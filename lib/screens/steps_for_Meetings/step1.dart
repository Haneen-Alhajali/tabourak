// lib\screens\steps_for_Meetings\step1.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'step2.dart';
import '../../colors/app_colors.dart';
import '../../config/config.dart';
import '../../config/globals.dart';

class AppointmentSetupScreen extends StatefulWidget {
  const AppointmentSetupScreen({Key? key}) : super(key: key);

  @override
  _AppointmentSetupScreenState createState() => _AppointmentSetupScreenState();
}

class _AppointmentSetupScreenState extends State<AppointmentSetupScreen> {
  List<bool> isSelected = [true, true, false];
  bool _isLoading = false;
  bool _hasExistingPreferences = false;
  List<dynamic>? _existingAppointments;

  bool get _isAtLeastOneSelected {
    return isSelected.contains(true);
  }

  @override
  void initState() {
    super.initState();
    _checkExistingPreferences();
  }

  Future<void> _checkExistingPreferences() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/appointments'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          setState(() {
            _hasExistingPreferences = true;
            _existingAppointments = data;
            // Update selections based on existing data
            isSelected = [
              data.any((appt) => appt['meeting_type'] == 'in_person' && appt['is_active']),
              data.any((appt) => appt['meeting_type'] == 'video_call' && appt['is_active']),
              data.any((appt) => appt['meeting_type'] == 'phone_call' && appt['is_active']),
            ];
          });
        }
      }
    } catch (e) {
      print('Error checking existing preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isLoading = true);

    try {
      final payload = {
        'appointments': [
          if (isSelected[0])
            {
              'name': 'In-Person Meeting',
              'meeting_type': 'in_person',
              'duration_minutes': 60,
            },
          if (isSelected[1])
            {
              'name': 'Web Conference',
              'meeting_type': 'video_call',
              'duration_minutes': 60,
            },
          if (isSelected[2])
            {
              'name': 'Phone Call',
              'meeting_type': 'phone_call',
              'duration_minutes': 30,
            }
        ]
      };

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/appointments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $globalAuthToken',
        },
        body: json.encode(payload),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AvailabilityScreen(),
          ),
        );
      } else {
        final error = json.decode(response.body)['error'] ?? 'Failed to save preferences';
        throw Exception(error);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Header with logo and step indicator
          Positioned(
            top: 60,
            left: 20,
            child: Image.asset(
              'images/tabourakNobackground.png',
              width: 60,
              height: 60,
            ),
          ),
          Positioned(
            top: 80,
            right: 20,
            child: Text(
              "Step 1 of 4",
              style: TextStyle(
                color: AppColors.textColorSecond,
                fontSize: 15,
              ),
            ),
          ),

          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80), // Space for header
                  Text(
                    "How do your appointments take place?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Let's start setting up your scheduling page.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textColorSecond,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildOption(0, Icons.home, "In-Person Meeting"),
                  _buildOption(1, Icons.video_call, "Video Conference"),
                  _buildOption(2, Icons.phone, "Phone Call"),

                  const SizedBox(height: 30),

                  if (!_isAtLeastOneSelected)
                    Text(
                      "Please select at least one appointment type",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: (_isLoading || !_isAtLeastOneSelected) 
                        ? null 
                        : _savePreferences,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAtLeastOneSelected
                          ? AppColors.primaryColor
                          : Colors.grey,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: AppColors.backgroundColor)
                        : Text(
                            "Next: Availability →",
                            style: TextStyle(
                              color: AppColors.backgroundColor,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),

          // Footer fixed at bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
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

  Widget _buildOption(int index, IconData icon, String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected[index] = !isSelected[index];
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected[index] ? AppColors.primaryColor : AppColors.textColorSecond,
          ),
          color: isSelected[index] ? AppColors.lightcolor : AppColors.backgroundColor,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected[index] ? AppColors.primaryColor : AppColors.textColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected[index])
              Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'step2.dart';
// import '../../colors/app_colors.dart';
// import '../../config/config.dart';
// import '../../config/globals.dart';

// class AppointmentSetupScreen extends StatefulWidget {

//   const AppointmentSetupScreen({Key? key}) : super(key: key);

//   @override
//   _AppointmentSetupScreenState createState() => _AppointmentSetupScreenState();
// }

// class _AppointmentSetupScreenState extends State<AppointmentSetupScreen> {
//   List<bool> isSelected = [true, true, false];
//   bool _isLoading = false;
//   bool _hasExistingPreferences = false;
//   List<dynamic>? _existingTypes;

//   @override
//   void initState() {
//     super.initState();
//     _checkExistingPreferences();
//   }

//   Future<void> _checkExistingPreferences() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/appointments/types'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data is List && data.isNotEmpty) {
//           setState(() {
//             _hasExistingPreferences = true;
//             _existingTypes = data;
//             // Update selections based on existing data
//             isSelected = [
//               data.any((type) => type['meeting_type'] == 'in_person' && type['is_active']),
//               data.any((type) => type['meeting_type'] == 'video_call' && type['is_active']),
//               data.any((type) => type['meeting_type'] == 'phone_call' && type['is_active']),
//             ];
//           });
//         }
//       }
//     } catch (e) {
//       print('Error checking existing preferences: $e');
//     }
//   }

//   Future<void> _savePreferences() async {
//     setState(() => _isLoading = true);

//     try {
//       final payload = {
//         'types': [
//           {
//             'type_id': _hasExistingPreferences 
//               ? _existingTypes?.firstWhere(
//                   (type) => type['meeting_type'] == 'in_person',
//                   orElse: () => {'type_id': null})['type_id']
//               : null,
//             'name': 'At a place',
//             'meeting_type': 'in_person',
//             'duration': 60,
//             'is_active': isSelected[0],
//             'color_hex': '#3B82F6',
//           },
//           {
//             'type_id': _hasExistingPreferences 
//               ? _existingTypes?.firstWhere(
//                   (type) => type['meeting_type'] == 'video_call',
//                   orElse: () => {'type_id': null})['type_id']
//               : null,
//             'name': 'Web conference',
//             'meeting_type': 'video_call',
//             'duration': 60,
//             'is_active': isSelected[1],
//             'color_hex': '#10B981',
//           },
//           {
//             'type_id': _hasExistingPreferences 
//               ? _existingTypes?.firstWhere(
//                   (type) => type['meeting_type'] == 'phone_call',
//                   orElse: () => {'type_id': null})['type_id']
//               : null,
//             'name': 'Phone call',
//             'meeting_type': 'phone_call',
//             'duration': 30,
//             'is_active': isSelected[2],
//             'color_hex': '#F59E0B',
//           }
//         ]
//       };

//       final response = await (_hasExistingPreferences 
//           ? http.put(
//               Uri.parse('${AppConfig.baseUrl}/api/appointments/preferences'),
//               headers: {
//                 'Content-Type': 'application/json',
//                 'Authorization': 'Bearer $globalAuthToken',
//               },
//               body: json.encode(payload),
//             )
//           : http.post(
//               Uri.parse('${AppConfig.baseUrl}/api/appointments/preferences'),
//               headers: {
//                 'Content-Type': 'application/json',
//                 'Authorization': 'Bearer $globalAuthToken',
//               },
//               body: json.encode(payload),
//             ));

//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => AvailabilityScreen(),
//           ),
//         );
//       } else {
//         final error = json.decode(response.body)['error'] ?? 'Failed to save preferences';
//         throw Exception(error);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       body: Stack(
//         children: [
//           // Header with logo and step indicator
//           Positioned(
//             top: 60,
//             left: 20,
//             child: Image.asset(
//               'images/tabourakNobackground.png',
//               width: 60,
//               height: 60,
//             ),
//           ),
//           Positioned(
//             top: 80,
//             right: 20,
//             child: Text(
//               "Step 1 of 4",
//               style: TextStyle(
//                 color: AppColors.textColorSecond,
//                 fontSize: 15,
//               ),
//             ),
//           ),

//           // Main content
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 80), // Space for header
//                   Text(
//                     "How do your appointments take place?",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textColor,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Let's start setting up your scheduling page.",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: AppColors.textColorSecond,
//                       fontSize: 14,
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   _buildOption(0, Icons.home, "At a place"),
//                   _buildOption(1, Icons.video_call, "Web conference"),
//                   _buildOption(2, Icons.phone, "Phone call"),

