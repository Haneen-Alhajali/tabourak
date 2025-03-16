import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';

class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // User Image
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
                'https://via.placeholder.com/150'), // Dummy image
          ),
          SizedBox(width: 8),
          // User Name and Email
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Haneen Alhajali', // User name
                style: TextStyle(
                  color: AppColors.backgroundColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'haneen@example.com', // Dummy email
                style: TextStyle(
                  color:  AppColors.backgroundColor.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}