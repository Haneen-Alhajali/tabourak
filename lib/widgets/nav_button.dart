import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';

class NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  NavButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.accentColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8), // Reduced padding
        title: Row(
          children: [
            Icon(icon, color: AppColors.backgroundColor, size: 22), // Reduced icon size
            SizedBox(width: 6), // Reduced space between icon and label
            Text(
              label,
              style: TextStyle(
                color: AppColors.backgroundColor,
                fontSize: 16, // Reduced font size
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
