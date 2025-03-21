import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/screens/auth/signup_screen.dart';
import 'package:tabourak/screens/steps_for_Meetings/step1.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("Email and password cannot be empty.");
      return;
    }

    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null && response.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AppointmentSetupScreen()),
        );
      } else {
        _showErrorDialog(
          "Login failed. Please check your credentials and try again.",
        );
      }
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains("invalid login credentials")) {
        _showErrorDialog("Incorrect email or password. Please try again.");
      } else if (e.message.toLowerCase().contains("user not found")) {
        _showErrorDialog("No account found with this email. Please sign up.");
      } else {
        _showErrorDialog("Login failed: ${e.message}");
      }
    } catch (e) {
      _showErrorDialog("An unexpected error occurred. Please try again later.");
    }
  }

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
          gradient: LinearGradient(
            colors: [
              AppColors.accentColor,
              AppColors.backgroundColor,
            ], 
            stops: [0.1, 0.9], 

            begin: Alignment.topLeft, 
            end: Alignment.bottomRight, 
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "LOGIN TO CONTINUE",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: AppColors.textColorSecond),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: AppColors.lightcolor,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: AppColors.textColorSecond),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: AppColors.lightcolor,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text("LOGIN", style: TextStyle(color: Colors.white)),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text(
                    "Don't have an account? SIGN UP NOW",
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
