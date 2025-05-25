import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';

class CustomTab extends StatelessWidget {
  final String title;
  final bool isActive;
  final bool hasBadge;

  const CustomTab({
    Key? key,
    required this.title,
    this.isActive = false,
    this.hasBadge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primaryColor : AppColors.textColorSecond,
          ),
        ),
        if (isActive)
          Container(
            height: 3,
            width: 40,
            color: AppColors.primaryColor,
          ),
        if (hasBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'New',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}