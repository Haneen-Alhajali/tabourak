import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/steps_for_Meetings/step1.dart';
import 'screens/steps_for_Meetings/step2.dart';
import 'screens/steps_for_Meetings/step3.dart';
import 'screens/steps_for_Meetings/step4.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/home_screen.dart';
import '../colors/app_colors.dart'; 
import '../config/globals.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tabourak/web%20pages/MeetingBooking.dart';

void main() {
    globalAuthToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNzQ4MTY2OTYxLCJleHAiOjE3NDgxODQ5NjF9.syDAGYbekzu_yF85fYKnMXgSNMFOAsise_ev55QnxvE';
 if (kIsWeb) {
    runApp(MeetingApp()); 
  }
  else{
  runApp(MyApp());

  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabourak Clone',
      theme: ThemeData(
            snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentTextStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        primarySwatch:  AppColors.primarySwatch,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16, color: AppColors.textColor),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        // '/': (context) => SchedulingPage(), // Step 4
        // '/': (context) => ConnectCalendarPage(), // Step 3
        // '/': (context) => AvailabilityScreen(), // Step 2
        // '/step2': (context) => AvailabilityScreen(), // Step 2
      //  '/': (context) => AppointmentSetupScreen(), // step1
        // '/step1': (context) => AppointmentSetupScreen(), // Provide actual token
        // '/': (context) => LoginPage(),
        '/login': (context) => LoginPage(),
        '/admin': (context) => AdminDashboard(),
      },
    );
  }
}

class ErrorHandler extends StatelessWidget {
  final Widget child;

  ErrorHandler({required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e) {
          return Center(
            child: Text('An error occurred: $e'),
          );
        }
      },
    );
  }
}
