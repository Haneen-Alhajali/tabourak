import 'package:flutter/material.dart';

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
        color: isActive ? Colors.blue[800] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8), // Reduced padding
        title: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22), // Reduced icon size
            SizedBox(width: 6), // Reduced space between icon and label
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
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
