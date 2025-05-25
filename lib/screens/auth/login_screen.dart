import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/screens/auth/sendOTPScreen.dart';
import 'package:http/http.dart' as http;
import 'package:tabourak/screens/home_screen.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import '../../config/config.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
    serverClientId:
        '1014877598829-img83d5tkn6cu53oj8668055oqrkp2gl.apps.googleusercontent.com',
  );

  /////////////////////ADD FOR VALID EMAIL
  Future<bool> _isEmailValid(String email) async {
    final uri = Uri.parse(
      'https://emailvalidation.abstractapi.com/v1/?api_key=b9d12753d3ae40529fe4cf37caf8592f&email=$email',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['deliverability'] == 'DELIVERABLE';
      } else {
        return false;
      }
    } catch (e) {
      print('Error verifying email: $e');
      return false;
    }
  }

  ///////////////////////////////////END OF VALID EMAIL
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  final String apiUrl = '${AppConfig.baseUrl}/api/auth/login';
  //////////////////////////////////////////////////////
  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("Email and password cannot be empty.");
      return;
    }

    bool isValidEmail = await _isEmailValid(email);
    if (!isValidEmail) {
      _showErrorDialog("Invalid email. Please enter a valid email address.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final responseData = jsonDecode(response.body);
      print(
        '🔴🔴🔴 🔴🔴🔴 🔴🔴🔴 🔴🔴🔴 🔴🔴🔴 🔴🔴🔴 🔴🔴🔴 🔴🔴🔴 🔴🔴🔴 🔴🔴🔴Response data: $responseData',
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        _showErrorDialog("Login failed. Please check your password.");
      }
    } catch (e) {
      _showErrorDialog("Error: ${e.toString()}");
    }
  }

  //////////for google
  Future<void> _signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('Google Auth Data:');
      print('ID Token: ${googleAuth.idToken}');
      print('Access Token: ${googleAuth.accessToken}');
      print('Email: ${googleUser.email}');

      if (googleAuth.idToken == null) {
        throw Exception('Google ID Token is null. Please try again.');
      }

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/auth/google'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": googleAuth.idToken, //
          "email": googleUser.email,
          "name": googleUser.displayName,
        }),
      );

      final responseData = jsonDecode(response.body);
      print(
        '🔴🔴🔴 🔴🔴🔴 🔴🔴🔴 🔴🔴🔴 🔴🔴🔴 🔴🔴🔴 🔴🔴🔴 🔴🔴🔴 🔴🔴🔴 🔴🔴🔴Response data: $responseData',
      );

      print('Backend Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        try {
          final responseBody = jsonDecode(response.body);
          String errorMessage =
              responseBody['message'] ?? 'Unknown error occurred';
          _showErrorDialog("$errorMessage");
        } catch (e) {
          _showErrorDialog("Google login failed. Please try again.");
        }
      }
    } catch (e) {
      print('Full Error: $e');
      _showErrorDialog("Error signing in with Google: ${e.toString()}");
    }
  }

  ///  //////////////////for goolge

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Login Error",
            style: TextStyle(color: AppColors.primaryColor),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/loginBackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "LOGIN TO TABOURAK",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.backgroundColor,
                ),
              ),

              const SizedBox(height: 40),

              // Email
              TextField(
                controller: _emailController,
                style: TextStyle(color: AppColors.textColorSecond),

                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 153, 153, 153),
                  ),
                  prefixIcon: Icon(
                    Icons.email,
                    color: AppColors.textColorSecond,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundColor,
                ),
              ),
              const SizedBox(height: 20),

              // Password
              TextField(
                controller: _passwordController,
                style: TextStyle(color: AppColors.textColorSecond),

                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 153, 153, 153),
                  ),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: AppColors.textColorSecond,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundColor,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundColor,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "LOGIN",
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Google Sign-In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('images/google_logo.png', height: 24),
                      SizedBox(width: 10),
                      Text(
                        "Sign in with Google",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SendOtpScreen()),
                    );
                  },
                  child: Text(
                    "Don't have an account? SIGN UP NOW",
                    style: TextStyle(color: AppColors.backgroundColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
