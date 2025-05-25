// lib\content\settings\email_password_settings_content.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';

class EmailPasswordContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Email & Password",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Your profile information is shared across all organizations you are a member of.",
                style: TextStyle(
                  color: AppColors.textColorSecond,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(color: AppColors.mediumColor, height: 1),
          SizedBox(height: 16),

          // Email Section
          _buildAccountSection(
            icon: Icons.email_outlined,
            title: "Email",
            subtitle: "royasmine05@gmail.com",
            buttonText: "Change Email",
            onPressed: () {},
          ),
          SizedBox(height: 16),
          Divider(color: AppColors.mediumColor, height: 1),
          SizedBox(height: 16),

          // Password Section
          _buildAccountSection(
            icon: Icons.lock_outline,
            title: "Password",
            subtitle: "Password has not been updated before.",
            buttonText: "Change Password",
            onPressed: () {},
          ),
          SizedBox(height: 16),
          Divider(color: AppColors.mediumColor, height: 1),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAccountSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback? onPressed,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 70, // Ensure minimum height for the section
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon and text section
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.lightcolor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.textColorSecond,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          // Button section
          Container(
            constraints: BoxConstraints(
              minWidth: 100, // Minimum width for the button
            ),
            child: TextButton(
              onPressed: onPressed,
              child: Text(
                buttonText,
                style: TextStyle(
                  color: onPressed != null
                      ? AppColors.primaryColor
                      : AppColors.textColorSecond,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}