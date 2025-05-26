//C:\Users\User\Desktop\flutter project\tabourak\lib\screens\steps_for_Meetings\step3.dart
import 'package:flutter/material.dart';
import 'package:tabourak/screens/steps_for_Meetings/step3complet.dart';
import 'package:tabourak/screens/steps_for_Meetings/step4.dart';
import '../../colors/app_colors.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import '../../config/config.dart';
import '../../config/globals.dart';

class CalendarPage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/calendar.events',
    ],
    serverClientId:
        '1014877598829-img83d5tkn6cu53oj8668055oqrkp2gl.apps.googleusercontent.com',
    forceCodeForRefreshToken: true,
  );
  

  Future<void> _connectCalrnder(BuildContext context) async {
    print('here inside the calender');

    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final accessToken = googleAuth.accessToken;


      final calendarResponse = await http.get(
        Uri.parse(
          'https://www.googleapis.com/calendar/v3/users/me/calendarList',
        ),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      print(calendarResponse.body);

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/calendar/connect'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "accessToken": googleAuth.accessToken,
          "email": googleUser.email,
          "globalAuthToken": globalAuthToken,
        }),
      );


      print('Google Auth Data:');
      print('ID Token: ${googleAuth.idToken}');
      print('Access Token: ${googleAuth.accessToken}');
      print('Email: ${googleUser.email}');

      print('Backend Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ConnectCalendarPage(accessToken: accessToken!),
          ),
        );
      } else {
        try {
          final responseBody = jsonDecode(response.body);
          String errorMessage =
              responseBody['message'] ?? 'Unknown error occurred';
          _showErrorDialog(context, "$errorMessage");
        } catch (e) {
          _showErrorDialog(context, "Google login failed. Please try again.");
        }
      }
    } catch (e) {
      print("");

      _showErrorDialog(
        context,
        "Error signing in with Google: ${e.toString()}",
      );
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
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
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  "Step 4 of 5",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 40),

              const SizedBox(height: 40),
              Text(
                "Connect Your Calendar",
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Ensure that existing events in your calendar block out times on your scheduling page.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),

              // Google Connect Button
              _buildConnectBox(
                iconPath: 'images/google_logo.png',
                title: 'Google',
                subtitle: 'Gmail & Google Workspace (aka GSuite) accounts.',
                onPressed: () {
                  _connectCalrnder(context);
                },
              ),
              const SizedBox(height: 16),

              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 500),
                      pageBuilder: (_, __, ___) => SchedulingPage(),
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(1, 0),
                            end: Offset(0, 0),
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Text(
                  "I don’t want to connect my calendar right now",
                  style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
              Text("© 2025 Tabourak", style: TextStyle(color: Colors.grey)),
              Text(
                "Privacy Policy | Terms & Conditions",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectBox({
    required String iconPath,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          Image.asset(iconPath, height: 32, width: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Connect", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
