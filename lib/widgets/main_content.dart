import 'package:flutter/material.dart';
import '../content/meetings_content.dart';
import '../content/pages/pages_content.dart';
import '../content/availability/availability_content.dart';
import '../content/members_content.dart';
import '../content/settings_content.dart';

class MainContent extends StatelessWidget {
  final String? selectedNav;

  MainContent({this.selectedNav});

  @override
  Widget build(BuildContext context) {
    // Define content based on the selected nav button
    Widget content;
    switch (selectedNav) {
      case 'Meetings':
        content = MeetingsContent();
        break;
      case 'Pages':
        content = PagesContent();
        break;
      case 'Availability':
        content = AvailabilityContent();
        break;
      case 'Members':
        content = MembersContent();
        break;
      case 'Settings':
        content = SettingsContent();
        break;
      default:
        content = MeetingsContent(); // Default content
    }

    return Padding(
      padding: const EdgeInsets.only(top: 32, left: 16), // Added margin from the top and left
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Content
            content,
          ],
        ),
      ),
    );
  }
}
