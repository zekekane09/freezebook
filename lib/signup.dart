import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freezebook/utils/sharedpreferencesextension.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'data/baseresponse.dart';
import 'loginpage.dart';

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
  bool _isSignUpClick = false;

  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  final DatabaseReference counterRef = FirebaseDatabase.instance.ref("numberOfUsers");
  late String fcmToken;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _getFcmToken();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _getFcmToken() async {
    await FirebaseMessaging.instance.requestPermission();
    fcmToken = (await FirebaseMessaging.instance.getToken())!;
    print("FCM Token: $fcmToken");
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
        birthdayController.text = DateFormat('MM-dd-yyyy').format(_selectedDate!);
        ageController.text = '${_calculateAge(_selectedDate!)} years old';
      });
    }
  }

  String _calculateAge(DateTime birthDate) {
    final DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return '$age';
  }

  void createUser () async {
    setState(() {
      _isSignUpClick = true;
    });

    String fullName = fullnameController.text;
    String username = usernameController.text;
    String password = passwordController.text;
    String email = emailController.text;
    String birthday = birthdayController.text;

    if (_validateFields()) {


      String platform = _getPlatform();

      User newUser  = User(
        fullname: fullName,
        email: email,
        birthday: birthday,
        password: password,
        username: username,
        platform: platform,
        fcm_token: fcmToken,
      );
      print("Creating user with the following details:");
      print("Full Name: ${newUser .fullname}");
      print("Email: ${newUser .email}");
      print("Birthday: ${newUser .birthday}");
      print("Username: ${newUser .username}");
      print("FCM Token: ${newUser .fcm_token}");
      print("Platform: ${newUser .platform}");
      BaseResponse response = await ApiService.createUser (newUser );
      // Fluttertoast.showToast(
      //   msg: response.message,
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.BOTTOM,
      //   timeInSecForIosWeb: 5,
      //   backgroundColor: Colors.white,
      //   textColor: Color(0xFF4d4dfa),
      //   fontSize: 16.0,
      // );
      if (response.code == "SUCCESS"){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setStringKey(SharedPreferencesKeys.email, email);
        await prefs.setStringKey(SharedPreferencesKeys.password, password);
        // Navigate to LoginPage or handle post-signup logic
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    }
  }

  bool _validateFields() {
    if (fullnameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        emailController.text.isEmpty ||
        birthdayController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill in all fields.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        textColor: Colors.red,
      );
      return false;
    }
    return true;
  }

  String _getPlatform() {
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isMacOS) return 'macOS';
    return 'Unknown Platform';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Sign Up", style: TextStyle(color: Color(0xFF4d4dfa))),
        iconTheme: IconThemeData(color: Color(0xFF4d4dfa)),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Text("Freezebook", style: TextStyle(color: Color(0xc64d4dfa), fontWeight: FontWeight.bold, fontSize: 50)),
            const SizedBox(height: 10),
            Text("Sign Up", style: TextStyle(color: Color(0xc64d4dfa), fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 20),
            _buildTextField(fullnameController, 'Full name'),
            const SizedBox(height: 10),
            _buildTextField(usernameController, 'Username'),
            const SizedBox(height: 10),
            _buildPasswordField(passwordController, 'Password', _isPasswordVisible, () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            }),
            const SizedBox(height: 10),
            _buildPasswordField(confirmPasswordController, 'Confirm Password', _isConfirmPasswordVisible, () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            }),
            const SizedBox(height: 10),
            _buildTextField(emailController, 'Email'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: _buildTextField(birthdayController, 'Birthday', readOnly: true),
              ),
            ),
            const SizedBox(height: 10),
            _buildTextField(ageController, 'Age', readOnly: true),
            const SizedBox(height: 20),
            ElevatedButton(
              style: TextButton.styleFrom(backgroundColor: Color(0xFF4d4dfa)),
              onPressed: createUser ,
              child: const Text('Sign up', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: _isSignUpClick && controller.text.isEmpty ? Colors.red : Color(0xc64d4dfa)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, bool isVisible, VoidCallback toggleVisibility) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: _isSignUpClick && controller.text.isEmpty ? Colors.red : Color(0xc64d4dfa)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.white),
        ),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white),
          onPressed: toggleVisibility,
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}