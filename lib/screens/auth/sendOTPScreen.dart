import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/config/config.dart';
import 'package:tabourak/screens/auth/VerifyOTPScreen.dart';

class SendOtpScreen extends StatefulWidget {
  @override
  _SendOtpScreenState createState() => _SendOtpScreenState();
}

class _SendOtpScreenState extends State<SendOtpScreen> {
  final emailController = TextEditingController();
  String? hash;

  Future<void> sendOtp() async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/otp/otp-login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": emailController.text}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      setState(() {
        hash = body["data"];
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(
            email: emailController.text,
            hash: hash!,
          ),
        ),
      );
    } else {
      _showErrorDialog("Failed to send OTP. Please check your email.");
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
              "Email confirmation",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.backgroundColor,
                ),
              ),
              SizedBox(height: 40),

              TextField(
                controller: emailController,
                style: TextStyle(color: AppColors.textColorSecond),
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: TextStyle(color: Color.fromARGB(255, 153, 153, 153)),
                  prefixIcon: Icon(Icons.email, color: AppColors.textColorSecond),
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
                  onPressed: sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundColor,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Send code",
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
