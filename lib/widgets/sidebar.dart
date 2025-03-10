import 'package:flutter/material.dart';
import 'nav_button.dart';
import 'user_profile.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback onClose;
  final Function(String) onNavSelected;
  final String? selectedNav;

  Sidebar({
    required this.onClose,
    required this.onNavSelected,
    this.selectedNav,
  });

  @override
  Widget build(BuildContext context) {
    final navButtons = [
      {'icon': Icons.calendar_today, 'label': 'Meetings'},
      {'icon': Icons.pages, 'label': 'Pages'},
      {'icon': Icons.schedule, 'label': 'Availability'},
      {'icon': Icons.people, 'label': 'Members'},
      {'icon': Icons.settings, 'label': 'Settings'},
    ];

    return Container(
      width: 250, // Increased width for the sidebar
      color: Colors.blue, // Background color
      child: Column(
        children: [
          // Margin from top for overall content
          Container(
            margin: EdgeInsets.only(top: 32), // Added margin from top
            child: Column(
              children: [
                // Logo and Close Button Row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16), // Horizontal padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between logo and close button
                    children: [
                      // Tabourak Logo
                      Expanded(
                        child: Align(
                          alignment: Alignment.center, // Center the logo horizontally
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50), // Circular shape
                            child: Image.asset(
                              'images/tabourak_logo.png', // Add your logo image to assets
                              width: 60, // Reduced size
                              height: 60,
                            ),
                          ),
                        ),
                      ),
                      // Close Button
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16), // Added space between logo and first navigation button (Meetings)
              ],
            ),
          ),
          // Navigation Buttons
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero, // Remove ListView padding
              children: navButtons.map((button) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0), // Reduced padding for nav buttons
                  child: NavButton(
                    icon: button['icon'] as IconData,
                    label: button['label'] as String,
                    isActive: selectedNav == button['label'],
                    onTap: () {
                      onNavSelected(button['label'] as String);
                      onClose();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          // Upgrade Button
          Container(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle upgrade
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              icon: Icon(Icons.star, color: Colors.white),
              label: Text(
                'Upgrade',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          // User Profile at the Bottom
          Container(
            margin: EdgeInsets.only(bottom: 16), // Added margin
            child: UserProfile(),
          ),
        ],
      ),
    );
  }
}
