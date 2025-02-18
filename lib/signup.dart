import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginpage.dart';
import 'utils/sharedpreferencesextension.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Field validation states
  bool _isSignUpClick = false;
  bool _isFullNameValid = false;
  bool _isUsernameValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _isEmailValid = false;
  bool _isBirthdayValid = false;

  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  final DatabaseReference counterRef = FirebaseDatabase.instance.ref("numberOfUsers");


  String? fcmToken;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _getFcmToken();
    _fieldListener();
  }
  void _fieldListener(){
    // Add listeners to the controllers
    fullnameController.addListener(() {
      setState(() {
        _isFullNameValid = fullnameController.text.isNotEmpty;
      });
    });
    usernameController.addListener(() {
      setState(() {
        _isUsernameValid = usernameController.text.isNotEmpty;
      });
    });
    passwordController.addListener(() {
      setState(() {
        _isPasswordValid = passwordController.text.isNotEmpty;
      });
    });
    confirmPasswordController.addListener(() {
      setState(() {
        _isConfirmPasswordValid = confirmPasswordController.text.isNotEmpty;
      });
    });
    emailController.addListener(() {
      setState(() {
        _isEmailValid = emailController.text.isNotEmpty;
      });
    });
    birthdayController.addListener(() {
      setState(() {
        _isBirthdayValid = birthdayController.text.isNotEmpty;
      });
    });
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        birthdayController.text =
            DateFormat('MM-dd-yyyy').format(_selectedDate!);
        ageController.text =
            '${_calculateAge(_selectedDate!)} years old'; // Calculate age if needed
      });
    }
  }
  // @override
  // void dispose() {
  //   // Dispose controllers
  //   fullnameController.dispose();
  //   usernameController.dispose();
  //   passwordController.dispose();
  //   confirmPasswordController.dispose();
  //   emailController.dispose();
  //   birthdayController.dispose();
  //   ageController.dispose();
  //   super.dispose();
  // }
  String _calculateAge(DateTime birthDate) {
    final DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return '$age';
  }

  Future<void> _getFcmToken() async {
    await FirebaseMessaging.instance.requestPermission();
    fcmToken = await FirebaseMessaging.instance.getToken();
  }

  void createUser() async {
    setState(() {
      _isSignUpClick = true; // Set to true when sign up is clicked
    });
    String fullName = fullnameController.text;
    String username = usernameController.text;
    String password = passwordController.text;
    String email = emailController.text;
    String birthday = birthdayController.text;
    String age = ageController.text;
    final snapshot = await counterRef.once();
    int currentCount = (snapshot.snapshot.value ?? 0) as int;
    int newUserId = currentCount + 1;

    // Validate fields
    _isFullNameValid = fullnameController.text.isNotEmpty;
    _isUsernameValid = usernameController.text.isNotEmpty;
    _isPasswordValid = passwordController.text.isNotEmpty;
    _isConfirmPasswordValid = confirmPasswordController.text.isNotEmpty;
    _isEmailValid = emailController.text.isNotEmpty;
    _isBirthdayValid = birthdayController.text.isNotEmpty;

    if (!_isFullNameValid ||
        !_isUsernameValid ||
        !_isPasswordValid ||
        !_isConfirmPasswordValid ||
        !_isEmailValid ||
        !_isBirthdayValid) {
      Fluttertoast.showToast(
        msg: "Please fill in all fields.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        textColor: Colors.red,
      );
      return;
    }
    DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");
    DatabaseEvent usernameEvent = await usersRef.orderByChild('username').equalTo(username).once();
    DatabaseEvent emailEvent = await usersRef.orderByChild('email').equalTo(email).once();
    if (usernameEvent.snapshot.value != null) {
      Fluttertoast.showToast(
        msg: "Username already exists. Please choose a different one.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (emailEvent.snapshot.value != null) {
      Fluttertoast.showToast(
        msg: "Email already exists. Please use a different email.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else if (Platform.isAndroid) {
      platform = 'Android';
    } else if (Platform.isWindows) {
      platform = 'Windows';
    } else if (Platform.isLinux) {
      platform = 'Linux';
    } else if (Platform.isMacOS) {
      platform = 'macOS';
    } else {
      platform = 'Unknown Platform';
    }

    String dateCreated = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    String status = "offline"; // Initial status
    String profilePicture = ""; // Initial status

    Map<String, dynamic> userData = {
      'full name': fullName,
      'username': username,
      'password': password,
      'email': email,
      'fcmToken': fcmToken,
      'birthday': birthday,
      'age': age,
      'platform': platform,
      'status': status, // Add status field
      'dateCreated': dateCreated, // Add dateCreated field
      'profilePicture': profilePicture, // Add dateCreated field
    };
    await counterRef.set(newUserId); // Update the counter
    await ref.child('UID00000$newUserId').set(userData);

    Fluttertoast.showToast(
      msg: "Sign up successful!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.white,
      textColor: Color(0xFF4d4dfa),
      fontSize: 16.0,
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringKey(SharedPreferencesKeys.username, username);
    await prefs.setStringKey(SharedPreferencesKeys.password, password);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Login", style: TextStyle(color: Color(0xFF4d4dfa))),
        iconTheme: IconThemeData(
          color: Color(0xFF4d4dfa), // Change this to your desired back icon color
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Text(
              "Freezebook",
              style: TextStyle(
                color: Color(0xc64d4dfa),
                fontWeight: FontWeight.bold,
                fontSize: 50,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Sign Up",
              style: TextStyle(
                color: Color(0xc64d4dfa),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: fullnameController,
              decoration: InputDecoration(
                labelText: 'Full name',
                labelStyle: TextStyle(color: Colors.white),
                // Change label color to white
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  // Set the border radius for rounded corners
                  borderSide: BorderSide(
                      color:_isSignUpClick && !_isFullNameValid?Colors.red : Color(0xc64d4dfa)), // Change underline color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  // Set the border radius for rounded corners
                  borderSide: BorderSide(
                      color: Colors.white), // Change focused underline color
                ),
              ),
              style:
                  TextStyle(color: Colors.white), // Change text color to white
            ),
            const SizedBox(height: 10),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.white),
                // Change label color to white
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  // Set the border radius for rounded corners
                  borderSide: BorderSide(
                      color:_isSignUpClick && !_isUsernameValid?Colors.red : Color(0xc64d4dfa)),// Change underline color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  // Set the border radius for rounded corners
                  borderSide: BorderSide(
                      color: Colors.white), // Change focused underline color
                ),
              ),
              style:
                  TextStyle(color: Colors.white), // Change text color to white
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
                // Change label color to white
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  // Set the border radius for rounded corners
                  borderSide: BorderSide(
                      color:_isSignUpClick && !_isPasswordValid?Colors.red : Color(0xc64d4dfa)), // Change underline color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  // Set the border radius for rounded corners
                  borderSide: BorderSide(
                      color: Colors.white), // Change focused underline color
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white, // Change icon color to white
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
                    });
                  },
                ),
              ),
              style:
                  TextStyle(color: Colors.white), // Change text color to white
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: Colors.white),
                // Change label color to white
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  // Set the border radius for rounded corners
                  borderSide: BorderSide(
                      color:_isSignUpClick && !_isConfirmPasswordValid?Colors.red : Color(0xc64d4dfa)), // Change underline color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  // Set the border radius for rounded corners
                  borderSide: BorderSide(
                      color: Colors.white), // Change focused underline color
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white, // Change icon color to white
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible; // Toggle password visibility
                    });
                  },
                ),
              ),
              style:
              TextStyle(color: Colors.white), // Change text color to white
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
                // Change label color to white
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  // Set the border radius for rounded corners
                  borderSide: BorderSide(
                      color:_isSignUpClick && !_isEmailValid?Colors.red : Color(0xc64d4dfa)),// Change underline color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  // Set the border radius for rounded corners
                  borderSide: BorderSide(
                      color: Colors.white), // Change focused underline color
                ),
              ),
              style:
                  TextStyle(color: Colors.white), // Change text color to white
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  readOnly: true,
                  controller: birthdayController,
                  decoration: InputDecoration(
                    labelText: 'Birthday',
                    labelStyle: TextStyle(color: Colors.white),
                    // Change label color to white
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      // Set the border radius for rounded corners
                      borderSide: BorderSide(
                          color: _isSignUpClick && !_isBirthdayValid?Colors.red : Color(0xc64d4dfa)),// Change underline color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      // Set the border radius for rounded corners
                      borderSide: BorderSide(
                          color:
                              Colors.white), // Change focused underline color
                    ),
                  ),
                  style: TextStyle(
                      color: Colors.white), // Change text color to white
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              readOnly: true,
              controller: ageController,
              decoration: InputDecoration(
                labelText: 'Age',
                labelStyle: TextStyle(color: ageController.text.isNotEmpty ? Colors.green : Colors.white),
                // Change label color to white
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  // Set the border radius for rounded corners
                  borderSide: BorderSide(
                      color:_isSignUpClick && !_isBirthdayValid?Colors.red : Color(0xc64d4dfa)), // Change underline color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  // Set the border radius for rounded corners
                  borderSide: BorderSide(
                      color: Colors.white), // Change focused underline color
                ),
              ),
              style:
                  TextStyle(color: Colors.white), // Change text color to white
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFF4d4dfa), // Change this to your desired background color
              ),
              onPressed: createUser,
              child: const Text('Sign up',
              style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
