import 'package:flutter/material.dart';
import 'step2.dart';
import '../../colors/app_colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppointmentSetupScreen(),
    );
  }
}

class AppointmentSetupScreen extends StatefulWidget {
  @override
  _AppointmentSetupScreenState createState() => _AppointmentSetupScreenState();
}


class _AppointmentSetupScreenState extends State<AppointmentSetupScreen> {
  List<bool> isSelected = [true, true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/tabourakNobackground.png',
                    width: 60,
                    height: 60,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Tabourak",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text("Step 1 of 4", style: TextStyle(color: AppColors.textColorSecond)),
              SizedBox(height: 20),
              Text(
                "How do your appointments take place?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Let's start setting up your scheduling page.",
                textAlign: TextAlign.center,
                style: TextStyle(color:AppColors.textColorSecond),
              ),
              SizedBox(height: 20),

              _buildOption(0, Icons.home, "At a place"),
              _buildOption(1, Icons.video_call, "Web conference"),
              _buildOption(2, Icons.phone, "Phone call"),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 500),
                      pageBuilder: (_, __, ___) => AvailabilityScreen(),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor:AppColors.primaryColor,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  "Next: Availability →",
                  style: TextStyle(color:AppColors.backgroundColor, fontSize: 16),
                ),
              ),

              SizedBox(height: 20),

              Text(
                "Privacy Policy | Terms & Conditions",
                style: TextStyle(color: AppColors.textColorSecond, fontSize: 12),
              ),
              SizedBox(height: 8),
              Text(
                "© 2025 Tabourak",
                style: TextStyle(color:AppColors.textColorSecond, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(int index, IconData icon, String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected[index] = !isSelected[index];
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected[index] ? AppColors.primaryColor : AppColors.textColorSecond,
          ),
          color:
              isSelected[index] ?AppColors.lightcolor :AppColors.backgroundColor,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected[index] ?AppColors.primaryColor : AppColors.textColor),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            if (isSelected[index])
              Icon(Icons.check_circle, color:AppColors.primaryColor),
          ],
        ),
      ),
    );
  }
}
