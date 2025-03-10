import 'package:flutter/material.dart';

class MeetingsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Meetings', // Default title
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle schedule meeting
              },
              child: Text('+ Schedule Meeting'),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Filters and Search
        Row(
          children: [
            Container(
              padding: EdgeInsets.only(left: 8, top: 6, bottom: 6), // Added padding from the left, top, and bottom
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4), // Box shape
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: 'Upcoming',
                  items: [
                    {'label': 'Upcoming', 'icon': Icons.calendar_today},
                    {'label': 'Past', 'icon': Icons.history},
                    {'label': 'Today', 'icon': Icons.today},
                    {'label': 'Tomorrow', 'icon': Icons.next_week},
                    {'label': 'Next 7 Days', 'icon': Icons.calendar_view_week},
                    {'label': 'Next 30 Days', 'icon': Icons.calendar_today},
                  ].map((item) {
                    return DropdownMenuItem<String>(
                      value: item['label'] as String,
                      child: Row(
                        children: [
                          Icon(item['icon'] as IconData, size: 18), // Reduced icon size
                          SizedBox(width: 8),
                          Text(item['label'] as String),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // Handle filter change
                  },
                  isDense: true, // Reduce the height of the dropdown
                ),
              ),
            ),
            SizedBox(width: 12), // Adjusted space between dropdown and search
            Expanded(
              child: Container(
                height: 40, // Set fixed height of the search box to 30
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search, size: 18), // Reduced icon size
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8), // Reduced height
                    isDense: true, // Reduce the height of the search box
                  ),
                  textAlignVertical: TextAlignVertical.center, // Vertically center the text
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Divider(),
        SizedBox(height: 16),
        // No Meetings Found
        Center(
          child: Column(
            children: [
              Image.asset(
                'images/no-event-bg.png',
                width: 400, 
              ),
              SizedBox(height: 16),
              Text(
                'No meetings found',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Try removing or adjusting your filters.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
