// lib/content/availability/widgets/add_seasonal_hours_modal.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/models/time_range.dart';
import 'availability_editor.dart';

class AddSeasonalHoursModal extends StatefulWidget {
  final Map<String, List<TimeRange>> initialAvailability;

  const AddSeasonalHoursModal({
    Key? key,
    required this.initialAvailability,
  }) : super(key: key);

  @override
  _AddSeasonalHoursModalState createState() => _AddSeasonalHoursModalState();
}

class _AddSeasonalHoursModalState extends State<AddSeasonalHoursModal> {
  late Map<String, List<TimeRange>> availability;
  late TextEditingController _nicknameController;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    availability = Map.from(widget.initialAvailability);
    _nicknameController = TextEditingController();
    _dateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 7)),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final initialDateRange = _dateRange ?? DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 7)),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
            backgroundColor: AppColors.backgroundColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Add Seasonal Hours',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: AppColors.textColorSecond,
                  ),
                ],
              ),
            ),
            
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nickname Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nickname',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nicknameController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Summer Hours or Holiday Hours',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Date Range Picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date Range',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => _pickDateRange(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: AppColors.textColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _dateRange != null
                                    ? '${_dateRange!.start.year}-${_dateRange!.start.month}-${_dateRange!.start.day} - '
                                        '${_dateRange!.end.year}-${_dateRange!.end.month}-${_dateRange!.end.day}'
                                    : 'Select Date Range',
                                style: TextStyle(color: AppColors.textColor),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: AppColors.textColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Weekly Hours Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recurring Weekly Hours',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Reuse the AvailabilityEditor widget
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AvailabilityEditor(
                            initialAvailability: availability,
                            onSave: (updatedAvailability) {
                              setState(() {
                                availability = updatedAvailability;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle save logic here
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'Add Seasonal Hours',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/content/availability/widgets/add_seasonal_hours_modal.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/models/time_range.dart';

// class AddSeasonalHoursModal extends StatefulWidget {
//   final Map<String, List<TimeRange>> initialAvailability;

//   const AddSeasonalHoursModal({
//     Key? key,
//     required this.initialAvailability,
//   }) : super(key: key);

//   @override
//   _AddSeasonalHoursModalState createState() => _AddSeasonalHoursModalState();
// }

// class _AddSeasonalHoursModalState extends State<AddSeasonalHoursModal> {
//   late Map<String, List<TimeRange>> availability;
//   late TextEditingController _nicknameController;
//   DateTimeRange? _dateRange;

//   @override
//   void initState() {
//     super.initState();
//     availability = Map.from(widget.initialAvailability);
//     _nicknameController = TextEditingController();
//     _dateRange = DateTimeRange(
//       start: DateTime.now(),
//       end: DateTime.now().add(const Duration(days: 7)),
//     );
//   }

//   @override
//   void dispose() {
//     _nicknameController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickDateRange(BuildContext context) async {
//     final initialDateRange = _dateRange ?? DateTimeRange(
//       start: DateTime.now(),
//       end: DateTime.now().add(const Duration(days: 7)),
//     );

//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(DateTime.now().year + 5),
//       initialDateRange: initialDateRange,
//     );

//     if (picked != null) {
//       setState(() {
//         _dateRange = picked;
//       });
//     }
//   }

//   Future<void> _pickTime(BuildContext context, bool isStart, TimeRange range) async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: isStart ? range.start : range.end,
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

//   void _addTimeSlot(String day) {
//     setState(() {
//       if (availability[day]!.isEmpty) {
//         availability[day]!.add(TimeRange(
//           const TimeOfDay(hour: 9, minute: 0),
//           const TimeOfDay(hour: 17, minute: 0),
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

//   void _removeTimeSlot(String day, TimeRange range) {
//     setState(() {
//       availability[day]!.remove(range);
//     });
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
//               title: const Text("Copy to other days"),
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
//                   child: const Text("Cancel"),
//                 ),
//                 ElevatedButton(
//                   onPressed: selected.isEmpty
//                       ? null
//                       : () => Navigator.of(context).pop(selected),
//                   child: const Text("Copy"),
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
//         const SnackBar(
//           content: Text("Copied to selected day(s)"),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 600),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.edit,
//                     color: AppColors.primaryColor,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Add Seasonal Hours',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textColor,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.of(context).pop(),
//                     color: AppColors.textColorSecond,
//                   ),
//                 ],
//               ),
//             ),
            
//             // Form
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Nickname Field
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Nickname',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _nicknameController,
//                           decoration: InputDecoration(
//                             hintText: 'e.g. Summer Hours or Holiday Hours',
//                             border: const OutlineInputBorder(),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 10,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: AppColors.primaryColor,
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Date Range Picker
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Date Range',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         OutlinedButton(
//                           onPressed: () => _pickDateRange(context),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                             side: BorderSide(color: Colors.grey.shade400),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.calendar_today,
//                                 size: 16,
//                                 color: AppColors.textColor,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 _dateRange != null
//                                     ? '${_dateRange!.start.year}-${_dateRange!.start.month}-${_dateRange!.start.day} - '
//                                         '${_dateRange!.end.year}-${_dateRange!.end.month}-${_dateRange!.end.day}'
//                                     : 'Select Date Range',
//                                 style: TextStyle(color: AppColors.textColor),
//                               ),
//                               const SizedBox(width: 8),
//                               Icon(
//                                 Icons.arrow_drop_down,
//                                 size: 16,
//                                 color: AppColors.textColor,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Weekly Hours Section
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Recurring Weekly Hours',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
                        
//                         // Days List
//                         Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Column(
//                             children: [
//                               // Sunday
//                               _buildDayRow('Sunday', 'Sun'),
//                               // Monday
//                               _buildDayRow('Monday', 'Mon'),
//                               // Tuesday
//                               _buildDayRow('Tuesday', 'Tue'),
//                               // Wednesday
//                               _buildDayRow('Wednesday', 'Wed'),
//                               // Thursday
//                               _buildDayRow('Thursday', 'Thu'),
//                               // Friday
//                               _buildDayRow('Friday', 'Fri'),
//                               // Saturday
//                               _buildDayRow('Saturday', 'Sat'),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             // Footer
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   top: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Handle save logic here
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryColor,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   child: const Text(
//                     'Add Seasonal Hours',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDayRow(String day, String shortDay) {
//     final isMobile = MediaQuery.of(context).size.width < 600;
    
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: Colors.grey.shade300,
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Day label - hidden on mobile when in landscape
//           if (!isMobile)
//             Container(
//               width: 80,
//               padding: const EdgeInsets.only(right: 16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   right: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   shortDay,
//                   style: TextStyle(
//                     color: AppColors.textColor,
//                   ),
//                 ),
//               ),
//             ),
          
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Show day name on mobile
//                 if (isMobile)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8.0),
//                     child: Text(
//                       day,
//                       style: TextStyle(
//                         color: AppColors.textColor,
//                       ),
//                     ),
//                   ),
                
//                 // Time slots or "Unavailable"
//                 if (availability[day]!.isEmpty)
//                   Text(
//                     'Unavailable',
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                     ),
//                   )
//                 else
//                   Column(
//                     children: availability[day]!.map((range) {
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 8.0),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: () => _pickTime(context, true, range),
//                                 style: OutlinedButton.styleFrom(
//                                   padding: const EdgeInsets.symmetric(vertical: 8),
//                                   side: BorderSide(color: Colors.grey.shade400),
//                                 ),
//                                 child: Text(
//                                   range.start.format(context),
//                                   style: TextStyle(color: AppColors.textColor),
//                                 ),
//                               ),
//                             ),
//                             const Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 8.0),
//                               child: Text('-'),
//                             ),
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: () => _pickTime(context, false, range),
//                                 style: OutlinedButton.styleFrom(
//                                   padding: const EdgeInsets.symmetric(vertical: 8),
//                                   side: BorderSide(color: Colors.grey.shade400),
//                                 ),
//                                 child: Text(
//                                   range.end.format(context),
//                                   style: TextStyle(color: AppColors.textColor),
//                                 ),
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.close, size: 20),
//                               onPressed: () => _removeTimeSlot(day, range),
//                               color: Colors.grey.shade600,
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   ),
                
//                 // Add Time button
//                 TextButton(
//                   onPressed: () => _addTimeSlot(day),
//                   style: TextButton.styleFrom(
//                     padding: EdgeInsets.zero,
//                     minimumSize: const Size(50, 30),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.add,
//                         size: 20,
//                         color: AppColors.primaryColor,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         'Add Time',
//                         style: TextStyle(
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // Copy button
//           IconButton(
//             icon: Icon(
//               Icons.copy,
//               size: 20,
//               color: Colors.grey.shade600,
//             ),
//             onPressed: () => _copyToOtherDays(day),
//           ),
//         ],
//       ),
//     );
//   }
// }