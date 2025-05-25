// lib\content\availability&calender\schedulesTab\schedule_manager_section.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/config/config.dart';
import 'package:tabourak/config/globals.dart';
import 'package:tabourak/config/snackbar_helper.dart';
import 'package:tabourak/content/availability&calender/schedulesTab/create_schedule_modal.dart';
import 'package:tabourak/content/availability&calender/schedulesTab/edit_schedule_modal.dart';
import 'package:tabourak/models/time_range.dart';

class ScheduleManagerSection extends StatefulWidget {
  final Function(Map<String, dynamic>, Map<String, List<TimeRange>>)? onScheduleSelected;
  
  const ScheduleManagerSection({
    Key? key,
    this.onScheduleSelected,
  }) : super(key: key);

  @override
  State<ScheduleManagerSection> createState() => _ScheduleManagerSectionState();
}

class _ScheduleManagerSectionState extends State<ScheduleManagerSection> {
  List<Map<String, dynamic>> _schedules = [];
  Map<String, dynamic>? _selectedSchedule;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    final currentSelectedId = _selectedSchedule?['id'];
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/schedules'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _schedules = List<Map<String, dynamic>>.from(data.map((schedule) {
            if (schedule['isDefault'] is int) {
              schedule['isDefault'] = schedule['isDefault'] == 1;
            }
            return schedule;
          }));
          
          if (_schedules.isNotEmpty) {
            if (currentSelectedId != null) {
              _selectedSchedule = _schedules.firstWhere(
                (s) => s['id'] == currentSelectedId,
                orElse: () => _schedules.firstWhere(
                  (s) => s['isDefault'] == true,
                  orElse: () => _schedules.first,
                ),
              );
            } else {
              _selectedSchedule = _schedules.firstWhere(
                (s) => s['isDefault'] == true,
                orElse: () => _schedules.first,
              );
            }
            
            // Fetch availability for the selected schedule
            if (widget.onScheduleSelected != null) {
              _fetchAvailabilityForSchedule(_selectedSchedule!['id'].toString());
            }
          }
        });
      } else {
        debugPrint('Failed to load schedules. Status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Failed to load schedules');
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching schedules: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _error = 'Failed to load schedules. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailabilityForSchedule(String scheduleId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/availability/for-schedule?scheduleId=$scheduleId'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final availability = <String, List<TimeRange>>{};
        
        for (final entry in data['availability'].entries) {
          final day = entry.key;
          final slots = entry.value as List;
          
          availability[day] = slots.map((slot) {
            return TimeRange(
              TimeOfDay(hour: slot['start']['hour'], minute: slot['start']['minute']),
              TimeOfDay(hour: slot['end']['hour'], minute: slot['end']['minute']),
            );
          }).toList();
        }
        
        if (widget.onScheduleSelected != null) {
          widget.onScheduleSelected!(_selectedSchedule!, availability);
        }
      } else {
        throw Exception('Failed to load availability');
      }
    } catch (e) {
      debugPrint('Error fetching availability: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to load availability for schedule')),
      // );
      SnackbarHelper.showError(context, 'Failed to load availability for schedule');
    }
  }

  // void _handleScheduleSelected(Map<String, dynamic>? schedule) async {
  //   if (schedule == null) return;
    
  //   try {
  //     await _fetchAvailabilityForSchedule(schedule['id'].toString());
  //     setState(() {
  //       _selectedSchedule = schedule;
  //     });
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to load availability for schedule')),
  //     );
  //   }
  // }
