// lib/screens/steps_for_Meetings/step3.dart
import 'package:flutter/material.dart';
import 'step4.dart';
import '../../colors/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/config.dart';
import '../../config/globals.dart';

class ConnectCalendarPage extends StatefulWidget {
  final String accessToken;

  const ConnectCalendarPage({Key? key, required this.accessToken})
    : super(key: key);

  @override
  _ConnectCalendarPageState createState() => _ConnectCalendarPageState();
}

class _ConnectCalendarPageState extends State<ConnectCalendarPage> {
  String _selectedCalendar = " ";
  List<String> _selectedCalendarsForCheck = [" "];
  List<String> _availableCalendars = [" "];

  ////////////
  @override
  void initState() {
    super.initState();
    _fetchCalendarData();
  }

  Future<void> _fetchCalendarData() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/calendar/info'),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _selectedCalendar = data['primaryEmail'];
        _availableCalendars = List<String>.from(data['availableCalendars']);
        _selectedCalendarsForCheck = List<String>.from(
          data['calendarsForCheck'],
        );
      });
    } else {
      print("Failed to fetch calendar info");
    }
  }

  ////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Row(
              children: [
                Image.asset(
                  'images/tabourakNobackground.png',
                  width: 60,
                  height: 60,
                ),
                const Spacer(),
                Text(
                  "Step 3 of 4",
                  style: TextStyle(
                    color: AppColors.textColorSecond,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Title section
                  Column(
                    children: [
                      Text(
                        "Connect Your Calendar",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Ensure that existing events in your calendar block out times on your scheduling page.",
                        style: TextStyle(
                          color: AppColors.textColorSecond,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Connected account card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.textColorSecond.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'images/google_logo.png',
                          width: 48,
                          height: 48,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Connected to Google",
                                style: TextStyle(
                                  color: AppColors.textColorSecond,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _selectedCalendar,
                                style: TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primaryColor,
                          size: 36,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Sync options
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "How should we sync with your calendar?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Add meetings option
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.textColorSecond.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'images/calendar_add.png',
                                  width: 40,
                                  height: 40,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    "Add scheduled meetings to this calendar:",
                                    style: TextStyle(
                                      color: AppColors.textColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.textColorSecond.withOpacity(
                                    0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                underline: const SizedBox(),
                                value: _selectedCalendar,
                                items:
                                    _availableCalendars.map((calendar) {
                                      return DropdownMenuItem(
                                        value: calendar,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(calendar),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCalendar = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Prevent double bookings option
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.textColorSecond.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'images/available_dates.png',
                                  width: 40,
                                  height: 40,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    "Check events in these calendars to prevent double-bookings:",
                                    style: TextStyle(
                                      color: AppColors.textColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Selected calendars chips
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  _selectedCalendarsForCheck.map((calendar) {
                                    return Chip(
                                      backgroundColor:
                                          AppColors.backgroundColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        side: BorderSide(
                                          color: AppColors.textColorSecond
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      label: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              calendar,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),

                                          //  Text(calendar),
                                        ],
                                      ),
                                      deleteIcon: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: AppColors.textColorSecond,
                                      ),
                                      onDeleted: () {
                                        setState(() {
                                          _selectedCalendarsForCheck.remove(
                                            calendar,
                                          );
                                        });
                                      },
                                    );
                                  }).toList(),
                            ),
                            const SizedBox(height: 8),
                            // Add calendar button
                            OutlinedButton(
                              onPressed: () {
                                _showCalendarSelectionDialog(context);
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text("+ Add Calendar"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Next button and footer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SchedulingPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    "Next: Your Information →",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Privacy Policy | Terms & Conditions",
                  style: TextStyle(
                    color: AppColors.textColorSecond,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "© 2025 Tabourak",
                  style: TextStyle(
                    color: AppColors.textColorSecond,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCalendarSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Calendars"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableCalendars.length,
              itemBuilder: (context, index) {
                final calendar = _availableCalendars[index];
                return CheckboxListTile(
                  title: Text(calendar),
                  value: _selectedCalendarsForCheck.contains(calendar),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        if (!_selectedCalendarsForCheck.contains(calendar)) {
                          _selectedCalendarsForCheck.add(calendar);
                        }
                      } else {
                        _selectedCalendarsForCheck.remove(calendar);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
  }
}
// import 'package:flutter/material.dart';
// import 'step4.dart';
// import '../../colors/app_colors.dart';

// class ConnectCalendarPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 50),
//             Row(
//               children: [
//                 Icon(Icons.calendar_today, color: AppColors.primaryColor),
//                 SizedBox(width: 10),
//                 Text(
//                   "Connect Your Calendar",
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//             Text("Ensure that existing events in your calendar block out times on your scheduling page."),
//             SizedBox(height: 20),
//             Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: AppColors.backgroundColor,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
//               ),
//               child: Row(
//                 children: [
                
                
//                   SizedBox(width: 10),
//                   Expanded(child: Text("Connected to Google\ns12113539@stu.najah.edu")),
//                   Icon(Icons.check_circle, color:AppColors.primaryColor),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             Text("How should we sync with your calendar?", style: TextStyle(fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             _buildDropdown("Add scheduled meetings to this calendar"),
//             SizedBox(height: 10),
//             _buildDropdown("Check events in these calendars to prevent double-bookings"),
//             Spacer(),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:AppColors.primaryColor,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 padding: EdgeInsets.symmetric(vertical: 15),
//               ),
//               onPressed: () {
//                   Navigator.push(
//                     context,
//                     PageRouteBuilder(
//                       transitionDuration: Duration(milliseconds: 500),
//                       pageBuilder: (_, __, ___) => SchedulingPage(),
//                       transitionsBuilder: (_, animation, __, child) {
//                         return SlideTransition(
//                           position: Tween<Offset>(
//                             begin: Offset(1, 0),
//                             end: Offset(0, 0),
//                           ).animate(animation),
//                           child: child,
//                         );
//                       },
//                     ),
//                   );
//                 },
//               child: Center(child: Text("Next: Your Information →", style: TextStyle(fontSize: 16, color:AppColors.backgroundColor))),
//             ),
//             SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown(String title) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
//         SizedBox(height: 5),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 10),
//           decoration: BoxDecoration(
//             color: AppColors.backgroundColor,
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
//           ),
//           child: DropdownButton<String>(
//             isExpanded: true,
//             underline: SizedBox(),
//             value: "s12113539@stu.najah.edu",
//             items: [
//               DropdownMenuItem(value: "s12113539@stu.najah.edu", child: Text("s12113539@stu.najah.edu")),
//             ],
//             onChanged: (value) {},
//           ),
//         ),
//       ],
//     );
//   }

// }

