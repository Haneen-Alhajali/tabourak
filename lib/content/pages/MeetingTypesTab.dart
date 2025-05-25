import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'MeetingDetailsPage.dart';

class MeetingTypesTab extends StatefulWidget {
  @override
  _MeetingTypesTabState createState() => _MeetingTypesTabState();
}

class _MeetingTypesTabState extends State<MeetingTypesTab> {
  List<Map<String, String>> meetings = [
    {
      'title': 'In-Person Meeting',
      'duration': '30 minutes',
      'type': 'One-on-One',
      'link': 'https://appt.link/in-person-meeting',
    },
    {
      'title': 'Web Conference',
      'duration': '30 minutes',
      'type': 'One-on-One',
      'link': 'https://appt.link/web-conference',
    },
  ];

  final TextEditingController _nameController = TextEditingController();

  void _showCreateMeetingDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Create a meeting type"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Meeting types are the services that people want to schedule you for. They will appear on your scheduling page, and have a direct link you can share.",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Meeting Type Name",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _nameController.clear();
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.trim().isNotEmpty) {
                    setState(() {
                      meetings.add({
                        'title': _nameController.text.trim(),
                        'duration': '30 minutes',
                        'type': 'One-on-One',
                        'link':
                            'https://appt.link/${_nameController.text.trim().toLowerCase().replaceAll(' ', '-')}',
                      });
                      _nameController.clear();
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text("Create"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showCreateMeetingDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, 
                  ),
                ),
                icon: Icon(Icons.add),
                label: Text(
                  "New Meeting Type",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: meetings.length,
              itemBuilder: (context, index) {
                final meeting = meetings[index];

                final isLast = index == meetings.length - 1;

                return Column(
                  children: [
                    _buildMeetingTypeCard(
                      context,
                      index: index,
                      title: meeting['title']!,
                      duration: meeting['duration']!,
                      type: meeting['type']!,
                      link: meeting['link']!,
                    ),
                    SizedBox(height: isLast ? 100 : 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingTypeCard(
    BuildContext context, {
    required int index,
    required String title,
    required String duration,
    required String type,
    required String link,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => MeetingDetailsPage(
                  title: title,
                  duration: duration,
                  type: type,
                  link: link,
                ),
          ),
        );
      },
      child: Card(
        color: AppColors.lightcolor,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.accentColor,
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
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textColorSecond,
                  ),
                  SizedBox(width: 4),
                  Text(duration),
                  SizedBox(width: 16),
                  Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.textColorSecond,
                  ),
                  SizedBox(width: 4),
                  Text(type),
                ],
              ),
              SizedBox(height: 8),
              Text(link, style: TextStyle(color: AppColors.secondaryColor)),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // تقدرِ تضيفي نسخ الرابط هنا
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mediumColor,
                    ),
                    icon: Icon(
                      Icons.link,
                      size: 16,
                      color: AppColors.textColor,
                    ),
                    label: Text(
                      'Copy Link',
                      style: TextStyle(color: AppColors.textColorSecond),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        setState(() {
                          meetings.removeAt(index);
                        });
                      } else if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => MeetingDetailsPage(
                                  title: title,
                                  duration: duration,
                                  type: type,
                                  link: link,
                                ),
                          ),
                        );
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                    icon: Icon(Icons.more_vert, color: AppColors.textColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