void _handleScheduleSelected(Map<String, dynamic>? schedule) async {
  if (schedule == null || schedule['id'] == null) return;
  
  try {
    await _fetchAvailabilityForSchedule(schedule['id'].toString());
    setState(() {
      _selectedSchedule = schedule;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load availability for schedule: ${e.toString()}')),
    );
  }
}
  Future<void> _createSchedule(Map<String, dynamic> scheduleData) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/schedules'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(scheduleData),
      );

      if (response.statusCode == 201) {
        await _fetchSchedules();
      } else {
        debugPrint('Failed to create schedule. Status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Failed to create schedule');
      }
    } catch (e, stackTrace) {
      debugPrint('Error creating schedule: $e');
      debugPrint('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create schedule. Please try again.')),
      );
    }
  }

  Future<void> _updateSchedule(String id, Map<String, dynamic> scheduleData) async {
    final currentSelectedId = _selectedSchedule?['id'];
    
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/schedules/$id'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(scheduleData),
      );

      if (response.statusCode == 200) {
        await _fetchSchedules();
        if (currentSelectedId != null) {
          setState(() {
            _selectedSchedule = _schedules.firstWhere(
              (s) => s['id'] == currentSelectedId,
              orElse: () => _schedules.firstWhere(
                (s) => s['isDefault'] == true,
                orElse: () => _schedules.first,
              ),
            );
          });
        }
      } else {
        debugPrint('Failed to update schedule. Status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Failed to update schedule');
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating schedule: $e');
      debugPrint('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update schedule. Please try again.')),
      );
    }
  }

  Future<void> _deleteSchedule(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/schedules/$id'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
        },
      );

      if (response.statusCode == 200) {
        await _fetchSchedules();
      } else {
        debugPrint('Failed to delete schedule. Status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Failed to delete schedule');
      }
    } catch (e, stackTrace) {
      debugPrint('Error deleting schedule: $e');
      debugPrint('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete schedule. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule Manager',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Define the times you are available to be scheduled for meetings.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textColorSecond,
          ),
        ),
        const SizedBox(height: 24),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'MY SCHEDULES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorSecond,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline, size: 16),
                  color: AppColors.textColorSecond,
                  onPressed: () {},
                ),
              ],
            ),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Schedule'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => CreateScheduleModal(
                    timezones: const [],
                  ),
                ).then((result) {
                  if (result != null) {
                    _createSchedule({
                      'name': result['name'],
                      'timezone': result['timezone'],
                      'isDefault': result['isDefault'],
                    });
                  }
                });
              },
            ),
          ],
        ),
        
        if (!isDesktop) Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedSchedule,
                items: _schedules.map((schedule) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: schedule,
                    child: Row(
                      children: [
                        Text(
                          schedule['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        if (schedule['isDefault'] == true) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(default)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
                onChanged: _handleScheduleSelected,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                style: const TextStyle(fontSize: 14, color: Colors.black),
                dropdownColor: Colors.white,
                hint: const Text('Select a schedule'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 22),
              color: AppColors.textColorSecond,
              onPressed: _selectedSchedule != null ? () {
                showDialog(
                  context: context,
                  builder: (context) => EditScheduleModal(
                    scheduleId: _selectedSchedule!['id'].toString(),
                    initialName: _selectedSchedule!['name'],
                    initialTimezone: _selectedSchedule!['timezone'],
                    isDefault: _selectedSchedule!['isDefault'],
                    onUpdate: _updateSchedule,
                    onDelete: _deleteSchedule,
                  ),
                );
              } : null,
            ),
          ],
        ),
        
        if (isDesktop) Column(
          children: [
            if (_schedules.isNotEmpty) ...[
              for (var schedule in _schedules)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: schedule['isDefault'] 
                        ? AppColors.primaryColor 
                        : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      if (schedule['isDefault'])
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (schedule['isDefault'])
                              const Text(
                                'DEFAULT',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorSecond,
                                ),
                              ),
                            if (schedule['isDefault']) const SizedBox(height: 4),
                            Text(
                              schedule['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        color: AppColors.textColorSecond,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => EditScheduleModal(
                              scheduleId: schedule['id'].toString(),
                              initialName: schedule['name'],
                              initialTimezone: schedule['timezone'],
                              isDefault: schedule['isDefault'],
                              onUpdate: _updateSchedule,
                              onDelete: _deleteSchedule,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ] else
              const Text('No schedules found'),
          ],
        ),
        
        // if (_selectedSchedule != null)
        //   Text(
        //     'Times are in ${_selectedSchedule!['timezone']}',
        //     style: TextStyle(
        //       fontSize: 14,
        //       color: Colors.grey[600],
        //     ),
        //   ),
        // const SizedBox(height: 16),
        if (_selectedSchedule != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0), // Adjust this value as needed
            child: Text(
              'Times are in ${_selectedSchedule!['timezone']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        const SizedBox(height: 16),
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // TextButton.icon(
                //   icon: const Icon(Icons.auto_awesome, size: 16),
                //   label: const Text('Generate Availability with AI'),
                //   style: TextButton.styleFrom(
                //     foregroundColor: AppColors.primaryColor,
                //   ),
                //   onPressed: () {},
                // ),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                //   decoration: BoxDecoration(
                //     color: Colors.pink,
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: const Text(
                //     'Beta',
                //     style: TextStyle(
                //       color: Colors.white,
                //       fontSize: 12,
                //     ),
                //   ),
                // ),
              ],
            ),
            TextButton.icon(
              icon: const Icon(Icons.help_outline, size: 16),
              label: const Text('I need help setting up my schedule'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}






//edit


// // lib\content\availability&calender\schedulesTab\schedule_manager_section.dart
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/config/config.dart';
// import 'package:tabourak/config/globals.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/create_schedule_modal.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/edit_schedule_modal.dart';

// class ScheduleManagerSection extends StatefulWidget {
//   const ScheduleManagerSection({Key? key}) : super(key: key);

//   @override
//   State<ScheduleManagerSection> createState() => _ScheduleManagerSectionState();
// }

// class _ScheduleManagerSectionState extends State<ScheduleManagerSection> {
//   List<Map<String, dynamic>> _schedules = [];
//   Map<String, dynamic>? _selectedSchedule;
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSchedules();
//   }

//   Future<void> _fetchSchedules() async {
//     // Store the current selected schedule ID before fetching
//     final currentSelectedId = _selectedSchedule?['id'];
    
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/schedules'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           _schedules = List<Map<String, dynamic>>.from(data.map((schedule) {
//             // Convert isDefault from int to bool if needed
//             if (schedule['isDefault'] is int) {
//               schedule['isDefault'] = schedule['isDefault'] == 1;
//             }
//             return schedule;
//           }));
          
//           if (_schedules.isNotEmpty) {
//             // Try to maintain the current selection if it exists
//             if (currentSelectedId != null) {
//               _selectedSchedule = _schedules.firstWhere(
//                 (s) => s['id'] == currentSelectedId,
//                 orElse: () => _schedules.firstWhere(
//                   (s) => s['isDefault'] == true,
//                   orElse: () => _schedules.first,
//                 ),
//               );
//             } else {
//               _selectedSchedule = _schedules.firstWhere(
//                 (s) => s['isDefault'] == true,
//                 orElse: () => _schedules.first,
//               );
//             }
//           }
//         });
//       } else {
//         debugPrint('Failed to load schedules. Status: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         throw Exception('Failed to load schedules');
//       }
//     } catch (e, stackTrace) {
//       debugPrint('Error fetching schedules: $e');
//       debugPrint('Stack trace: $stackTrace');
//       setState(() {
//         _error = 'Failed to load schedules. Please try again.';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _createSchedule(Map<String, dynamic> scheduleData) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/schedules'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode(scheduleData),
//       );

//       if (response.statusCode == 201) {
//         await _fetchSchedules();
//       } else {
//         debugPrint('Failed to create schedule. Status: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         throw Exception('Failed to create schedule');
//       }
//     } catch (e, stackTrace) {
//       debugPrint('Error creating schedule: $e');
//       debugPrint('Stack trace: $stackTrace');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to create schedule. Please try again.')),
//       );
//     }
//   }

//   Future<void> _updateSchedule(String id, Map<String, dynamic> scheduleData) async {
//     // Store the current selected schedule ID before updating
//     final currentSelectedId = _selectedSchedule?['id'];
    
//     try {
//       final response = await http.put(
//         Uri.parse('${AppConfig.baseUrl}/api/schedules/$id'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode(scheduleData),
//       );

//       if (response.statusCode == 200) {
//         await _fetchSchedules();
//         // After fetching, try to restore the selected schedule
//         if (currentSelectedId != null) {
//           setState(() {
//             _selectedSchedule = _schedules.firstWhere(
//               (s) => s['id'] == currentSelectedId,
//               orElse: () => _schedules.firstWhere(
//                 (s) => s['isDefault'] == true,
//                 orElse: () => _schedules.first,
//               ),
//             );
//           });
//         }
//       } else {
//         debugPrint('Failed to update schedule. Status: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         throw Exception('Failed to update schedule');
//       }
//     } catch (e, stackTrace) {
//       debugPrint('Error updating schedule: $e');
//       debugPrint('Stack trace: $stackTrace');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update schedule. Please try again.')),
//       );
//     }
//   }

//   Future<void> _deleteSchedule(String id) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('${AppConfig.baseUrl}/api/schedules/$id'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         await _fetchSchedules();
//       } else {
//         debugPrint('Failed to delete schedule. Status: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         throw Exception('Failed to delete schedule');
//       }
//     } catch (e, stackTrace) {
//       debugPrint('Error deleting schedule: $e');
//       debugPrint('Stack trace: $stackTrace');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete schedule. Please try again.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width >= 1024;

//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_error != null) {
//       return Center(child: Text(_error!));
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Schedule Manager',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         const Text(
//           'Define the times you are available to be scheduled for meetings.',
//           style: TextStyle(
//             fontSize: 14,
//             color: AppColors.textColorSecond,
//           ),
//         ),
//         const SizedBox(height: 24),
        
//         // Header with Add Schedule button
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'MY SCHEDULES',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textColorSecond,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.help_outline, size: 16),
//                   color: AppColors.textColorSecond,
//                   onPressed: () {},
//                 ),
//               ],
//             ),
//             TextButton.icon(
//               icon: const Icon(Icons.add, size: 16),
//               label: const Text('Add Schedule'),
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.primaryColor,
//               ),
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => CreateScheduleModal(
//                     timezones: const [], // Will be loaded in the modal
//                   ),
//                 ).then((result) {
//                   if (result != null) {
//                     _createSchedule({
//                       'name': result['name'],
//                       'timezone': result['timezone'],
//                       'isDefault': result['isDefault'],
//                     });
//                   }
//                 });
//               },
//             ),
//           ],
//         ),
        
//         // Mobile view - Dropdown with edit button
//         // if (!isDesktop) Row(
//         //   children: [
//         //     Expanded(
//         //       child: DropdownButtonFormField<Map<String, dynamic>>(
//         //         value: _selectedSchedule,
//         //         items: _schedules.map((schedule) {
//         //           return DropdownMenuItem<Map<String, dynamic>>(
//         //             value: schedule,
//         //             child: Text(
//         //               schedule['name'],
//         //               style: const TextStyle(
//         //                 fontSize: 14,
//         //                 color: Colors.black,
//         //               ),
//         //             ),
//         //           );
//         //         }).toList(),
//         //         onChanged: (newValue) {
//         //           setState(() {
//         //             _selectedSchedule = newValue;
//         //           });
//         //         },
//         //         decoration: InputDecoration(
//         //           filled: true,
//         //           fillColor: Colors.white,
//         //           border: OutlineInputBorder(
//         //             borderRadius: BorderRadius.circular(4),
//         //             borderSide: BorderSide(color: Colors.grey.shade300),
//         //           ),
//         //           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//         //         ),
//         //         icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
//         //         style: const TextStyle(fontSize: 14, color: Colors.black),
//         //         dropdownColor: Colors.white,
//         //         hint: const Text('Select a schedule'),
//         //       ),
//         //     ),
//         //     const SizedBox(width: 8),
//         //     IconButton(
//         //       icon: const Icon(Icons.edit_outlined, size: 22),
//         //       color: AppColors.textColorSecond,
//         //       onPressed: _selectedSchedule != null ? () {
//         //         showDialog(
//         //           context: context,
//         //           builder: (context) => EditScheduleModal(
//         //             scheduleId: _selectedSchedule!['id'].toString(),
//         //             initialName: _selectedSchedule!['name'],
//         //             initialTimezone: _selectedSchedule!['timezone'],
//         //             isDefault: _selectedSchedule!['isDefault'],
//         //             onUpdate: _updateSchedule,
//         //             onDelete: _deleteSchedule,
//         //           ),
//         //         );
//         //       } : null,
//         //     ),
//         //   ],
//         // ),
// // Mobile view - Dropdown with edit button
// if (!isDesktop) Row(
//   children: [
//     Expanded(
//       child: DropdownButtonFormField<Map<String, dynamic>>(
//         value: _selectedSchedule,
//         items: _schedules.map((schedule) {
//           return DropdownMenuItem<Map<String, dynamic>>(
//             value: schedule,
//             child: Row(
//               children: [
//                 Text(
//                   schedule['name'],
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black,
//                   ),
//                 ),
//                 if (schedule['isDefault'] == true) ...[
//                   const SizedBox(width: 4),
//                   Text(
//                     '(default)',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: AppColors.primaryColor,
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           );
//         }).toList(),
//         onChanged: (newValue) {
//           setState(() {
//             _selectedSchedule = newValue;
//           });
//         },
//         decoration: InputDecoration(
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(4),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//         ),
//         icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
//         style: const TextStyle(fontSize: 14, color: Colors.black),
//         dropdownColor: Colors.white,
//         hint: const Text('Select a schedule'),
//       ),
//     ),
//     const SizedBox(width: 8),
//     IconButton(
//       icon: const Icon(Icons.edit_outlined, size: 22),
//       color: AppColors.textColorSecond,
//       onPressed: _selectedSchedule != null ? () {
//         showDialog(
//           context: context,
//           builder: (context) => EditScheduleModal(
//             scheduleId: _selectedSchedule!['id'].toString(),
//             initialName: _selectedSchedule!['name'],
//             initialTimezone: _selectedSchedule!['timezone'],
//             isDefault: _selectedSchedule!['isDefault'],
//             onUpdate: _updateSchedule,
//             onDelete: _deleteSchedule,
//           ),
//         );
//       } : null,
//     ),
//   ],
// ),        
//         // Desktop view - Schedule list
//         if (isDesktop) Column(
//           children: [
//             if (_schedules.isNotEmpty) ...[
//               for (var schedule in _schedules)
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   margin: const EdgeInsets.only(bottom: 8),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: schedule['isDefault'] 
//                         ? AppColors.primaryColor 
//                         : Colors.grey.shade300,
//                     ),
//                     borderRadius: BorderRadius.circular(8),
//                     boxShadow: [
//                       if (schedule['isDefault'])
//                         BoxShadow(
//                           color: AppColors.primaryColor.withOpacity(0.1),
//                           blurRadius: 4,
//                           spreadRadius: 1,
//                         ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if (schedule['isDefault'])
//                               const Text(
//                                 'DEFAULT',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.textColorSecond,
//                                 ),
//                               ),
//                             if (schedule['isDefault']) const SizedBox(height: 4),
//                             Text(
//                               schedule['name'],
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.edit_outlined),
//                         color: AppColors.textColorSecond,
//                         onPressed: () {
//                           showDialog(
//                             context: context,
//                             builder: (context) => EditScheduleModal(
//                               scheduleId: schedule['id'].toString(),
//                               initialName: schedule['name'],
//                               initialTimezone: schedule['timezone'],
//                               isDefault: schedule['isDefault'],
//                               onUpdate: _updateSchedule,
//                               onDelete: _deleteSchedule,
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//             ] else
//               const Text('No schedules found'),
//           ],
//         ),
        
//         // Timezone information
//         if (_selectedSchedule != null)
//           Text(
//             'Times are in ${_selectedSchedule!['timezone']}',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//         const SizedBox(height: 16),
        
//         // AI and Help buttons
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 TextButton.icon(
//                   icon: const Icon(Icons.auto_awesome, size: 16),
//                   label: const Text('Generate Availability with AI'),
//                   style: TextButton.styleFrom(
//                     foregroundColor: AppColors.primaryColor,
//                   ),
//                   onPressed: () {},
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: Colors.pink,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Text(
//                     'Beta',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             TextButton.icon(
//               icon: const Icon(Icons.help_outline, size: 16),
//               label: const Text('I need help setting up my schedule'),
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.primaryColor,
//               ),
//               onPressed: () {},
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }






// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/config/config.dart';
// import 'package:tabourak/config/globals.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/create_schedule_modal.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/edit_schedule_modal.dart';

// class ScheduleManagerSection extends StatefulWidget {
//   const ScheduleManagerSection({Key? key}) : super(key: key);

//   @override
//   State<ScheduleManagerSection> createState() => _ScheduleManagerSectionState();
// }

// class _ScheduleManagerSectionState extends State<ScheduleManagerSection> {
//   List<Map<String, dynamic>> _schedules = [];
//   Map<String, dynamic>? _selectedSchedule;
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSchedules();
//   }

//   Future<void> _fetchSchedules() async {
//     // Store the current selected schedule ID before fetching
//     final currentSelectedId = _selectedSchedule?['id'];
    
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/schedules'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           _schedules = List<Map<String, dynamic>>.from(data.map((schedule) {
//             // Convert isDefault from int to bool if needed
//             if (schedule['isDefault'] is int) {
//               schedule['isDefault'] = schedule['isDefault'] == 1;
//             }
//             return schedule;
//           }));
          
//           if (_schedules.isNotEmpty) {
//             // Try to maintain the current selection if it exists
//             if (currentSelectedId != null) {
//               _selectedSchedule = _schedules.firstWhere(
//                 (s) => s['id'] == currentSelectedId,
//                 orElse: () => _schedules.firstWhere(
//                   (s) => s['isDefault'] == true,
//                   orElse: () => _schedules.first,
//                 ),
//               );
//             } else {
//               _selectedSchedule = _schedules.firstWhere(
//                 (s) => s['isDefault'] == true,
//                 orElse: () => _schedules.first,
//               );
//             }
//           }
//         });
//       } else {
//         debugPrint('Failed to load schedules. Status: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         throw Exception('Failed to load schedules');
//       }
//     } catch (e, stackTrace) {
//       debugPrint('Error fetching schedules: $e');
//       debugPrint('Stack trace: $stackTrace');
//       setState(() {
//         _error = 'Failed to load schedules. Please try again.';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _createSchedule(Map<String, dynamic> scheduleData) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/schedules'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode(scheduleData),
//       );

//       if (response.statusCode == 201) {
//         await _fetchSchedules();
//       } else {
//         debugPrint('Failed to create schedule. Status: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         throw Exception('Failed to create schedule');
//       }
//     } catch (e, stackTrace) {
//       debugPrint('Error creating schedule: $e');
//       debugPrint('Stack trace: $stackTrace');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to create schedule. Please try again.')),
//       );
//     }
//   }

//   Future<void> _updateSchedule(String id, Map<String, dynamic> scheduleData) async {
//     // Store the current selected schedule ID before updating
//     final currentSelectedId = _selectedSchedule?['id'];
    
//     try {
//       final response = await http.put(
//         Uri.parse('${AppConfig.baseUrl}/api/schedules/$id'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode(scheduleData),
//       );

//       if (response.statusCode == 200) {
//         await _fetchSchedules();
//         // After fetching, try to restore the selected schedule
//         if (currentSelectedId != null) {
//           setState(() {
//             _selectedSchedule = _schedules.firstWhere(
//               (s) => s['id'] == currentSelectedId,
//               orElse: () => _schedules.firstWhere(
//                 (s) => s['isDefault'] == true,
//                 orElse: () => _schedules.first,
//               ),
//             );
//           });
//         }
//       } else {
//         debugPrint('Failed to update schedule. Status: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         throw Exception('Failed to update schedule');
//       }
//     } catch (e, stackTrace) {
//       debugPrint('Error updating schedule: $e');
//       debugPrint('Stack trace: $stackTrace');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update schedule. Please try again.')),
//       );
//     }
//   }

//   Future<void> _deleteSchedule(String id) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('${AppConfig.baseUrl}/api/schedules/$id'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         await _fetchSchedules();
//       } else {
//         debugPrint('Failed to delete schedule. Status: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         throw Exception('Failed to delete schedule');
//       }
//     } catch (e, stackTrace) {
//       debugPrint('Error deleting schedule: $e');
//       debugPrint('Stack trace: $stackTrace');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete schedule. Please try again.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width >= 1024;

//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_error != null) {
//       return Center(child: Text(_error!));
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Schedule Manager',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         const Text(
//           'Define the times you are available to be scheduled for meetings.',
//           style: TextStyle(
//             fontSize: 14,
//             color: AppColors.textColorSecond,
//           ),
//         ),
//         const SizedBox(height: 24),
        
//         // Header with Add Schedule button
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'MY SCHEDULES',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textColorSecond,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.help_outline, size: 16),
//                   color: AppColors.textColorSecond,
//                   onPressed: () {},
//                 ),
//               ],
//             ),
//             TextButton.icon(
//               icon: const Icon(Icons.add, size: 16),
//               label: const Text('Add Schedule'),
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.primaryColor,
//               ),
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => CreateScheduleModal(
//                     timezones: const [], // Will be loaded in the modal
//                   ),
//                 ).then((result) {
//                   if (result != null) {
//                     _createSchedule({
//                       'name': result['name'],
//                       'timezone': result['timezone'],
//                       'isDefault': result['isDefault'],
//                     });
//                   }
//                 });
//               },
//             ),
//           ],
//         ),
        
//         // Mobile view - Dropdown with edit button
//         // if (!isDesktop) Row(
//         //   children: [
//         //     Expanded(
//         //       child: DropdownButtonFormField<Map<String, dynamic>>(
//         //         value: _selectedSchedule,
//         //         items: _schedules.map((schedule) {
//         //           return DropdownMenuItem<Map<String, dynamic>>(
//         //             value: schedule,
//         //             child: Text(
//         //               schedule['name'],
//         //               style: const TextStyle(
//         //                 fontSize: 14,
//         //                 color: Colors.black,
//         //               ),
//         //             ),
//         //           );
//         //         }).toList(),
//         //         onChanged: (newValue) {
//         //           setState(() {
//         //             _selectedSchedule = newValue;
//         //           });
//         //         },
//         //         decoration: InputDecoration(
//         //           filled: true,
//         //           fillColor: Colors.white,
//         //           border: OutlineInputBorder(
//         //             borderRadius: BorderRadius.circular(4),
//         //             borderSide: BorderSide(color: Colors.grey.shade300),
//         //           ),
//         //           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//         //         ),
//         //         icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
//         //         style: const TextStyle(fontSize: 14, color: Colors.black),
//         //         dropdownColor: Colors.white,
//         //         hint: const Text('Select a schedule'),
//         //       ),
//         //     ),
//         //     const SizedBox(width: 8),
//         //     IconButton(
//         //       icon: const Icon(Icons.edit_outlined, size: 22),
//         //       color: AppColors.textColorSecond,
//         //       onPressed: _selectedSchedule != null ? () {
//         //         showDialog(
//         //           context: context,
//         //           builder: (context) => EditScheduleModal(
//         //             scheduleId: _selectedSchedule!['id'].toString(),
//         //             initialName: _selectedSchedule!['name'],
//         //             initialTimezone: _selectedSchedule!['timezone'],
//         //             isDefault: _selectedSchedule!['isDefault'],
//         //             onUpdate: _updateSchedule,
//         //             onDelete: _deleteSchedule,
//         //           ),
//         //         );
//         //       } : null,
//         //     ),
//         //   ],
//         // ),
// // Mobile view - Dropdown with edit button
// if (!isDesktop) Row(
//   children: [
//     Expanded(
//       child: DropdownButtonFormField<Map<String, dynamic>>(
//         value: _selectedSchedule,
//         items: _schedules.map((schedule) {
//           return DropdownMenuItem<Map<String, dynamic>>(
//             value: schedule,
//             child: Row(
//               children: [
//                 Text(
//                   schedule['name'],
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black,
//                   ),
//                 ),
//                 if (schedule['isDefault'] == true) ...[
//                   const SizedBox(width: 4),
//                   Text(
//                     '(default)',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: AppColors.primaryColor,
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           );
//         }).toList(),
//         onChanged: (newValue) {
//           setState(() {
//             _selectedSchedule = newValue;
//           });
//         },
//         decoration: InputDecoration(
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(4),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//         ),
//         icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
//         style: const TextStyle(fontSize: 14, color: Colors.black),
//         dropdownColor: Colors.white,
//         hint: const Text('Select a schedule'),
//       ),
//     ),
//     const SizedBox(width: 8),
//     IconButton(
//       icon: const Icon(Icons.edit_outlined, size: 22),
//       color: AppColors.textColorSecond,
//       onPressed: _selectedSchedule != null ? () {
//         showDialog(
//           context: context,
//           builder: (context) => EditScheduleModal(
//             scheduleId: _selectedSchedule!['id'].toString(),
//             initialName: _selectedSchedule!['name'],
//             initialTimezone: _selectedSchedule!['timezone'],
//             isDefault: _selectedSchedule!['isDefault'],
//             onUpdate: _updateSchedule,
//             onDelete: _deleteSchedule,
//           ),
//         );
//       } : null,
//     ),
//   ],
// ),        
//         // Desktop view - Schedule list
//         if (isDesktop) Column(
//           children: [
//             if (_schedules.isNotEmpty) ...[
//               for (var schedule in _schedules)
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   margin: const EdgeInsets.only(bottom: 8),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: schedule['isDefault'] 
//                         ? AppColors.primaryColor 
//                         : Colors.grey.shade300,
//                     ),
//                     borderRadius: BorderRadius.circular(8),
//                     boxShadow: [
//                       if (schedule['isDefault'])
//                         BoxShadow(
//                           color: AppColors.primaryColor.withOpacity(0.1),
//                           blurRadius: 4,
//                           spreadRadius: 1,
//                         ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if (schedule['isDefault'])
//                               const Text(
//                                 'DEFAULT',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.textColorSecond,
//                                 ),
//                               ),
//                             if (schedule['isDefault']) const SizedBox(height: 4),
//                             Text(
//                               schedule['name'],
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.edit_outlined),
//                         color: AppColors.textColorSecond,
//                         onPressed: () {
//                           showDialog(
//                             context: context,
//                             builder: (context) => EditScheduleModal(
//                               scheduleId: schedule['id'].toString(),
//                               initialName: schedule['name'],
//                               initialTimezone: schedule['timezone'],
//                               isDefault: schedule['isDefault'],
//                               onUpdate: _updateSchedule,
//                               onDelete: _deleteSchedule,
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//             ] else
//               const Text('No schedules found'),
//           ],
//         ),
        
//         // Timezone information
//         if (_selectedSchedule != null)
//           Text(
//             'Times are in ${_selectedSchedule!['timezone']}',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//         const SizedBox(height: 16),
        
//         // AI and Help buttons
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 TextButton.icon(
//                   icon: const Icon(Icons.auto_awesome, size: 16),
//                   label: const Text('Generate Availability with AI'),
//                   style: TextButton.styleFrom(
//                     foregroundColor: AppColors.primaryColor,
//                   ),
//                   onPressed: () {},
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: Colors.pink,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Text(
//                     'Beta',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             TextButton.icon(
//               icon: const Icon(Icons.help_outline, size: 16),
//               label: const Text('I need help setting up my schedule'),
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.primaryColor,
//               ),
//               onPressed: () {},
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/config/config.dart';
// import 'package:tabourak/config/globals.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/create_schedule_modal.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/edit_schedule_modal.dart';

// class ScheduleManagerSection extends StatefulWidget {
//   const ScheduleManagerSection({Key? key}) : super(key: key);

//   @override
//   State<ScheduleManagerSection> createState() => _ScheduleManagerSectionState();
// }

// class _ScheduleManagerSectionState extends State<ScheduleManagerSection> {
//   List<Map<String, dynamic>> _schedules = [];
//   Map<String, dynamic>? _selectedSchedule;
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSchedules();
//   }

//   Future<void> _fetchSchedules() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/schedules'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           _schedules = List<Map<String, dynamic>>.from(data.map((schedule) {
//             // Convert isDefault from int to bool if needed
//             if (schedule['isDefault'] is int) {
//               schedule['isDefault'] = schedule['isDefault'] == 1;
//             }
//             return schedule;
//           }));
          
//           if (_schedules.isNotEmpty) {
//             _selectedSchedule = _schedules.firstWhere(
//               (s) => s['isDefault'] == true,
//               orElse: () => _schedules.first,
//             );
//           }
//         });
//       } else {
//         debugPrint('Failed to load schedules. Status: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         throw Exception('Failed to load schedules');
//       }
//     } catch (e, stackTrace) {
//       debugPrint('Error fetching schedules: $e');
//       debugPrint('Stack trace: $stackTrace');
//       setState(() {
//         _error = 'Failed to load schedules. Please try again.';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _createSchedule(Map<String, dynamic> scheduleData) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/schedules'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode(scheduleData),
//       );

//       if (response.statusCode == 201) {
//         await _fetchSchedules();
//       } else {
//         debugPrint('Failed to create schedule. Status: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         throw Exception('Failed to create schedule');
//       }
//     } catch (e, stackTrace) {
//       debugPrint('Error creating schedule: $e');
//       debugPrint('Stack trace: $stackTrace');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to create schedule. Please try again.')),
//       );
//     }
//   }

//   Future<void> _updateSchedule(String id, Map<String, dynamic> scheduleData) async {
//     try {
//       final response = await http.put(
//         Uri.parse('${AppConfig.baseUrl}/api/schedules/$id'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode(scheduleData),
//       );

//       if (response.statusCode == 200) {
//         await _fetchSchedules();
//       } else {
//         debugPrint('Failed to update schedule. Status: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         throw Exception('Failed to update schedule');
//       }
//     } catch (e, stackTrace) {
//       debugPrint('Error updating schedule: $e');
//       debugPrint('Stack trace: $stackTrace');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update schedule. Please try again.')),
//       );
//     }
//   }

//   Future<void> _deleteSchedule(String id) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('${AppConfig.baseUrl}/api/schedules/$id'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         await _fetchSchedules();
//       } else {
//         debugPrint('Failed to delete schedule. Status: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         throw Exception('Failed to delete schedule');
//       }
//     } catch (e, stackTrace) {
//       debugPrint('Error deleting schedule: $e');
//       debugPrint('Stack trace: $stackTrace');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete schedule. Please try again.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width >= 1024;

//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_error != null) {
//       return Center(child: Text(_error!));
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Schedule Manager',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         const Text(
//           'Define the times you are available to be scheduled for meetings.',
//           style: TextStyle(
//             fontSize: 14,
//             color: AppColors.textColorSecond,
//           ),
//         ),
//         const SizedBox(height: 24),
        
//         // Header with Add Schedule button
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'MY SCHEDULES',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textColorSecond,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.help_outline, size: 16),
//                   color: AppColors.textColorSecond,
//                   onPressed: () {},
//                 ),
//               ],
//             ),
//             TextButton.icon(
//               icon: const Icon(Icons.add, size: 16),
//               label: const Text('Add Schedule'),
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.primaryColor,
//               ),
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => CreateScheduleModal(
//                     timezones: const [], // Will be loaded in the modal
//                   ),
//                 ).then((result) {
//                   if (result != null) {
//                     _createSchedule({
//                       'name': result['name'],
//                       'timezone': result['timezone'],
//                       'isDefault': result['isDefault'],
//                     });
//                   }
//                 });
//               },
//             ),
//           ],
//         ),
        
//         // Mobile view - Dropdown with edit button
//         if (!isDesktop) Row(
//           children: [
//             Expanded(
//               child: DropdownButtonFormField<Map<String, dynamic>>(
//                 value: _selectedSchedule,
//                 items: _schedules.map((schedule) {
//                   return DropdownMenuItem<Map<String, dynamic>>(
//                     value: schedule,
//                     child: Text(
//                       schedule['name'],
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.black,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: (newValue) {
//                   setState(() {
//                     _selectedSchedule = newValue;
//                   });
//                 },
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(4),
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//                 ),
//                 icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
//                 style: const TextStyle(fontSize: 14, color: Colors.black),
//                 dropdownColor: Colors.white,
//                 hint: const Text('Select a schedule'),
//               ),
//             ),
//             const SizedBox(width: 8),
//             IconButton(
//               icon: const Icon(Icons.edit_outlined, size: 22),
//               color: AppColors.textColorSecond,
//               onPressed: _selectedSchedule != null ? () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => EditScheduleModal(
//                     scheduleId: _selectedSchedule!['id'].toString(),
//                     initialName: _selectedSchedule!['name'],
//                     initialTimezone: _selectedSchedule!['timezone'],
//                     isDefault: _selectedSchedule!['isDefault'],
//                     onUpdate: _updateSchedule,
//                     onDelete: _deleteSchedule,
//                   ),
//                 );
//               } : null,
//             ),
//           ],
//         ),
        
//         // Desktop view - Schedule list
//         if (isDesktop) Column(
//           children: [
//             if (_schedules.isNotEmpty) ...[
//               for (var schedule in _schedules)
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   margin: const EdgeInsets.only(bottom: 8),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: schedule['isDefault'] 
//                         ? AppColors.primaryColor 
//                         : Colors.grey.shade300,
//                     ),
//                     borderRadius: BorderRadius.circular(8),
//                     boxShadow: [
//                       if (schedule['isDefault'])
//                         BoxShadow(
//                           color: AppColors.primaryColor.withOpacity(0.1),
//                           blurRadius: 4,
//                           spreadRadius: 1,
//                         ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if (schedule['isDefault'])
//                               const Text(
//                                 'DEFAULT',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.textColorSecond,
//                                 ),
//                               ),
//                             if (schedule['isDefault']) const SizedBox(height: 4),
//                             Text(
//                               schedule['name'],
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.edit_outlined),
//                         color: AppColors.textColorSecond,
//                         onPressed: () {
//                           showDialog(
//                             context: context,
//                             builder: (context) => EditScheduleModal(
//                               scheduleId: schedule['id'].toString(),
//                               initialName: schedule['name'],
//                               initialTimezone: schedule['timezone'],
//                               isDefault: schedule['isDefault'],
//                               onUpdate: _updateSchedule,
//                               onDelete: _deleteSchedule,
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//             ] else
//               const Text('No schedules found'),
//           ],
//         ),
        
//         // Timezone information
//         if (_selectedSchedule != null)
//           Text(
//             'Times are in ${_selectedSchedule!['timezone']}',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//         const SizedBox(height: 16),
        
//         // AI and Help buttons
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 TextButton.icon(
//                   icon: const Icon(Icons.auto_awesome, size: 16),
//                   label: const Text('Generate Availability with AI'),
//                   style: TextButton.styleFrom(
//                     foregroundColor: AppColors.primaryColor,
//                   ),
//                   onPressed: () {},
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: Colors.pink,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Text(
//                     'Beta',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             TextButton.icon(
//               icon: const Icon(Icons.help_outline, size: 16),
//               label: const Text('I need help setting up my schedule'),
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.primaryColor,
//               ),
//               onPressed: () {},
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }















// lib\content\availability&calender\schedulesTab\schedule_manager_section.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/create_schedule_modal.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/edit_schedule_modal.dart';

// class ScheduleManagerSection extends StatefulWidget {
//   const ScheduleManagerSection({Key? key}) : super(key: key);

//   @override
//   State<ScheduleManagerSection> createState() => _ScheduleManagerSectionState();
// }

// class _ScheduleManagerSectionState extends State<ScheduleManagerSection> {
//   String? _selectedSchedule;
//   final List<String> _schedules = [
//     'My Availability (default)',
//     'Work Hours',
//     'Weekend Availability',
//     'Custom Schedule'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _selectedSchedule = _schedules.first;
//   }

//   void _handleEditResult(dynamic result) {
//     if (result == 'delete') {
//       // Handle delete logic
//       setState(() {
//         _schedules.remove(_selectedSchedule);
//         if (_schedules.isNotEmpty) {
//           _selectedSchedule = _schedules.first;
//         } else {
//           _selectedSchedule = null;
//         }
//       });
//     } else if (result != null) {
//       // Handle save logic
//       setState(() {
//         final index = _schedules.indexOf(_selectedSchedule!);
//         if (index != -1) {
//           _schedules[index] = result['name'];
//           _selectedSchedule = _schedules[index];
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width >= 1024;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Schedule Manager',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         const Text(
//           'Define the times you are available to be scheduled for meetings.',
//           style: TextStyle(
//             fontSize: 14,
//             color: AppColors.textColorSecond,
//           ),
//         ),
//         const SizedBox(height: 24),
        
//         // Header with Add Schedule button
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'MY SCHEDULES',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textColorSecond,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.help_outline, size: 16),
//                   color: AppColors.textColorSecond,
//                   onPressed: () {},
//                 ),
//               ],
//             ),
//             TextButton.icon(
//               icon: const Icon(Icons.add, size: 16),
//               label: const Text('Add Schedule'),
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.primaryColor,
//               ),
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => const CreateScheduleModal(),
//                 ).then((result) {
//                   if (result != null) {
//                     setState(() {
//                       _schedules.add(result['name']);
//                       _selectedSchedule = result['name'];
//                     });
//                   }
//                 });
//               },
//             ),
//           ],
//         ),
        
//         // Mobile view - Dropdown with edit button
//         if (!isDesktop) Row(
//           children: [
//             Expanded(
//               child: DropdownButtonFormField<String>(
//                 value: _selectedSchedule,
//                 items: _schedules.map((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(
//                       value,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.black,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: (newValue) {
//                   setState(() {
//                     _selectedSchedule = newValue;
//                   });
//                 },
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(4),
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//                 ),
//                 icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
//                 style: const TextStyle(fontSize: 14, color: Colors.black),
//                 dropdownColor: Colors.white,
//                 hint: const Text('Select a schedule'),
//               ),
//             ),
//             const SizedBox(width: 8),
//             IconButton(
//               icon: const Icon(Icons.edit_outlined, size: 22),
//               color: AppColors.textColorSecond,
//               onPressed: _selectedSchedule != null ? () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => EditScheduleModal(
//                     initialName: _selectedSchedule!,
//                     initialTimezone: 'Asia/Hebron',
//                     isDefault: _selectedSchedule == _schedules.first,
//                   ),
//                 ).then(_handleEditResult);
//               } : null,
//             ),
//           ],
//         ),
        
//         // Desktop view - Schedule list
//         if (isDesktop) Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 border: Border.all(color: AppColors.primaryColor),
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.primaryColor.withOpacity(0.1),
//                     blurRadius: 4,
//                     spreadRadius: 1,
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'DEFAULT',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.textColorSecond,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           _selectedSchedule ?? 'No schedule selected',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.edit_outlined),
//                     color: AppColors.textColorSecond,
//                     onPressed: _selectedSchedule != null ? () {
//                       showDialog(
//                         context: context,
//                         builder: (context) => EditScheduleModal(
//                           initialName: _selectedSchedule!,
//                           initialTimezone: 'Asia/Hebron',
//                           isDefault: _selectedSchedule == _schedules.first,
//                         ),
//                       ).then(_handleEditResult);
//                     } : null,
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 8),
//           ],
//         ),
        
//         // Timezone information
//         Text(
//           'Times are in Asia/Hebron',
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.grey[600],
//           ),
//         ),
//         const SizedBox(height: 16),
        
//         // AI and Help buttons
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 TextButton.icon(
//                   icon: const Icon(Icons.auto_awesome, size: 16),
//                   label: const Text('Generate Availability with AI'),
//                   style: TextButton.styleFrom(
//                     foregroundColor: AppColors.primaryColor,
//                   ),
//                   onPressed: () {},
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: Colors.pink,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Text(
//                     'Beta',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             TextButton.icon(
//               icon: const Icon(Icons.help_outline, size: 16),
//               label: const Text('I need help setting up my schedule'),
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.primaryColor,
//               ),
//               onPressed: () {},
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
