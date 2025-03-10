import 'package:flutter/material.dart';
import 'widgets/schedule_manager_section.dart';
import 'widgets/recurring_weekly_hours_section.dart';
import 'widgets/date_specific_hours_section.dart';
import 'widgets/custom_widgets.dart';
import 'widgets/meeting_limits_content.dart'; // Import the new file for Meeting Limits
import 'widgets/calendars_content.dart'; // Import the new file for Calendars

class AvailabilityContent extends StatefulWidget {
  const AvailabilityContent({Key? key}) : super(key: key);

  @override
  _AvailabilityContentState createState() => _AvailabilityContentState();
}

class _AvailabilityContentState extends State<AvailabilityContent> {
  String _selectedTab = 'Schedules';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          'Availability & Calendars',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Tabs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTab(Icons.schedule, 'Schedules'),
            _buildTab(Icons.calendar_today, 'Calendars'),
            _buildTab(Icons.shield, 'Meeting Limits'), // Updated icon
          ],
        ),

        // Divider Line exactly under the blue line
        Container(
          height: 2,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 16),

        // Dynamic Content
        if (_selectedTab == 'Schedules')
          Column(
            children: const [
              ScheduleManagerSection(),
              SizedBox(height: 24),
              RecurringWeeklyHoursSection(),
              SizedBox(height: 24),
              DateSpecificHoursSection(),
            ],
          ),
        if (_selectedTab == 'Calendars')
          const CalendarsContent(), // Use the new CalendarsContent file
        if (_selectedTab == 'Meeting Limits')
          const MeetingLimitsContent(),
      ],
    );
  }

  Widget _buildTab(IconData icon, String title) {
    final bool isActive = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: isActive ? Colors.blue : Colors.grey, size: 20), // Smaller icons
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.blue : Colors.grey,
                  fontSize: 14, // Smaller font size
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          if (isActive)
            Container(
              width: title.length * 8.5, // Adjust width based on title length
              height: 2,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }
}
