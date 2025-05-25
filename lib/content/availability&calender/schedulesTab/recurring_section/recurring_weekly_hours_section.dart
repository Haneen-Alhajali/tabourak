// lib\content\availability&calender\schedulesTab\recurring_section\recurring_weekly_hours_section.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/content/availability&calender/schedulesTab/recurring_section/edit_hours_page.dart';
import 'package:tabourak/content/availability&calender/schedulesTab/recurring_section/seasonal_hours_section.dart';
import 'package:tabourak/content/availability&calender/schedulesTab/recurring_section/add_seasonal_hours_modal.dart';
import 'package:tabourak/models/time_range.dart';

class RecurringWeeklyHoursSection extends StatefulWidget {
  final Map<String, List<TimeRange>> availability;
  final String scheduleId;
  final Function(Map<String, List<TimeRange>>)? onAvailabilityUpdated;

  const RecurringWeeklyHoursSection({
    Key? key,
    required this.availability,
    required this.scheduleId,
    this.onAvailabilityUpdated,
  }) : super(key: key);

  @override
  _RecurringWeeklyHoursSectionState createState() => _RecurringWeeklyHoursSectionState();
}

class _RecurringWeeklyHoursSectionState extends State<RecurringWeeklyHoursSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'RECURRING WEEKLY HOURS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorSecond,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline, size: 16),
                  onPressed: () {},
                  color: AppColors.textColorSecond,
                ),
              ],
            ),
            TextButton(
              onPressed: () async {
                final updatedAvailability = await Navigator.push<Map<String, List<TimeRange>>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditHoursPage(
                      initialAvailability: widget.availability,
                      scheduleId: widget.scheduleId,
                    ),
                  ),
                );
                
                if (updatedAvailability != null) {
                  widget.onAvailabilityUpdated?.call(updatedAvailability);
                }
              },
              child: const Text(
                'Edit Hours',
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildDayRow(context, 'Sunday', widget.availability['Sunday']),
              _buildDayRow(context, 'Monday', widget.availability['Monday']),
              _buildDayRow(context, 'Tuesday', widget.availability['Tuesday']),
              _buildDayRow(context, 'Wednesday', widget.availability['Wednesday']),
              _buildDayRow(context, 'Thursday', widget.availability['Thursday']),
              _buildDayRow(context, 'Friday', widget.availability['Friday']),
              _buildDayRow(context, 'Saturday', widget.availability['Saturday']),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        SeasonalHoursSection(
          scheduleId: widget.scheduleId,
          onAdd: () async {
            final result = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (context) => AddSeasonalHoursModal(
                initialAvailability: widget.availability,
              ),
            );
            return result;
          },
          onAvailabilityUpdated: (updatedAvailability) {
            widget.onAvailabilityUpdated?.call(updatedAvailability);
          },
        ),
      ],
    );
  }

  Widget _buildDayRow(BuildContext context, String day, List<TimeRange>? timeRanges) {
    final isAvailable = timeRanges != null && timeRanges.isNotEmpty;
    
    List<TimeRange>? sortedTimeRanges;
    if (isAvailable) {
      sortedTimeRanges = List<TimeRange>.from(timeRanges!);
      sortedTimeRanges.sort((a, b) {
        final aMinutes = a.start.hour * 60 + a.start.minute;
        final bMinutes = b.start.hour * 60 + b.start.minute;
        return aMinutes.compareTo(bMinutes);
      });
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                if (!isAvailable)
                  Text(
                    'Unavailable',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                if (isAvailable)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sortedTimeRanges!.map((range) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(AppColors.primaryColor.value).withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${range.start.format(context)} - ${range.end.format(context)}',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}





//edit2 for add seasonal


// // lib\content\availability&calender\schedulesTab\recurring_section\recurring_weekly_hours_section.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/recurring_section/edit_hours_page.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/recurring_section/seasonal_hours_section.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/recurring_section/add_seasonal_hours_modal.dart';
// import 'package:tabourak/models/time_range.dart';

// class RecurringWeeklyHoursSection extends StatefulWidget {
//   final Map<String, List<TimeRange>> availability;
//   final Map<DateTimeRange, Map<String, dynamic>> seasonalHours;
//   final String scheduleId;
//   final Function(Map<String, List<TimeRange>>)? onAvailabilityUpdated;

//   const RecurringWeeklyHoursSection({
//     Key? key,
//     required this.availability,
//     required this.scheduleId,
//     this.seasonalHours = const {},
//     this.onAvailabilityUpdated,
//   }) : super(key: key);

//   @override
//   _RecurringWeeklyHoursSectionState createState() => _RecurringWeeklyHoursSectionState();
// }

// class _RecurringWeeklyHoursSectionState extends State<RecurringWeeklyHoursSection> {
//   late Map<DateTimeRange, Map<String, dynamic>> seasonalHours;

//   @override
//   void initState() {
//     super.initState();
//     seasonalHours = Map.from(widget.seasonalHours);
//   }

//   void _handleEditSeasonalHours(DateTimeRange dateRange) async {
//     final data = seasonalHours[dateRange];
//     if (data == null) return;

//     final result = await showDialog(
//       context: context,
//       builder: (context) => AddSeasonalHoursModal(
//         initialAvailability: widget.availability,
//         initialNickname: data['nickname'],
//         initialDateRange: dateRange,
//         initialSeasonalAvailability: data['availability'],
//         isEditing: true,
//       ),
//     );

//     if (result != null) {
//       setState(() {
//         seasonalHours.remove(dateRange);
//         seasonalHours[result['dateRange']] = {
//           'nickname': result['nickname'],
//           'availability': result['availability'],
//         };
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'RECURRING WEEKLY HOURS',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textColorSecond,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.help_outline, size: 16),
//                   onPressed: () {},
//                   color: AppColors.textColorSecond,
//                 ),
//               ],
//             ),
//             TextButton(
//               onPressed: () async {
//                 final updatedAvailability = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => EditHoursPage(
//                       initialAvailability: widget.availability,
//                       scheduleId: widget.scheduleId,
//                     ),
//                   ),
//                 );
                
//                 if (updatedAvailability != null && widget.onAvailabilityUpdated != null) {
//                   widget.onAvailabilityUpdated!(updatedAvailability);
//                 }
//               },
//               child: const Text(
//                 'Edit Hours',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             children: [
//               _buildDayRow(context, 'Sunday', widget.availability['Sunday']),
//               _buildDayRow(context, 'Monday', widget.availability['Monday']),
//               _buildDayRow(context, 'Tuesday', widget.availability['Tuesday']),
//               _buildDayRow(context, 'Wednesday', widget.availability['Wednesday']),
//               _buildDayRow(context, 'Thursday', widget.availability['Thursday']),
//               _buildDayRow(context, 'Friday', widget.availability['Friday']),
//               _buildDayRow(context, 'Saturday', widget.availability['Saturday']),
//             ],
//           ),
//         ),
        
//         const SizedBox(height: 32),
        
//         // SeasonalHoursSection(
//         //   seasonalHours: seasonalHours,
//         //   onAdd: () async {
//         //     final result = await showDialog(
//         //       context: context,
//         //       builder: (context) => AddSeasonalHoursModal(
//         //         initialAvailability: widget.availability,
//         //       ),
//         //     );
            
//         //     if (result != null) {
//         //       setState(() {
//         //         seasonalHours[result['dateRange']] = {
//         //           'nickname': result['nickname'],
//         //           'availability': result['availability'],
//         //         };
//         //       });
//         //     }
//         //   },
//         //   onEdit: _handleEditSeasonalHours,
//         //   onDelete: (dateRange) {
//         //     setState(() {
//         //       seasonalHours.remove(dateRange);
//         //     });
//         //   },
//         // ),
// SeasonalHoursSection(
//   scheduleId: widget.scheduleId,
//   onAdd: () async {
//     final result = await showDialog(
//       context: context,
//       builder: (context) => AddSeasonalHoursModal(
//         initialAvailability: widget.availability,
//       ),
//     );
    
//     if (result != null) {
//       // The save will be handled by SeasonalHoursSection itself
//       // We just need to trigger a refresh of the availability
//       if (widget.onAvailabilityUpdated != null) {
//         widget.onAvailabilityUpdated!(result['availability']);
//       }
//     }
//   },
//   onAvailabilityUpdated: (updatedAvailability) {
//     if (widget.onAvailabilityUpdated != null) {
//       widget.onAvailabilityUpdated!(updatedAvailability);
//     }
//   },
// ),
//       ],
//     );
//   }

//   Widget _buildDayRow(BuildContext context, String day, List<TimeRange>? timeRanges) {
//     final isAvailable = timeRanges != null && timeRanges.isNotEmpty;
    
//     // Sort time ranges by start time
//     List<TimeRange>? sortedTimeRanges;
//     if (isAvailable) {
//       sortedTimeRanges = List<TimeRange>.from(timeRanges!);
//       sortedTimeRanges.sort((a, b) {
//         final aMinutes = a.start.hour * 60 + a.start.minute;
//         final bMinutes = b.start.hour * 60 + b.start.minute;
//         return aMinutes.compareTo(bMinutes);
//       });
//     }

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
//         children: [          
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   day,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 if (!isAvailable)
//                   Text(
//                     'Unavailable',
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 14,
//                     ),
//                   ),
//                 if (isAvailable)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: sortedTimeRanges!.map((range) {
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 4),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: Color(AppColors.primaryColor.value).withAlpha(25),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             '${range.start.format(context)} - ${range.end.format(context)}',
//                             style: TextStyle(
//                               color: AppColors.primaryColor,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }













//edit


// lib\content\availability&calender\schedulesTab\recurring_section\recurring_weekly_hours_section.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/recurring_section/edit_hours_page.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/recurring_section/seasonal_hours_section.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/recurring_section/add_seasonal_hours_modal.dart';
// import 'package:tabourak/models/time_range.dart';

// class RecurringWeeklyHoursSection extends StatefulWidget {
//   final Map<String, List<TimeRange>> availability;
//   final Map<DateTimeRange, Map<String, dynamic>> seasonalHours;

//   const RecurringWeeklyHoursSection({
//     Key? key,
//     required this.availability,
//     this.seasonalHours = const {},
//   }) : super(key: key);

//   @override
//   _RecurringWeeklyHoursSectionState createState() => _RecurringWeeklyHoursSectionState();
// }

// class _RecurringWeeklyHoursSectionState extends State<RecurringWeeklyHoursSection> {
//   late Map<DateTimeRange, Map<String, dynamic>> seasonalHours;

//   @override
//   void initState() {
//     super.initState();
//     seasonalHours = Map.from(widget.seasonalHours);
//   }

//   void _handleEditSeasonalHours(DateTimeRange dateRange) async {
//     final data = seasonalHours[dateRange];
//     if (data == null) return;

//     final result = await showDialog(
//       context: context,
//       builder: (context) => AddSeasonalHoursModal(
//         initialAvailability: widget.availability,
//         initialNickname: data['nickname'],
//         initialDateRange: dateRange,
//         initialSeasonalAvailability: data['availability'],
//         isEditing: true,
//       ),
//     );

//     if (result != null) {
//       setState(() {
//         // Remove old entry and add updated one
//         seasonalHours.remove(dateRange);
//         seasonalHours[result['dateRange']] = {
//           'nickname': result['nickname'],
//           'availability': result['availability'],
//         };
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'RECURRING WEEKLY HOURS',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textColorSecond,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.help_outline, size: 16),
//                   onPressed: () {},
//                   color: AppColors.textColorSecond,
//                 ),
//               ],
//             ),
//             TextButton(
//               onPressed: () async {
//                 final updatedAvailability = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => EditHoursPage(
//                       initialAvailability: widget.availability,
//                     ),
//                   ),
//                 );
                
//                 if (updatedAvailability != null) {
//                   // Handle the updated availability if needed
//                 }
//               },
//               child: const Text(
//                 'Edit Hours',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             children: [
//               _buildDayRow(context, 'Sunday', widget.availability['Sunday']),
//               _buildDayRow(context, 'Monday', widget.availability['Monday']),
//               _buildDayRow(context, 'Tuesday', widget.availability['Tuesday']),
//               _buildDayRow(context, 'Wednesday', widget.availability['Wednesday']),
//               _buildDayRow(context, 'Thursday', widget.availability['Thursday']),
//               _buildDayRow(context, 'Friday', widget.availability['Friday']),
//               _buildDayRow(context, 'Saturday', widget.availability['Saturday']),
//             ],
//           ),
//         ),
        
//         const SizedBox(height: 32),
        
//         SeasonalHoursSection(
//           seasonalHours: seasonalHours,
//           onAdd: () async {
//             final result = await showDialog(
//               context: context,
//               builder: (context) => AddSeasonalHoursModal(
//                 initialAvailability: widget.availability,
//               ),
//             );
            
//             if (result != null) {
//               setState(() {
//                 seasonalHours[result['dateRange']] = {
//                   'nickname': result['nickname'],
//                   'availability': result['availability'],
//                 };
//               });
//             }
//           },
//           onEdit: _handleEditSeasonalHours,
//           onDelete: (dateRange) {
//             setState(() {
//               seasonalHours.remove(dateRange);
//             });
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildDayRow(BuildContext context, String day, List<TimeRange>? timeRanges) {
//     final isAvailable = timeRanges != null && timeRanges.isNotEmpty;
//     final timeText = isAvailable 
//         ? '${timeRanges!.first.start.format(context)} - ${timeRanges.first.end.format(context)}'
//         : 'Unavailable';

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
//         children: [          
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   day,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 if (isAvailable)
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       timeText,
//                       style: TextStyle(
//                         color: AppColors.primaryColor,
//                         fontSize: 14,
//                       ),
//                     ),
//                   )
//                 else
//                   Text(
//                     timeText,
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 14,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }







// // lib\content\availability&calender\schedulesTab\recurring_section\recurring_weekly_hours_section.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/recurring_section/edit_hours_page.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/recurring_section/seasonal_hours_section.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/recurring_section/add_seasonal_hours_modal.dart';
// import 'package:tabourak/models/time_range.dart';

// class RecurringWeeklyHoursSection extends StatefulWidget {
//   final Map<String, List<TimeRange>> availability;
//   final Map<DateTimeRange, Map<String, dynamic>> seasonalHours;

//   const RecurringWeeklyHoursSection({
//     Key? key,
//     required this.availability,
//     this.seasonalHours = const {},
//   }) : super(key: key);

//   @override
//   _RecurringWeeklyHoursSectionState createState() => _RecurringWeeklyHoursSectionState();
// }

// class _RecurringWeeklyHoursSectionState extends State<RecurringWeeklyHoursSection> {
//   late Map<DateTimeRange, Map<String, dynamic>> seasonalHours;

//   @override
//   void initState() {
//     super.initState();
//     seasonalHours = Map.from(widget.seasonalHours);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'RECURRING WEEKLY HOURS',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textColorSecond,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.help_outline, size: 16),
//                   onPressed: () {},
//                   color: AppColors.textColorSecond,
//                 ),
//               ],
//             ),
//             TextButton(
//               onPressed: () async {
//                 final updatedAvailability = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => EditHoursPage(
//                       initialAvailability: widget.availability,
//                     ),
//                   ),
//                 );
                
//                 if (updatedAvailability != null) {
//                   // Handle the updated availability if needed
//                 }
//               },
//               child: const Text(
//                 'Edit Hours',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             children: [
//               _buildDayRow(context, 'Sunday', widget.availability['Sunday']),
//               _buildDayRow(context, 'Monday', widget.availability['Monday']),
//               _buildDayRow(context, 'Tuesday', widget.availability['Tuesday']),
//               _buildDayRow(context, 'Wednesday', widget.availability['Wednesday']),
//               _buildDayRow(context, 'Thursday', widget.availability['Thursday']),
//               _buildDayRow(context, 'Friday', widget.availability['Friday']),
//               _buildDayRow(context, 'Saturday', widget.availability['Saturday']),
//             ],
//           ),
//         ),
        
//         const SizedBox(height: 32),
        
//         SeasonalHoursSection(
//           seasonalHours: seasonalHours,
//           onAdd: () async {
//             final result = await showDialog(
//               context: context,
//               builder: (context) => AddSeasonalHoursModal(
//                 initialAvailability: widget.availability,
//               ),
//             );
            
//             if (result != null) {
//               setState(() {
//                 seasonalHours[result['dateRange']] = {
//                   'nickname': result['nickname'],
//                   'availability': result['availability'],
//                 };
//               });
//             }
//           },
//           onEdit: (dateRange) {
//             // Handle edit functionality
//           },
//           onDelete: (dateRange) {
//             setState(() {
//               seasonalHours.remove(dateRange);
//             });
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildDayRow(BuildContext context, String day, List<TimeRange>? timeRanges) {
//     final isAvailable = timeRanges != null && timeRanges.isNotEmpty;
//     final timeText = isAvailable 
//         ? '${timeRanges!.first.start.format(context)} - ${timeRanges.first.end.format(context)}'
//         : 'Unavailable';

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
//         children: [          
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   day,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 if (isAvailable)
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       timeText,
//                       style: TextStyle(
//                         color: AppColors.primaryColor,
//                         fontSize: 14,
//                       ),
//                     ),
//                   )
//                 else
//                   Text(
//                     timeText,
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 14,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }





// lib\content\availability&calender\schedulesTab\recurring_section\recurring_weekly_hours_section.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/recurring_section/edit_hours_page.dart';
// import 'package:tabourak/content/availability&calender/schedulesTab/recurring_section/add_seasonal_hours_modal.dart';
// import 'package:tabourak/models/time_range.dart';

// class RecurringWeeklyHoursSection extends StatelessWidget {
//   final Map<String, List<TimeRange>> availability;

//   const RecurringWeeklyHoursSection({
//     Key? key,
//     required this.availability,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'RECURRING WEEKLY HOURS',
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
//             TextButton(
//               onPressed: () async {
//                 final updatedAvailability = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => EditHoursPage(
//                       initialAvailability: availability,
//                     ),
//                   ),
//                 );
                
//                 if (updatedAvailability != null) {
//                   // Handle the updated availability if needed
//                 }
//               },
//               child: const Text(
//                 'Edit Hours',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             children: [
//               _buildDayRow(context, 'Sunday', availability['Sunday']),
//               _buildDayRow(context, 'Monday', availability['Monday']),
//               _buildDayRow(context, 'Tuesday', availability['Tuesday']),
//               _buildDayRow(context, 'Wednesday', availability['Wednesday']),
//               _buildDayRow(context, 'Thursday', availability['Thursday']),
//               _buildDayRow(context, 'Friday', availability['Friday']),
//               _buildDayRow(context, 'Saturday', availability['Saturday']),
//             ],
//           ),
//         ),
        
//         const SizedBox(height: 16),
        
//         TextButton(
//           onPressed: () {
//             showDialog(
//               context: context,
//               builder: (context) => AddSeasonalHoursModal(
//                 initialAvailability: availability,
//               ),
//             );
//           },
//           child: const Text(
//             'Add Seasonal Hours',
//             style: TextStyle(
//               color: AppColors.primaryColor,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDayRow(BuildContext context, String day, List<TimeRange>? timeRanges) {
//     final isAvailable = timeRanges != null && timeRanges.isNotEmpty;
//     final timeText = isAvailable 
//         ? '${timeRanges!.first.start.format(context)} - ${timeRanges.first.end.format(context)}'
//         : 'Unavailable';

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
//         children: [          
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   day,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 if (isAvailable)
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       timeText,
//                       style: TextStyle(
//                         color: AppColors.primaryColor,
//                         fontSize: 14,
//                       ),
//                     ),
//                   )
//                 else
//                   Text(
//                     timeText,
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 14,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }







