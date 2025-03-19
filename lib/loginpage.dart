import 'package:flutter/material.dart';
import 'package:freezebook/homepage.dart';
import 'signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/sharedpreferencesextension.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late bool _isPasswordVisible = false;
  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  // Future<void> loginUser (String? username, String? password, BuildContext context) async {
  //   try {
  //     DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");
  //     DatabaseEvent event = await usersRef.orderByChild('username').equalTo(username).once();
  //     DataSnapshot snapshot = event.snapshot; // Correctly access the DataSnapshot
  //
  //     print("User  data found $snapshot");
  //     if (snapshot.value != null) {
  //       var userData = (snapshot.value as Map).values.first;
  //
  //       String email = userData['email'];
  //       String storedPassword = userData['password'];
  //       UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: email,
  //         password: password!,
  //       );
  //
  //       await usersRef.child(userCredential.user!.uid).child('status').set('ONLINE');
  //
  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('username', username!);
  //
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => Homepage(username: username)),
  //       );
  //     } else {
  //       print("User  data not found");
  //       Fluttertoast.showToast(
  //         msg: "User  data not found",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //         fontSize: 16.0,
  //       );
  //     }
  //   } catch (e) {
  //     print("Error logging in: $e");
  //     Fluttertoast.showToast(
  //       msg: "Error logging in: $e",
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //       fontSize: 16.0,
  //     );
  //   }
  // }
  //
  void loginUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getStringKey(SharedPreferencesKeys.username);
    String? password = prefs.getStringKey(SharedPreferencesKeys.password);
    if (usernameController.text == username && passwordController.text == password) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage(username: username)),
      );
    } else {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  void _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getStringKey(SharedPreferencesKeys.username);
    String? password = prefs.getStringKey(SharedPreferencesKeys.password);

    if (username != null) {
      usernameController.text = username;
    }
    if (password != null) {
      passwordController.text = password;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color to black
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Text(
              "Freezebook",
              style: TextStyle(
                color: Color(0xFF4d4dfa), // Change text color to white
                fontWeight: FontWeight.bold,
                fontSize: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Login",
              style: TextStyle(
                color: Color(0xFF4d4dfa), // Change text color to white
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.white), // Change label color to white
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Set the border radius for rounded corners
                  borderSide: BorderSide(color: Color(0xFF4d4dfa)), // Change underline color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Set the border radius for rounded corners
                  borderSide: BorderSide(color: Colors.white), // Change focused underline color
                ),
              ),
              style: TextStyle(color: Colors.white), // Change text color to white
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white), // Change label color to white
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Set the border radius for rounded corners
                  borderSide: BorderSide(color: Color(0xFF4d4dfa)), // Change underline color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Set the border radius for rounded corners
                  borderSide: BorderSide(color: Colors.white), // Change focused underline color
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
              style: TextStyle(color: Colors.white), // Change text color to white
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFF4d4dfa), // Change this to your desired background color
              ),
              onPressed:() {
                loginUser();
              } ,
              child: const Text('Login',
                style: TextStyle(color: Colors.white),),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.white), // Change text color to white
                    ),
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(color: Colors.red), // Change "Sign Up" color to blue
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}