import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'MeetingTypesTab.dart'; // Import the MeetingTypesTab file
import 'SettingsTab.dart'; // Import the SettingsTab file

class PagesContent extends StatefulWidget {
  @override
  _PagesContentState createState() => _PagesContentState();
}

class _PagesContentState extends State<PagesContent>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  int meetingTypes = 2;
  int teamMembers = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: false, // Ensure the tabs are not scrollable
          labelColor: AppColors.backgroundColor,
          unselectedLabelColor: AppColors.textColor,
          indicator: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          labelPadding: EdgeInsets.symmetric(horizontal: 2),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule),
                  SizedBox(width: 5),
                  Text(
                    'Meeting Types',
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group),
                  SizedBox(width: 5),
                  Text(
                    'Team Members',
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 5),
                  Text(
                    'Settings',
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height:
              MediaQuery.of(context).size.height -
              180, // Adjust height as needed
          child: TabBarView(
            controller: _tabController,
            children: [
              Center(child: MeetingTypesTab()),
              Center(
                child: Text('Team Members', style: TextStyle(fontSize: 14)),
              ),
              Center(child: SettingsTab()),
            ],
          ),
        ),
      ],
    );
  }
}