// // lib/content/availability/widgets/recurring_weekly_hours_section.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/content/availability/edit_hours_page.dart';
// import 'package:tabourak/models/time_range.dart';

// class RecurringWeeklyHoursSection extends StatelessWidget {
//   final Map<String, List<TimeRange>> availability;

//   const RecurringWeeklyHoursSection({
//     Key? key,
//     required this.availability,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'RECURRING WEEKLY HOURS',
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
//             TextButton(
//               onPressed: () async {
//                 final updatedAvailability = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => EditHoursPage(
//                       initialAvailability: availability,
//                     ),
//                   ),
//                 );
                
//                 if (updatedAvailability != null) {
//                   // Handle the updated availability if needed
//                   // You might want to pass a callback to update the parent state
//                 }
//               },
//               child: const Text(
//                 'Edit Hours',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             children: [
//               _buildDayRow(context, 'Monday', availability['Monday']),
//               _buildDayRow(context, 'Tuesday', availability['Tuesday']),
//               _buildDayRow(context, 'Wednesday', availability['Wednesday']),
//               _buildDayRow(context, 'Thursday', availability['Thursday']),
//               _buildDayRow(context, 'Friday', availability['Friday']),
//               _buildDayRow(context, 'Saturday', availability['Saturday']),
//               _buildDayRow(context, 'Sunday', availability['Sunday']),
//             ],
//           ),
//         ),
        
//         const SizedBox(height: 16),
        
//         TextButton(
//           onPressed: () {},
//           child: const Text(
//             'Add Seasonal Hours',
//             style: TextStyle(
//               color: AppColors.primaryColor,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDayRow(BuildContext context, String day, List<TimeRange>? timeRanges) {
//     final isAvailable = timeRanges != null && timeRanges.isNotEmpty;
//     final timeText = isAvailable 
//         ? '${timeRanges.first.start.format(context)} - ${timeRanges.first.end.format(context)}'
//         : 'Unavailable';

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
//         children: [          
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   day,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 if (isAvailable)
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       timeText,
//                       style: TextStyle(
//                         color: AppColors.primaryColor,
//                         fontSize: 14,
//                       ),
//                     ),
//                   )
//                 else
//                   Text(
//                     timeText,
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 14,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

