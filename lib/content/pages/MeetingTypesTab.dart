// lib\content\pages\MeetingTypesTab.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tabourak/colors/app_colors.dart';
import 'dart:convert';
import 'package:tabourak/config/config.dart';
import 'package:tabourak/config/globals.dart';
import 'package:tabourak/config/snackbar_helper.dart';
import 'MeetingDetailsPage.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:url_launcher/url_launcher.dart'; // For launchUrl

class MeetingTypesTab extends StatefulWidget {
  @override
  _MeetingTypesTabState createState() => _MeetingTypesTabState();
}

class _MeetingTypesTabState extends State<MeetingTypesTab> {
  List<Map<String, dynamic>> meetings = [];
  bool _isLoading = true;
  bool _hasError = false;

  final TextEditingController _nameController = TextEditingController();
  bool _isGroupMeeting = false;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _fetchMeetingTypes();
  }

  Future<void> _fetchMeetingTypes() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/meeting-types'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
        },
      );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        meetings = data.map((appt) {
          // Convert isGroup from int to bool if needed
          bool isGroup;
          if (appt['isGroup'] is bool) {
            isGroup = appt['isGroup'];
          } else {
            isGroup = appt['isGroup'] == 1; // Convert 1/0 to true/false
          }

          return {
            'title': appt['title'],
            'duration': appt['duration'],
            'type': appt['type'],
            'link': appt['link'],
            'color': Color(int.parse(appt['color'].replaceFirst('#', '0xFF'))),
            'isGroup': isGroup,
            'id': appt['appointment_id'],
          };
        }).toList();
      });
      } else {
        final errorMsg = 'Failed to load meeting types. Status code: ${response.statusCode}';
        print(errorMsg); // Print to terminal
        print('Response body: ${response.body}'); // Print response body for debugging
        throw Exception('Failed to load meeting types');
      }
    } catch (e) {
      print('Error in _fetchMeetingTypes: $e'); // Print to terminal
      setState(() {
        _hasError = true;
      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error loading meeting types: ${e.toString()}')),
      // );
      SnackbarHelper.showError(context, 'Error loading meeting types: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCreateMeetingDialog() {
    _nameController.clear();
    _isGroupMeeting = false;
    _showError = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: EdgeInsets.all(24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Create a meeting type",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      
                      // Body
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          children: [
                            // Image and description
                            Column(
                              children: [
                                Image.asset(
                                  'images/calendar_icon.png',
                                  height: 150,
                                ),
                                SizedBox(height:8),
                                Text(
                                  "Meeting types are the services that people want to schedule you for. They will appear on your scheduling page, and have a direct link you can share.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 24),
                            
                            // Form
                            Form(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Meeting name field
                                  Text(
                                    "Meeting Type Name",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.primaryColor,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                      errorText: _showError ? "Please enter a meeting name" : null,
                                    ),
                                    onChanged: (value) {
                                      setDialogState(() {
                                        _showError = value.isEmpty;
                                      });
                                    },
                                  ),
                                  
                                  // Link preview
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.link,
                                          size: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "appt.link/meet-with-you/${_nameController.text.trim().toLowerCase().replaceAll(' ', '-')}",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(height: 24),
                                  
                                  // Group meeting option
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: _isGroupMeeting,
                                          onChanged: (value) {
                                            setDialogState(() {
                                              _isGroupMeeting = value ?? false;
                                            });
                                          },
                                          activeColor: AppColors.primaryColor,
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.people, size: 24, color: Colors.grey.shade700),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "This is a class or group meeting.",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "Multiple attendees will be able to schedule for the same time slot.",
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(height: 24),
                                  
                                  // Create button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_nameController.text.trim().isEmpty) {
                                          setDialogState(() {
                                            _showError = true;
                                          });
                                        } else {
                                          try {
                                            final response = await http.post(
                                              Uri.parse('${AppConfig.baseUrl}/api/meeting-types'),
                                              headers: {
                                                'Content-Type': 'application/json',
                                                'Authorization': 'Bearer $globalAuthToken',
                                              },
                                              body: json.encode({
                                                'title': _nameController.text.trim(),
                                                'isGroup': _isGroupMeeting,
                                              }),
                                            );

                                            if (response.statusCode == 201) {
                                              await _fetchMeetingTypes();
                                              Navigator.pop(context);
                                            } else {
                                              final errorMsg = 'Failed to create meeting type. Status code: ${response.statusCode}';
                                              print(errorMsg); // Print to terminal
                                              print('Response body: ${response.body}'); // Print response body for debugging
                                              throw Exception('Failed to create meeting type');
                                            }
                                          } catch (e) {
                                            print('Error creating meeting type: $e'); // Print to terminal
                                            // ScaffoldMessenger.of(context).showSnackBar(
                                            //   SnackBar(content: Text('Error creating meeting type: ${e.toString()}')),
                                            // );
                                            SnackbarHelper.showError(context, 'Error creating meeting type: ${e.toString()}');
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      child: Text(
                                        "Create Meeting Type",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteMeetingType(int appointmentId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/meeting-types/$appointmentId'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
        },
      );

      if (response.statusCode == 200) {
        await _fetchMeetingTypes();
      } else {
        final errorMsg = 'Failed to delete meeting type. Status code: ${response.statusCode}';
        print(errorMsg); // Print to terminal
        print('Response body: ${response.body}'); // Print response body for debugging
        throw Exception('Failed to delete meeting type');
      }
    } catch (e) {
        print('Error deleting meeting type: $e'); // Print to terminal
      //   ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error deleting meeting type: ${e.toString()}')),
      // );
      SnackbarHelper.showError(context, 'Error deleting meeting type: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load meeting types'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchMeetingTypes,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 30, left: 16, right: 16, bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showCreateMeetingDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  elevation: 2,
                ),
                icon: Icon(Icons.add, size: 20, color: Colors.white),
                label: Text(
                  "New Meeting Type",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getCrossAxisCount(context),
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: meetings.length,
                itemBuilder: (context, index) {
                  final meeting = meetings[index];
                  return _buildMeetingTypeCard(
                    context,
                    index: index,
                    title: meeting['title'],
                    duration: meeting['duration'],
                    type: meeting['type'],
                    link: meeting['link'],
                    color: meeting['color'],
                    isGroup: meeting['isGroup'],
                    id: meeting['id'],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 4;
    if (width > 1000) return 3;
    if (width > 700) return 2;
    return 1;
  }

  Widget _buildMeetingTypeCard(
    BuildContext context, {
    required int index,
    required String title,
    required String duration,
    required String type,
    required String link,
    required Color color,
    required bool isGroup,
    required int id,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MeetingDetailsPage(
              title: title,
              duration: duration,
              type: type,
              link: link,
              id: id,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.textColorSecond,
                            ),
                            SizedBox(width: 4),
                            Text(duration),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isGroup ? Icons.people : Icons.person,
                              size: 16,
                              color: AppColors.textColorSecond,
                            ),
                            SizedBox(width: 4),
                            Text(type),
                          ],
                        ),
                      ],
                    ),
                   SizedBox(height: 12),
                    Text(
                      link.replaceAll('https://', ''),
                      style: TextStyle(
                        color: AppColors.secondaryColor,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add copy link functionality
                      Clipboard.setData(ClipboardData(text: link));
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text('Link copied to clipboard')),
                      // );
                      SnackbarHelper.showInfo(context, 'Link copied to clipboard');

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link,
                          size: 16,
                          color: Colors.pink,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Copy Link',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          // Add view functionality
                          if (await canLaunch(link)) {
                            await launch(link);
                          } else {
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(content: Text('Could not launch $link')),
                            // );
                            SnackbarHelper.showError(context, 'Could not launch $link');

                          }
                        },
                        icon: Icon(
                          Icons.open_in_new,
                          size: 20,
                          color: AppColors.textColorSecond,
                        ),
                        tooltip: 'View Live Page',
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Meeting Type'),
                                content: Text('Are you sure you want to delete this meeting type?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteMeetingType(id);
                                    },
                                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          } else if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MeetingDetailsPage(
                                  title: title,
                                  duration: duration,
                                  type: type,
                                  link: link,
                                  id: id,
                                ),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20, color: AppColors.textColor),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                        icon: Icon(
                          Icons.more_vert,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'MeetingDetailsPage.dart';

// class MeetingTypesTab extends StatefulWidget {
//   @override
//   _MeetingTypesTabState createState() => _MeetingTypesTabState();
// }

// class _MeetingTypesTabState extends State<MeetingTypesTab> {
//   List<Map<String, dynamic>> meetings = [
//     {
//       'title': 'In-Person Meeting',
//       'duration': '30 minutes',
//       'type': 'One-on-One',
//       'link': 'https://appt.link/in-person-meeting',
//       'color': Color(0xFF0ED70A),
//       'customSchedule': true,
//       'isGroup': false,
//     },
//     {
//       'title': 'Web Conference',
//       'duration': '30 minutes',
//       'type': 'One-on-One',
//       'link': 'https://appt.link/web-conference',
//       'color': Color(0xFF1E9BFF),
//       'customSchedule': false,
//       'isGroup': false,
//     },
//   ];

//   final TextEditingController _nameController = TextEditingController();
//   bool _isGroupMeeting = false;
//   bool _showError = false;

//   void _showCreateMeetingDialog() {
//     _nameController.clear();
//     _isGroupMeeting = false;
//     _showError = false;

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return Dialog(
//               insetPadding: EdgeInsets.all(24),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: SingleChildScrollView(
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 500),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Header
//                       Container(
//                         padding: EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           border: Border(
//                             bottom: BorderSide(
//                               color: Colors.grey.shade300,
//                               width: 1,
//                             ),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 "Create a meeting type",
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.close),
//                               onPressed: () => Navigator.pop(context),
//                             ),
//                           ],
//                         ),
//                       ),
                      
//                       // Body
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                         child: Column(
//                           children: [
//                             // Image and description
//                             Column(
//                               children: [
//                                 Image.asset(
//                                   'images/calendar_icon.png',
//                                   height: 150,
//                                 ),
//                                 SizedBox(height:8),
//                                 Text(
//                                   "Meeting types are the services that people want to schedule you for. They will appear on your scheduling page, and have a direct link you can share.",
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: Colors.grey.shade600,
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                               ],
//                             ),
                            
//                             SizedBox(height: 24),
                            
//                             // Form
//                             Form(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   // Meeting name field
//                                   Text(
//                                     "Meeting Type Name",
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   SizedBox(height: 8),
//                                   TextFormField(
//                                     controller: _nameController,
//                                     decoration: InputDecoration(
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(6),
//                                       ),
//                                       focusedBorder: OutlineInputBorder(
//                                         borderSide: BorderSide(
//                                           color: AppColors.primaryColor,
//                                           width: 2,
//                                         ),
//                                         borderRadius: BorderRadius.circular(6),
//                                       ),
//                                       errorBorder: OutlineInputBorder(
//                                         borderSide: BorderSide(
//                                           color: Colors.red,
//                                           width: 1,
//                                         ),
//                                         borderRadius: BorderRadius.circular(6),
//                                       ),
//                                       contentPadding: EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 14,
//                                       ),
//                                       errorText: _showError ? "Please enter a meeting name" : null,
//                                     ),
//                                     onChanged: (value) {
//                                       setDialogState(() {
//                                         _showError = value.isEmpty;
//                                       });
//                                     },
//                                   ),
                                  
//                                   // Link preview
//                                   Padding(
//                                     padding: EdgeInsets.only(top: 8),
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           Icons.link,
//                                           size: 16,
//                                           color: Colors.grey.shade600,
//                                         ),
//                                         SizedBox(width: 4),
//                                         Text(
//                                           "appt.link/meet-with-you/${_nameController.text.trim().toLowerCase().replaceAll(' ', '-')}",
//                                           style: TextStyle(
//                                             color: Colors.grey.shade600,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
                                  
//                                   SizedBox(height: 24),
                                  
//                                   // Group meeting option
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                         color: Colors.grey.shade300,
//                                       ),
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                     padding: EdgeInsets.all(12),
//                                     child: Row(
//                                       children: [
//                                         Checkbox(
//                                           value: _isGroupMeeting,
//                                           onChanged: (value) {
//                                             setDialogState(() {
//                                               _isGroupMeeting = value ?? false;
//                                             });
//                                           },
//                                           activeColor: AppColors.primaryColor,
//                                         ),
//                                         SizedBox(width: 8),
//                                         Icon(Icons.people, size: 24, color: Colors.grey.shade700),
//                                         SizedBox(width: 12),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 "This is a class or group meeting.",
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                               SizedBox(height: 4),
//                                               Text(
//                                                 "Multiple attendees will be able to schedule for the same time slot.",
//                                                 style: TextStyle(
//                                                   color: Colors.grey.shade600,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
                                  
//                                   SizedBox(height: 24),
                                  
//                                   // Create button
//                                   SizedBox(
//                                     width: double.infinity,
//                                     child: ElevatedButton(
//                                       onPressed: () {
//                                         if (_nameController.text.trim().isEmpty) {
//                                           setDialogState(() {
//                                             _showError = true;
//                                           });
//                                         } else {
//                                           setState(() {  // Using parent's setState here
//                                             meetings.add({
//                                               'title': _nameController.text.trim(),
//                                               'duration': '30 minutes',
//                                               'type': _isGroupMeeting 
//                                                   ? 'Group Meeting' 
//                                                   : 'One-on-One',
//                                               'link': 'https://appt.link/${_nameController.text.trim().toLowerCase().replaceAll(' ', '-')}',
//                                               'color': Color(0xFF1E9BFF),
//                                               'customSchedule': false,
//                                               'isGroup': _isGroupMeeting,
//                                             });
//                                           });
//                                           Navigator.pop(context);
//                                         }
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: AppColors.primaryColor,
//                                         foregroundColor: Colors.white,
//                                         padding: EdgeInsets.symmetric(vertical: 14),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(6),
//                                         ),
//                                       ),
//                                       child: Text(
//                                         "Create Meeting Type",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.only(top: 30, left: 16, right: 16, bottom: 8),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _showCreateMeetingDialog,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryColor,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   elevation: 2,
//                 ),
//                 icon: Icon(Icons.add, size: 20, color: Colors.white),
//                 label: Text(
//                   "New Meeting Type",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: _getCrossAxisCount(context),
//                   childAspectRatio: 1.2,
//                   crossAxisSpacing: 24,
//                   mainAxisSpacing: 24,
//                 ),
//                 itemCount: meetings.length,
//                 itemBuilder: (context, index) {
//                   final meeting = meetings[index];
//                   return _buildMeetingTypeCard(
//                     context,
//                     index: index,
//                     title: meeting['title'],
//                     duration: meeting['duration'],
//                     type: meeting['type'],
//                     link: meeting['link'],
//                     color: meeting['color'],
//                     customSchedule: meeting['customSchedule'],
//                     isGroup: meeting['isGroup'],
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   int _getCrossAxisCount(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     if (width > 1400) return 4;
//     if (width > 1000) return 3;
//     if (width > 700) return 2;
//     return 1;
//   }

//   Widget _buildMeetingTypeCard(
//     BuildContext context, {
//     required int index,
//     required String title,
//     required String duration,
//     required String type,
//     required String link,
//     required Color color,
//     required bool customSchedule,
//     required bool isGroup,
//   }) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => MeetingDetailsPage(
//               title: title,
//               duration: duration,
//               type: type,
//               link: link,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey.shade300),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           width: 16,
//                           height: 16,
//                           decoration: BoxDecoration(
//                             color: color,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                         SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             title,
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 12),
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: [
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.access_time,
//                               size: 16,
//                               color: AppColors.textColorSecond,
//                             ),
//                             SizedBox(width: 4),
//                             Text(duration),
//                           ],
//                         ),
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               isGroup ? Icons.people : Icons.person,
//                               size: 16,
//                               color: AppColors.textColorSecond,
//                             ),
//                             SizedBox(width: 4),
//                             Text(type),
//                           ],
//                         ),
//                       ],
//                     ),
//                     if (customSchedule) ...[
//                       SizedBox(height: 8),
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade200,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           'Custom Schedule',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: AppColors.textColorSecond,
//                           ),
//                         ),
//                       ),
//                     ],
//                     SizedBox(height: 12),
//                     Text(
//                       link.replaceAll('https://', ''),
//                       style: TextStyle(
//                         color: AppColors.secondaryColor,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 border: Border(
//                   top: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       // Add copy link functionality
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: AppColors.textColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       side: BorderSide(color: Colors.grey.shade400),
//                       padding: EdgeInsets.symmetric(horizontal: 12),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.link,
//                           size: 16,
//                           color: AppColors.secondaryColor,
//                         ),
//                         SizedBox(width: 6),
//                         Text(
//                           'Copy Link',
//                           style: TextStyle(fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       IconButton(
//                         onPressed: () {
//                           // Add view functionality
//                         },
//                         icon: Icon(
//                           Icons.open_in_new,
//                           size: 20,
//                           color: AppColors.textColorSecond,
//                         ),
//                         tooltip: 'View Live Page',
//                       ),
//                       PopupMenuButton<String>(
//                         onSelected: (value) {
//                           if (value == 'delete') {
//                             setState(() {
//                               meetings.removeAt(index);
//                             });
//                           } else if (value == 'edit') {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => MeetingDetailsPage(
//                                   title: title,
//                                   duration: duration,
//                                   type: type,
//                                   link: link,
//                                 ),
//                               ),
//                             );
//                           }
//                         },
//                         itemBuilder: (context) => [
//                           PopupMenuItem(
//                             value: 'edit',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.edit, size: 20, color: AppColors.textColor),
//                                 SizedBox(width: 8),
//                                 Text('Edit'),
//                               ],
//                             ),
//                           ),
//                           PopupMenuItem(
//                             value: 'delete',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.delete, size: 20, color: Colors.red),
//                                 SizedBox(width: 8),
//                                 Text('Delete'),
//                               ],
//                             ),
//                           ),
//                         ],
//                         icon: Icon(
//                           Icons.more_vert,
//                           color: AppColors.textColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
