import 'package:flutter/material.dart';

class MeetingTypesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Building MeetingTypesTab"); // Debugging log
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildMeetingTypeCard(
          title: 'In-Person Meeting',
          duration: '30 minutes',
          type: 'One-on-One',
          link: 'https://appt.link/meet-with-yasmine-ro-yUnB9Oqn/in-person-meeting',
        ),
        SizedBox(height: 16),
        _buildMeetingTypeCard(
          title: 'Web Conference',
          duration: '30 minutes',
          type: 'One-on-One',
          link: 'https://appt.link/meet-with-yasmine-ro-yUnB9Oqn/web-conference',
        ),
      ],
    );
  }

  Widget _buildMeetingTypeCard({
    required String title,
    required String duration,
    required String type,
    required String link,
  }) {
    print("Building MeetingTypeCard: $title"); // Debugging log
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF1E9BFF),
                  radius: 8,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(duration),
                SizedBox(width: 16),
                Icon(Icons.person, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(type),
              ],
            ),
            SizedBox(height: 8),
            Text(
              link,
              style: TextStyle(color: Colors.blue),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.link, size: 16),
                  label: Text('Copy Link'),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}