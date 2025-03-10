import 'package:flutter/material.dart';
import 'MeetingTypesTab.dart'; // Import the MeetingTypesTab file
import 'SettingsTab.dart'; // Import the SettingsTab file

class PagesContent extends StatefulWidget {
  @override
  _PagesContentState createState() => _PagesContentState();
}

class _PagesContentState extends State<PagesContent> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Meeting Types (2)'),
              Tab(text: 'Team Members (1)'),
              Tab(text: 'Settings'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                MeetingTypesTab(),
                Center(child: Text('Team Members Tab Content')),
                SettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}