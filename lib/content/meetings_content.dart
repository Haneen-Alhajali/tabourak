import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';

class MeetingsContent extends StatelessWidget {


  final meetings = [
  {
    'date': 'Friday\nMay 2, 2025',
    'time': '9:30 AM - 10:00 AM',
    'type': 'In-Person Meeting',
    'name': 'shahd yaseen',
  },
  {
    'date': 'Wednesday\nApril 30, 2025',
    'time': '10:30 AM - 11:00 AM',
    'type': 'In-Person Meeting',
    'name': 'shahd yaseen',
  },
];

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
                color: AppColors.textColor, // Set all text color to grey
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.mediumColor,
              ),
              child: Text(
                '+ Schedule Meeting',
                style: TextStyle(color: AppColors.textColor),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Filters and Search
        // Filters and Search + Menu
        Row(
          children: [
            // Dropdown Filter
            Container(
              padding: EdgeInsets.only(left: 8, top: 6, bottom: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textColor),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: 'Upcoming',
                  items:
                      [
                        {'label': 'Upcoming', 'icon': Icons.calendar_today},
                        {'label': 'Past', 'icon': Icons.history},
                        {'label': 'Today', 'icon': Icons.today},
                        {'label': 'Tomorrow', 'icon': Icons.next_week},
                        {
                          'label': 'Next 7 Days',
                          'icon': Icons.calendar_view_week,
                        },
                        {'label': 'Next 30 Days', 'icon': Icons.calendar_today},
                      ].map((item) {
                        return DropdownMenuItem<String>(
                          value: item['label'] as String,
                          child: Row(
                            children: [
                              Icon(item['icon'] as IconData, size: 18),
                              SizedBox(width: 8),
                              Text(
                                item['label'] as String,
                                style: TextStyle(
                                  color: AppColors.textColorSecond,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    // Handle filter change
                  },
                  isDense: true,
                ),
              ),
            ),
            SizedBox(width: 12),

            // Search Field
            Expanded(
              child: Container(
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: AppColors.textColorSecond),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: AppColors.textColor,
                    ),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 8,
                    ),
                    isDense: true,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ),

            // Menu Button
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppColors.textColor),
              onSelected: (value) {
                if (value == 'export') {
                  // TODO: export functionality
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem<String>(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.download, color: AppColors.textColor),
                          SizedBox(width: 8),
                          Text('Export Meeting Data (CSV)'),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),

        SizedBox(height: 6),
        Divider(),
        SizedBox(height: 16),

        // Replace "No meetings found" section with:
        Expanded(
          child: ListView(
            children: [
              for (var meeting in meetings) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    meeting['date']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorSecond,
                    ),
                  ),
                ),
                MeetingCard(
                  time: meeting['time']!,
                  type: meeting['type']!,
                  name: meeting['name']!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////

class MeetingCard extends StatelessWidget {
  final String time;
  final String type;
  final String name;

  const MeetingCard({
    required this.time,
    required this.type,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              child: Text(
                name.substring(0, 2).toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.mediumColor,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    type,
                    style: TextStyle(color: AppColors.textColorSecond),
                  ),
                  Text(name, style: TextStyle(color: AppColors.textColor)),
                ],
              ),
            ),
            Icon(Icons.more_vert, color: AppColors.textColor),
          ],
        ),
      ),
    );
  }
}
