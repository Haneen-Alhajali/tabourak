// lib/content/availability/widgets/recurring_weekly_hours_section.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/content/availability&calender/schedulesTab/recurring_section/edit_hours_page.dart';
import 'package:tabourak/content/availability&calender/schedulesTab/recurring_section/add_seasonal_hours_modal.dart';
import 'package:tabourak/models/time_range.dart';

class RecurringWeeklyHoursSection extends StatelessWidget {
  final Map<String, List<TimeRange>> availability;

  const RecurringWeeklyHoursSection({
    Key? key,
    required this.availability,
  }) : super(key: key);

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
                  color: AppColors.textColorSecond,
                  onPressed: () {},
                ),
              ],
            ),
            TextButton(
              onPressed: () async {
                final updatedAvailability = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditHoursPage(
                      initialAvailability: availability,
                    ),
                  ),
                );
                
                if (updatedAvailability != null) {
                  // Handle the updated availability if needed
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
              _buildDayRow(context, 'Sunday', availability['Sunday']),
              _buildDayRow(context, 'Monday', availability['Monday']),
              _buildDayRow(context, 'Tuesday', availability['Tuesday']),
              _buildDayRow(context, 'Wednesday', availability['Wednesday']),
              _buildDayRow(context, 'Thursday', availability['Thursday']),
              _buildDayRow(context, 'Friday', availability['Friday']),
              _buildDayRow(context, 'Saturday', availability['Saturday']),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddSeasonalHoursModal(
                initialAvailability: availability,
              ),
            );
          },
          child: const Text(
            'Add Seasonal Hours',
            style: TextStyle(
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayRow(BuildContext context, String day, List<TimeRange>? timeRanges) {
    final isAvailable = timeRanges != null && timeRanges.isNotEmpty;
    final timeText = isAvailable 
        ? '${timeRanges!.first.start.format(context)} - ${timeRanges.first.end.format(context)}'
        : 'Unavailable';

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
                if (isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      timeText,
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  Text(
                    timeText,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