//                   const SizedBox(height: 30),

//                   ElevatedButton(
//                     onPressed: _isLoading ? null : _savePreferences,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryColor,
//                       minimumSize: const Size(double.infinity, 50),
//                     ),
//                     child: _isLoading
//                         ? CircularProgressIndicator(color: AppColors.backgroundColor)
//                         : Text(
//                             "Next: Availability →",
//                             style: TextStyle(
//                               color: AppColors.backgroundColor,
//                               fontSize: 16,
//                             ),
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Footer fixed at bottom
//           Positioned(
//             bottom: 20,
//             left: 0,
//             right: 0,
//             child: Column(
//               children: [
//                 Text(
//                   "Privacy Policy | Terms & Conditions",
//                   style: TextStyle(
//                     color: AppColors.textColorSecond,
//                     fontSize: 12,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "© 2025 Tabourak",
//                   style: TextStyle(
//                     color: AppColors.textColorSecond,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOption(int index, IconData icon, String text) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           isSelected[index] = !isSelected[index];
//         });
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 6),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: isSelected[index] ? AppColors.primaryColor : AppColors.textColorSecond,
//           ),
//           color: isSelected[index] ? AppColors.lightcolor : AppColors.backgroundColor,
//         ),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: isSelected[index] ? AppColors.primaryColor : AppColors.textColor,
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 text,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             if (isSelected[index])
//               Icon(
//                 Icons.check_circle,
//                 color: AppColors.primaryColor,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }