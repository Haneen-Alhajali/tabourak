import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/screens/auth/signup_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  final String hash;

  VerifyOtpScreen({required this.email, required this.hash});

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final otpController = TextEditingController();

  Future<void> verifyOtp() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.140:3000/api/otp/otp-verify'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": widget.email,
        "otp": otpController.text,
        "hash": widget.hash,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegisterPage(email:widget.email)),
      );
    } else {
      _showErrorDialog("The verification code is incorrect or expired.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error", style: TextStyle(color: AppColors.primaryColor)),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("Ok", style: TextStyle(color: AppColors.primaryColor)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
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
                "Enter the verification code",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.backgroundColor,
                ),
              ),
              SizedBox(height: 40),

              TextField(
                controller: otpController,
                style: TextStyle(color: AppColors.textColorSecond),
                decoration: InputDecoration(
                  hintText: "verification code",
                  hintStyle: TextStyle(color: Color.fromARGB(255, 153, 153, 153)),
                  prefixIcon: Icon(Icons.lock, color: AppColors.textColorSecond),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundColor,
                ),
              ),
              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundColor,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "verification",
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
