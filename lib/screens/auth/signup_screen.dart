// lib\screens\auth\signup_screen.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/screens/auth/login_screen.dart';
import 'package:tabourak/screens/steps_for_Meetings/step1.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/config.dart';
import '../../config/globals.dart';



class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Email validation
  Future<bool> _isEmailValid(String email) async {
    final uri = Uri.parse(
      'https://emailvalidation.abstractapi.com/v1/?api_key=b9d12753d3ae40529fe4cf37caf8592f&email=$email',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['deliverability'] == 'DELIVERABLE';
      }
      return false;
    } catch (e) {
      print('Error verifying email: $e');
      return false;
    }
  }

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false; // Added loading state

  final String apiUrl = '${AppConfig.baseUrl}/api/auth/register';

  void _register() async {
    setState(() {
      _isLoading = true;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorDialog("All fields must be filled.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    bool isValidEmail = await _isEmailValid(email);
    if (!isValidEmail) {
      _showErrorDialog("Invalid email. Please enter a valid email address.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": username,
          "email": email,
          "password": password,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        globalAuthToken = responseData['token'];
        // Get token from response and pass to next screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentSetupScreen(
            ),
          ),
        );
      } else {
        _showErrorDialog(responseData['message'] ?? "Registration failed. Please try again.");
      }
    } catch (e) {
      // _showErrorDialog("Connection error. Please try again.");
      print(e.toString());
      
      _showErrorDialog("Error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Registration Error",
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
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/signupBackground.png'),
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
                "SIGN UP TO TABOURAK",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 40),

              // Username
              TextField(
                controller: _usernameController,
                style: TextStyle(color: AppColors.textColorSecond),
                decoration: InputDecoration(
                  hintText: "Username",
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 153, 153, 153),
                  ),
                  prefixIcon: Icon(
                    Icons.person,
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

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    disabledBackgroundColor: Colors.grey, // Loading state color
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "SIGN UP",
                          style: TextStyle(color: AppColors.backgroundColor),
                        ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                  child: Text(
                    "Already have an account? LOGIN NOW",
                    style: TextStyle(color: AppColors.primaryColor),
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