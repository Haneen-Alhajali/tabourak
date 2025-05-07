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


void main() {
    globalAuthToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NSwiaWF0IjoxNzQ2NjI5NzcyLCJleHAiOjE3NDY2MzMzNzJ9.3oM4DJpHmPLXZRExIKL_9TqSfyjkvNG1UlMXAlwfSK4';
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabourak Clone',
      theme: ThemeData(
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