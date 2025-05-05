import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/home_screen.dart';
import '../colors/app_colors.dart'; 

void main() {
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