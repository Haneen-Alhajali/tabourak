 // lib/content/availability/widgets/availability_editor.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/models/time_range.dart';

class AvailabilityEditor extends StatefulWidget {
  final Map<String, List<TimeRange>> initialAvailability;
  final Function(Map<String, List<TimeRange>>) onSave;

  const AvailabilityEditor({
    Key? key,
    required this.initialAvailability,
    required this.onSave,
  }) : super(key: key);

  @override
  _AvailabilityEditorState createState() => _AvailabilityEditorState();
}

class _AvailabilityEditorState extends State<AvailabilityEditor> {
  late Map<String, List<TimeRange>> availability;
  bool showWeekend = false;

  @override
  void initState() {
    super.initState();
    availability = Map.from(widget.initialAvailability);
    showWeekend = availability.containsKey("Friday");
  }

  Future<void> _pickTime(BuildContext context, bool isStart, TimeRange range) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? range.start : range.end,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          range.start = picked;
        } else {
          range.end = picked;
        }
      });
    }
  }

  void _copyToOtherDays(String sourceDay) async {
    final days = availability.keys.toList();
    final selectedDays = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        final selected = <String>[];
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Copy to other days"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: days.where((d) => d != sourceDay).map((day) {
                    return CheckboxListTile(
                      title: Text(day),
                      value: selected.contains(day),
                      activeColor: AppColors.primaryColor,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            selected.add(day);
                          } else {
                            selected.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                  ),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () => Navigator.of(context).pop(selected),
                  child: Text("Copy"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedDays != null && selectedDays.isNotEmpty) {
      setState(() {
        for (final day in selectedDays) {
          availability[day] = availability[sourceDay]!
              .map((tr) => TimeRange(tr.start, tr.end))
              .toList();
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Copied to ${selectedDays.length} day(s)"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _addTimeSlot(String day) {
    setState(() {
      if (availability[day]!.isEmpty) {
        availability[day]!.add(TimeRange(
          TimeOfDay(hour: 9, minute: 0),
          TimeOfDay(hour: 17, minute: 0),
        ));
      } else {
        final lastSlot = availability[day]!.last;
        TimeOfDay newStart = lastSlot.end;
        TimeOfDay newEnd;
        
        int newHour = newStart.hour + 1;
        int newMinute = newStart.minute;
        
        if (newHour >= 24) {
          newHour = newHour % 24;
        }
        
        newEnd = TimeOfDay(hour: newHour, minute: newMinute);
        
        availability[day]!.add(TimeRange(newStart, newEnd));
      }
    });
  }

  bool _hasOverlap(String day, TimeRange newRange) {
    for (final existingRange in availability[day]!) {
      if (existingRange == newRange) continue;
      
      final existingStart = existingRange.start;
      final existingEnd = existingRange.end;
      final newStart = newRange.start;
      final newEnd = newRange.end;

      if (_isStartSameAsEnd(existingRange) || _isStartSameAsEnd(newRange)) {
        continue;
      }

      if ((newStart.hour < existingEnd.hour || 
          (newStart.hour == existingEnd.hour && newStart.minute < existingEnd.minute)) &&
          (newEnd.hour > existingStart.hour || 
          (newEnd.hour == existingStart.hour && newEnd.minute > existingStart.minute))) {
        return true;
      }
    }
    return false;
  }

  bool _isStartAfterEnd(TimeRange range) {
    return range.end.hour < range.start.hour || 
          (range.end.hour == range.start.hour && range.end.minute < range.start.minute);
  }

  bool _isStartSameAsEnd(TimeRange range) {
    return range.start.hour == range.end.hour && 
           range.start.minute == range.end.minute;
  }

  Widget _timeBox(TimeOfDay time, {bool isInvalid = false}) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: isInvalid ? Colors.red : Colors.grey,
          width: isInvalid ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(5),
        color: isInvalid ? Colors.red.withOpacity(0.1) : null,
      ),
      child: Center(
        child: Text(
          time.format(context),
          style: TextStyle(
            color: isInvalid ? Colors.red : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...availability.keys.map((day) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    day,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      color: AppColors.primaryColor,
                    ),
                    onPressed: () => _copyToOtherDays(day),
                    tooltip: 'Copy to other days',
                  ),
                ],
              ),
              ...availability[day]!.map((range) {
                final hasOverlap = _hasOverlap(day, range);
                final isStartAfterEnd = _isStartAfterEnd(range);
                final isStartSameAsEnd = _isStartSameAsEnd(range);
                final isInvalid = hasOverlap || isStartAfterEnd || isStartSameAsEnd;
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isInvalid ? Colors.red : AppColors.textColorSecond,
                      width: isInvalid ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: isInvalid 
                        ? Colors.red.withOpacity(0.1) 
                        : AppColors.backgroundColor,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickTime(context, true, range),
                              child: _timeBox(range.start, isInvalid: isInvalid),
                            ),
                          ),
                          Text(" - "),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickTime(context, false, range),
                              child: _timeBox(range.end, isInvalid: isInvalid),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: isInvalid ? Colors.red : AppColors.textColor,
                            ),
                            onPressed: () {
                              setState(() {
                                availability[day]!.remove(range);
                              });
                            },
                          ),
                        ],
                      ),
                      if (isInvalid)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            isStartAfterEnd 
                                ? "Start can't be after end" 
                                : isStartSameAsEnd
                                  ? "Start time can't be same as end time"
                                  : "Time ranges can't overlap",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              TextButton(
                onPressed: () => _addTimeSlot(day),
                child: Row(
                  children: [
                    Icon(Icons.add, color: AppColors.primaryColor),
                    Text(
                      "Add Time",
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          );
        }).toList(),
        
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Show Weekend",
                style: TextStyle(fontSize: 16),
              ),
              Switch(
                value: showWeekend,
                onChanged: (value) {
                  setState(() {
                    showWeekend = value;
                    if (value) {
                      availability["Friday"] = [
                        TimeRange(
                          TimeOfDay(hour: 9, minute: 0),
                          TimeOfDay(hour: 17, minute: 0),
                        ),
                      ];
                      availability["Saturday"] = [
                        TimeRange(
                          TimeOfDay(hour: 9, minute: 0),
                          TimeOfDay(hour: 17, minute: 0),
                        ),
                      ];
                    } else {
                      availability.remove("Friday");
                      availability.remove("Saturday");
                    }
                  });
                },
                activeColor: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

















// // lib/content/availability/widgets/availability_editor.dart
// import 'package:flutter/material.dart';
// import '../../../colors/app_colors.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../../../config/config.dart';

// class AvailabilityEditor extends StatefulWidget {
//   final Map<String, List<TimeRange>> initialAvailability;
//   final String authToken;
//   final Function(Map<String, List<TimeRange>>) onSave;

//   const AvailabilityEditor({
//     Key? key,
//     required this.initialAvailability,
//     required this.authToken,
//     required this.onSave,
//   }) : super(key: key);

//   @override
//   _AvailabilityEditorState createState() => _AvailabilityEditorState();
// }

// class _AvailabilityEditorState extends State<AvailabilityEditor> {
//   late Map<String, List<TimeRange>> availability;
//   bool showWeekend = false;
//   bool _isLoading = false;
//   String? _scheduleId;

//   @override
//   void initState() {
//     super.initState();
//     availability = Map.from(widget.initialAvailability);
//     showWeekend = availability.containsKey("Friday");
//     _loadAvailability();
//   }

//   Future<void> _loadAvailability() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/availability'),
//         headers: {
//           'Authorization': 'Bearer ${widget.authToken}',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           _scheduleId = data['scheduleId'];
          
//           if (data['availability'] != null) {
//             final apiAvailability = data['availability'] as Map<String, dynamic>;
//             availability = {
//               "Sunday": [],
//               "Monday": [],
//               "Tuesday": [],
//               "Wednesday": [],
//               "Thursday": [],
//               "Friday": [],
//               "Saturday": [],
//             };
            
//             apiAvailability.forEach((day, ranges) {
//               if (availability.containsKey(day)) {
//                 availability[day] = (ranges as List).map((range) {
//                   return TimeRange(
//                     TimeOfDay(hour: range['start']['hour'], minute: range['start']['minute']),
//                     TimeOfDay(hour: range['end']['hour'], minute: range['end']['minute']),
//                   );
//                 }).toList();
//               }
//             });

//             if (availability["Friday"]!.isEmpty && availability["Saturday"]!.isEmpty) {
//               availability.remove("Friday");
//               availability.remove("Saturday");
//             }
//             showWeekend = availability.containsKey("Friday");
//           }
//         });
//       }
//     } catch (e) {
//       print('Error loading availability: $e');
//       // Initialize with default values if loading fails
//       setState(() {
//         availability = {
//           "Sunday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//           "Monday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//           "Tuesday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//           "Wednesday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//           "Thursday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//         };
//       });
//     }
//   }

//   Future<void> _saveAvailability() async {
//     setState(() => _isLoading = true);

//     // Validate all time slots first
//     bool hasInvalid = false;
//     availability.forEach((day, ranges) {
//       for (final range in ranges) {
//         if (_isStartAfterEnd(range) || _hasOverlap(day, range) || _isStartSameAsEnd(range)) {
//           hasInvalid = true;
//           return;
//         }
//       }
//     });

//     if (hasInvalid) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Please resolve invalid time slots")),
//       );
//       return;
//     }

//     // Convert our availability to API format
//     final apiAvailability = {};
//     availability.forEach((day, ranges) {
//       apiAvailability[day] = ranges.map((range) {
//         return {
//           'start': {
//             'hour': range.start.hour,
//             'minute': range.start.minute,
//           },
//           'end': {
//             'hour': range.end.hour,
//             'minute': range.end.minute,
//           },
//         };
//       }).toList();
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/availability'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${widget.authToken}',
//         },
//         body: json.encode({
//           'availability': apiAvailability,
//           'scheduleId': _scheduleId,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Availability ${responseData['action']} successfully')),
//         );
        
//         // Call the parent's onSave callback
//         widget.onSave(availability);
//       } else {
//         final error = json.decode(response.body)['error'] ?? 'Failed to save availability';
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

//   Future<void> _pickTime(BuildContext context, bool isStart, TimeRange range) async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: isStart ? range.start : range.end,
//       builder: (context, child) {
//         return MediaQuery(
//           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         if (isStart) {
//           range.start = picked;
//         } else {
//           range.end = picked;
//         }
//       });
//     }
//   }

//   void _copyToOtherDays(String sourceDay) async {
//     final days = availability.keys.toList();
//     final selectedDays = await showDialog<List<String>>(
//       context: context,
//       builder: (context) {
//         final selected = <String>[];
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text("Copy to other days"),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: days.where((d) => d != sourceDay).map((day) {
//                     return CheckboxListTile(
//                       title: Text(day),
//                       value: selected.contains(day),
//                       onChanged: (checked) {
//                         setState(() {
//                           if (checked == true) {
//                             selected.add(day);
//                           } else {
//                             selected.remove(day);
//                           }
//                         });
//                       },
//                     );
//                   }).toList(),
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text("Cancel"),
//                 ),
//                 ElevatedButton(
//                   onPressed: selected.isEmpty
//                       ? null
//                       : () => Navigator.of(context).pop(selected),
//                   child: Text("Copy"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryColor,
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );

//     if (selectedDays != null && selectedDays.isNotEmpty) {
//       setState(() {
//         for (final day in selectedDays) {
//           availability[day] = availability[sourceDay]!
//               .map((tr) => TimeRange(tr.start, tr.end))
//               .toList();
//         }
//       });
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Copied to ${selectedDays.length} day(s)"),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   void _addTimeSlot(String day) {
//     setState(() {
//       if (availability[day]!.isEmpty) {
//         availability[day]!.add(TimeRange(
//           TimeOfDay(hour: 9, minute: 0),
//           TimeOfDay(hour: 17, minute: 0),
//         ));
//       } else {
//         final lastSlot = availability[day]!.last;
//         TimeOfDay newStart = lastSlot.end;
//         TimeOfDay newEnd;
        
//         int newHour = newStart.hour + 1;
//         int newMinute = newStart.minute;
        
//         if (newHour >= 24) {
//           newHour = newHour % 24;
//         }
        
//         newEnd = TimeOfDay(hour: newHour, minute: newMinute);
        
//         availability[day]!.add(TimeRange(newStart, newEnd));
//       }
//     });
//   }

//   bool _hasOverlap(String day, TimeRange newRange) {
//     for (final existingRange in availability[day]!) {
//       if (existingRange == newRange) continue;
      
//       final existingStart = existingRange.start;
//       final existingEnd = existingRange.end;
//       final newStart = newRange.start;
//       final newEnd = newRange.end;

//       if (_isStartSameAsEnd(existingRange) || _isStartSameAsEnd(newRange)) {
//         continue;
//       }

//       if ((newStart.hour < existingEnd.hour || 
//           (newStart.hour == existingEnd.hour && newStart.minute < existingEnd.minute)) &&
//           (newEnd.hour > existingStart.hour || 
//           (newEnd.hour == existingStart.hour && newEnd.minute > existingStart.minute))) {
//         return true;
//       }
//     }
//     return false;
//   }

//   bool _isStartAfterEnd(TimeRange range) {
//     return range.end.hour < range.start.hour || 
//           (range.end.hour == range.start.hour && range.end.minute < range.start.minute);
//   }

//   bool _isStartSameAsEnd(TimeRange range) {
//     return range.start.hour == range.end.hour && 
//            range.start.minute == range.end.minute;
//   }

//   Widget _timeBox(TimeOfDay time, {bool isInvalid = false}) {
//     return Container(
//       padding: EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: isInvalid ? Colors.red : Colors.grey,
//           width: isInvalid ? 2 : 1,
//         ),
//         borderRadius: BorderRadius.circular(5),
//         color: isInvalid ? Colors.red.withOpacity(0.1) : null,
//       ),
//       child: Center(
//         child: Text(
//           time.format(context),
//           style: TextStyle(
//             color: isInvalid ? Colors.red : null,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ...availability.keys.map((day) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     day,
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Spacer(),
//                   IconButton(
//                     icon: Icon(
//                       Icons.copy,
//                       color: AppColors.primaryColor,
//                     ),
//                     onPressed: () => _copyToOtherDays(day),
//                     tooltip: 'Copy to other days',
//                   ),
//                 ],
//               ),
//               ...availability[day]!.map((range) {
//                 final hasOverlap = _hasOverlap(day, range);
//                 final isStartAfterEnd = _isStartAfterEnd(range);
//                 final isStartSameAsEnd = _isStartSameAsEnd(range);
//                 final isInvalid = hasOverlap || isStartAfterEnd || isStartSameAsEnd;
//                 return Container(
//                   margin: EdgeInsets.symmetric(vertical: 5),
//                   padding: EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: isInvalid ? Colors.red : AppColors.textColorSecond,
//                       width: isInvalid ? 2 : 1,
//                     ),
//                     borderRadius: BorderRadius.circular(8),
//                     color: isInvalid 
//                         ? Colors.red.withOpacity(0.1) 
//                         : AppColors.backgroundColor,
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () => _pickTime(context, true, range),
//                               child: _timeBox(range.start, isInvalid: isInvalid),
//                             ),
//                           ),
//                           Text(" - "),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () => _pickTime(context, false, range),
//                               child: _timeBox(range.end, isInvalid: isInvalid),
//                             ),
//                           ),
//                           IconButton(
//                             icon: Icon(
//                               Icons.close,
//                               color: isInvalid ? Colors.red : AppColors.textColor,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 availability[day]!.remove(range);
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                       if (isInvalid)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8.0),
//                           child: Text(
//                             isStartAfterEnd 
//                                 ? "Start can't be after end" 
//                                 : isStartSameAsEnd
//                                   ? "Start time can't be same as end time"
//                                   : "Time ranges can't overlap",
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//               TextButton(
//                 onPressed: () => _addTimeSlot(day),
//                 child: Row(
//                   children: [
//                     Icon(Icons.add, color: AppColors.primaryColor),
//                     Text(
//                       "Add Time",
//                       style: TextStyle(color: AppColors.primaryColor),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 10),
//             ],
//           );
//         }).toList(),
        
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Show Weekend",
//                 style: TextStyle(fontSize: 16),
//               ),
//               Switch(
//                 value: showWeekend,
//                 onChanged: (value) {
//                   setState(() {
//                     showWeekend = value;
//                     if (value) {
//                       availability["Friday"] = [
//                         TimeRange(
//                           TimeOfDay(hour: 9, minute: 0),
//                           TimeOfDay(hour: 17, minute: 0),
//                         ),
//                       ];
//                       availability["Saturday"] = [
//                         TimeRange(
//                           TimeOfDay(hour: 9, minute: 0),
//                           TimeOfDay(hour: 17, minute: 0),
//                         ),
//                       ];
//                     } else {
//                       availability.remove("Friday");
//                       availability.remove("Saturday");
//                     }
//                   });
//                 },
//                 activeColor: AppColors.primaryColor,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }