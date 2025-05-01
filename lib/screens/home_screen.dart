
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/main_content.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSidebarExpanded = false;
  String? _selectedNav = 'Meetings'; // Meetings Default selected nav

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }

  void _closeSidebar() {
    setState(() {
      _isSidebarExpanded = false;
    });
  }

  void _onNavSelected(String nav) {
    setState(() {
      _selectedNav = nav;
      _isSidebarExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          MainContent(selectedNav: _selectedNav),
          // Floating Sidebar
          if (_isSidebarExpanded)
            GestureDetector(
              onTap: _closeSidebar,
              child: Container(
                color: AppColors.textColor.withOpacity(0.3),
              ),
            ),
          if (_isSidebarExpanded)
            Align(
              alignment: Alignment.centerLeft,
              child: Sidebar(
                onClose: _closeSidebar,
                onNavSelected: _onNavSelected,
                selectedNav: _selectedNav,
              ),
            ),
        ],
      ),
      // Hamburger Button Menu Below the Sidebar
      floatingActionButton: _isSidebarExpanded
          ? null // Hide the button when the sidebar is expanded
          : Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 32, bottom: 32), // Added margin
                child: FloatingActionButton(
                  onPressed: _toggleSidebar,
                  backgroundColor: AppColors.primaryColor, // Hamburger button background color
                  child: Icon(Icons.menu, color: AppColors.backgroundColor),
                ),
              ),
            ),
    );
  }
}