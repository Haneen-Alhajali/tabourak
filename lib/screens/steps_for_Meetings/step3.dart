import 'package:flutter/material.dart';
import 'step4.dart';
import '../../colors/app_colors.dart';

class ConnectCalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primaryColor),
                SizedBox(width: 10),
                Text(
                  "Connect Your Calendar",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text("Ensure that existing events in your calendar block out times on your scheduling page."),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: Row(
                children: [
                
                
                  SizedBox(width: 10),
                  Expanded(child: Text("Connected to Google\ns12113539@stu.najah.edu")),
                  Icon(Icons.check_circle, color:AppColors.primaryColor),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text("How should we sync with your calendar?", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildDropdown("Add scheduled meetings to this calendar"),
            SizedBox(height: 10),
            _buildDropdown("Check events in these calendars to prevent double-bookings"),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:AppColors.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
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
              child: Center(child: Text("Next: Your Information →", style: TextStyle(fontSize: 16, color:AppColors.backgroundColor))),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: SizedBox(),
            value: "s12113539@stu.najah.edu",
            items: [
              DropdownMenuItem(value: "s12113539@stu.najah.edu", child: Text("s12113539@stu.najah.edu")),
            ],
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }

}

