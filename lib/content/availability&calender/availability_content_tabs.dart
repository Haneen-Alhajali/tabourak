// lib\content\availability&calender\availability_content_tabs.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'schedulesTab/schedule_manager_section.dart';
import 'schedulesTab/recurring_section/recurring_weekly_hours_section.dart';
import 'schedulesTab/date_section/date_specific_hours_section.dart';
import 'widgets/meeting_limits_content.dart';
import 'widgets/calendars_content.dart';
import 'package:tabourak/models/time_range.dart';

class AvailabilityContent extends StatefulWidget {
  const AvailabilityContent({Key? key}) : super(key: key);

  @override
  _AvailabilityContentState createState() => _AvailabilityContentState();
}

class _AvailabilityContentState extends State<AvailabilityContent> {
  String _selectedTab = 'Schedules';
  Map<String, List<TimeRange>> _availability = {};
  Map<String, dynamic>? _selectedSchedule;

  @override
  void initState() {
    super.initState();
    // Initialize with empty availability
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    for (final day in days) {
      _availability[day] = [];
    }
  }

  void _handleScheduleSelected(Map<String, dynamic> schedule, Map<String, List<TimeRange>> availability) {
    setState(() {
      _selectedSchedule = schedule;
      _availability = availability;
      // Ensure all days are present
      const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      for (final day in days) {
        _availability.putIfAbsent(day, () => []);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Availability & Calendars',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),

          Container(
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
                _buildTab('Schedules', Icons.schedule),
                _buildTab('Calendars', Icons.calendar_today),
                _buildTab('Meeting Limits', Icons.lock_clock),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // if (_selectedTab == 'Schedules')
          //   Column(
          //     children: [
          //       ScheduleManagerSection(
          //         onScheduleSelected: _handleScheduleSelected,
          //       ),
          //       const SizedBox(height: 32),
          //       if (_selectedSchedule != null && _selectedSchedule!['id'] != null)
          //         RecurringWeeklyHoursSection(
          //           availability: _availability,
          //           scheduleId: _selectedSchedule!['id'].toString(),
          //           onAvailabilityUpdated: (updatedAvailability) {
          //             setState(() {
          //               _availability = updatedAvailability;
          //             });
          //           },
          //         ),
          //       const SizedBox(height: 32),
          //       DateSpecificHoursSection(),
          //     ],
          //   ),
if (_selectedTab == 'Schedules')
  Column(
    children: [
      ScheduleManagerSection(
        onScheduleSelected: _handleScheduleSelected,
      ),
      const SizedBox(height: 32),
      if (_selectedSchedule != null && _selectedSchedule!['id'] != null)
        RecurringWeeklyHoursSection(
          availability: _availability,
          scheduleId: _selectedSchedule!['id'].toString(),
          onAvailabilityUpdated: (updatedAvailability) {
            setState(() {
              _availability = updatedAvailability;
            });
          },
        ),
      const SizedBox(height: 32),
      DateSpecificHoursSection(
        scheduleId: _selectedSchedule?['id']?.toString(),
      ),
    ],
  ),
          if (_selectedTab == 'Calendars')
            const CalendarsContent(),
          if (_selectedTab == 'Meeting Limits')
            const MeetingLimitsContent(),
        ],
      ),
    );
  }

  Widget _buildTab(String title, IconData icon) {
    final bool isActive = _selectedTab == title;
    return Flexible(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? AppColors.primaryColor : AppColors.textColorSecond,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? AppColors.primaryColor : AppColors.textColorSecond,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



//edit2 for add seasonal




// // lib\content\availability&calender\availability_content_tabs.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'schedulesTab/schedule_manager_section.dart';
// import 'schedulesTab/recurring_section/recurring_weekly_hours_section.dart';
// import 'schedulesTab/date_section/date_specific_hours_section.dart';
// import 'widgets/meeting_limits_content.dart';
// import 'widgets/calendars_content.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'package:intl/intl.dart';

// class AvailabilityContent extends StatefulWidget {
//   const AvailabilityContent({Key? key}) : super(key: key);

//   @override
//   _AvailabilityContentState createState() => _AvailabilityContentState();
// }

// class _AvailabilityContentState extends State<AvailabilityContent> {
//   String _selectedTab = 'Schedules';
//   Map<String, List<TimeRange>> _availability = {};
//   Map<String, dynamic>? _selectedSchedule;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize with empty availability
//     const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
//     for (final day in days) {
//       _availability[day] = [];
//     }
//   }

//   final Map<DateTimeRange, Map<String, dynamic>> seasonalHours = {
//     DateTimeRange(
//       start: DateTime(2023, 12, 25),
//       end: DateTime(2023, 12, 31),
//     ): {
//       'nickname': 'Holiday Hours',
//       'availability': {
//         "Sunday": [TimeRange(TimeOfDay(hour: 10, minute: 0), TimeOfDay(hour: 14, minute: 0))],
//         "Monday": [TimeRange(TimeOfDay(hour: 10, minute: 0), TimeOfDay(hour: 14, minute: 0))],
//       },
//     },
//     DateTimeRange(
//       start: DateTime(2024, 1, 1),
//       end: DateTime(2024, 1, 7),
//     ): {
//       'nickname': 'New Year Hours',
//       'availability': {
//         "Sunday": [TimeRange(TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 16, minute: 0))],
//         "Monday": [TimeRange(TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 16, minute: 0))],
//       },
//     },
//   };

//   void _handleScheduleSelected(Map<String, dynamic> schedule, Map<String, List<TimeRange>> availability) {
//     setState(() {
//       _selectedSchedule = schedule;
//       _availability = availability;
//       // Ensure all days are present
//       const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
//       for (final day in days) {
//         _availability.putIfAbsent(day, () => []);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Availability & Calendars',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textColor,
//             ),
//           ),
//           const SizedBox(height: 16),

//           Container(
//             decoration: BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(
//                   color: Colors.grey.shade300,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: Row(
//               children: [
//                 _buildTab('Schedules', Icons.schedule),
//                 _buildTab('Calendars', Icons.calendar_today),
//                 _buildTab('Meeting Limits', Icons.lock_clock),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),

//           if (_selectedTab == 'Schedules')
//             Column(
//               children: [
//                 ScheduleManagerSection(
//                   onScheduleSelected: _handleScheduleSelected,
//                 ),
//                 const SizedBox(height: 32),
//                 // RecurringWeeklyHoursSection(
//                 //   availability: _availability,
//                 //   scheduleId: _selectedSchedule?['id']?.toString() ?? '',
//                 //   seasonalHours: seasonalHours,
//                 //   onAvailabilityUpdated: (updatedAvailability) {
//                 //     setState(() {
//                 //       _availability = updatedAvailability;
//                 //     });
//                 //   },
//                 // ),
// if (_selectedSchedule != null && _selectedSchedule!['id'] != null)
//   RecurringWeeklyHoursSection(
//     availability: _availability,
//     scheduleId: _selectedSchedule!['id'].toString(),
//     seasonalHours: seasonalHours,
//     onAvailabilityUpdated: (updatedAvailability) {
//       setState(() {
//         _availability = updatedAvailability;
//       });
//     },
//   ),

//                 const SizedBox(height: 32),
//                 DateSpecificHoursSection(),
//               ],
//             ),
//           if (_selectedTab == 'Calendars')
//             const CalendarsContent(),
//           if (_selectedTab == 'Meeting Limits')
//             const MeetingLimitsContent(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTab(String title, IconData icon) {
//     final bool isActive = _selectedTab == title;
//     return Flexible(
//       child: InkWell(
//         onTap: () {
//           setState(() {
//             _selectedTab = title;
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: isActive ? AppColors.primaryColor : Colors.transparent,
//                 width: 2,
//               ),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 20,
//                 color: isActive ? AppColors.primaryColor : AppColors.textColorSecond,
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                   color: isActive ? AppColors.primaryColor : AppColors.textColorSecond,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }









// edit 


// // lib\content\availability&calender\availability_content_tabs.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'schedulesTab/schedule_manager_section.dart';
// import 'schedulesTab/recurring_section/recurring_weekly_hours_section.dart';
// import 'schedulesTab/date_section/date_specific_hours_section.dart';
// import 'widgets/meeting_limits_content.dart';
// import 'widgets/calendars_content.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'package:intl/intl.dart';

// class AvailabilityContent extends StatefulWidget {
//   const AvailabilityContent({Key? key}) : super(key: key);

//   @override
//   _AvailabilityContentState createState() => _AvailabilityContentState();
// }

// class _AvailabilityContentState extends State<AvailabilityContent> {
//   String _selectedTab = 'Schedules';
//   final Map<String, List<TimeRange>> availability = {
//     "Sunday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Monday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Tuesday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Wednesday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Thursday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Friday": [],
//     "Saturday": [],
//   };

//   final Map<DateTimeRange, Map<String, dynamic>> seasonalHours = {
//     DateTimeRange(
//       start: DateTime(2023, 12, 25),
//       end: DateTime(2023, 12, 31),
//     ): {
//       'nickname': 'Holiday Hours',
//       'availability': {
//         "Sunday": [TimeRange(TimeOfDay(hour: 10, minute: 0), TimeOfDay(hour: 14, minute: 0))],
//         "Monday": [TimeRange(TimeOfDay(hour: 10, minute: 0), TimeOfDay(hour: 14, minute: 0))],
//       },
//     },
//     DateTimeRange(
//       start: DateTime(2024, 1, 1),
//       end: DateTime(2024, 1, 7),
//     ): {
//       'nickname': 'New Year Hours',
//       'availability': {
//         "Sunday": [TimeRange(TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 16, minute: 0))],
//         "Monday": [TimeRange(TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 16, minute: 0))],
//       },
//     },
//   };

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Availability & Calendars',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textColor,
//             ),
//           ),
//           const SizedBox(height: 16),

//           Container(
//             decoration: BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(
//                   color: Colors.grey.shade300,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: Row(
//               children: [
//                 _buildTab('Schedules', Icons.schedule),
//                 _buildTab('Calendars', Icons.calendar_today),
//                 _buildTab('Meeting Limits', Icons.lock_clock),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),

//           if (_selectedTab == 'Schedules')
//             Column(
//               children: [
//                 const ScheduleManagerSection(),
//                 const SizedBox(height: 32),
//                 RecurringWeeklyHoursSection(
//                   availability: availability,
//                   seasonalHours: seasonalHours,
//                 ),
//                 const SizedBox(height: 32),
//                 DateSpecificHoursSection(), // Removed const here
//               ],
//             ),
//           if (_selectedTab == 'Calendars')
//             const CalendarsContent(),
//           if (_selectedTab == 'Meeting Limits')
//             const MeetingLimitsContent(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTab(String title, IconData icon) {
//     final bool isActive = _selectedTab == title;
//     return Flexible(
//       child: InkWell(
//         onTap: () {
//           setState(() {
//             _selectedTab = title;
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: isActive ? AppColors.primaryColor : Colors.transparent,
//                 width: 2,
//               ),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 20,
//                 color: isActive ? AppColors.primaryColor : AppColors.textColorSecond,
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                   color: isActive ? AppColors.primaryColor : AppColors.textColorSecond,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }








// lib\content\availability&calender\availability_content_tabs.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'schedulesTab/schedule_manager_section.dart';
// import 'schedulesTab/recurring_section/recurring_weekly_hours_section.dart';
// import 'schedulesTab/date_section/date_specific_hours_section.dart';
// import 'widgets/meeting_limits_content.dart';
// import 'widgets/calendars_content.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'package:intl/intl.dart';

// class AvailabilityContent extends StatefulWidget {
//   const AvailabilityContent({Key? key}) : super(key: key);

//   @override
//   _AvailabilityContentState createState() => _AvailabilityContentState();
// }

// class _AvailabilityContentState extends State<AvailabilityContent> {
//   String _selectedTab = 'Schedules';
//   final Map<String, List<TimeRange>> availability = {
//     "Sunday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Monday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Tuesday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Wednesday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Thursday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Friday": [],
//     "Saturday": [],
//   };

//   final Map<DateTimeRange, Map<String, dynamic>> seasonalHours = {
//     DateTimeRange(
//       start: DateTime(2023, 12, 25),
//       end: DateTime(2023, 12, 31),
//     ): {
//       'nickname': 'Holiday Hours',
//       'availability': {
//         "Sunday": [TimeRange(TimeOfDay(hour: 10, minute: 0), TimeOfDay(hour: 14, minute: 0))],
//         "Monday": [TimeRange(TimeOfDay(hour: 10, minute: 0), TimeOfDay(hour: 14, minute: 0))],
//       },
//     },
//     DateTimeRange(
//       start: DateTime(2024, 1, 1),
//       end: DateTime(2024, 1, 7),
//     ): {
//       'nickname': 'New Year Hours',
//       'availability': {
//         "Sunday": [TimeRange(TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 16, minute: 0))],
//         "Monday": [TimeRange(TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 16, minute: 0))],
//       },
//     },
//   };

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Availability & Calendars',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textColor,
//             ),
//           ),
//           const SizedBox(height: 16),

//           Container(
//             decoration: BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(
//                   color: Colors.grey.shade300,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: Row(
//               children: [
//                 _buildTab('Schedules', Icons.schedule),
//                 _buildTab('Calendars', Icons.calendar_today),
//                 _buildTab('Meeting Limits', Icons.lock_clock),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),

//           if (_selectedTab == 'Schedules')
//             Column(
//               children: [
//                 const ScheduleManagerSection(),
//                 const SizedBox(height: 32),
//                 RecurringWeeklyHoursSection(
//                   availability: availability,
//                   seasonalHours: seasonalHours,
//                 ),
//                 const SizedBox(height: 32),
//                 DateSpecificHoursSection(), // Removed const here
//               ],
//             ),
//           if (_selectedTab == 'Calendars')
//             const CalendarsContent(),
//           if (_selectedTab == 'Meeting Limits')
//             const MeetingLimitsContent(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTab(String title, IconData icon) {
//     final bool isActive = _selectedTab == title;
//     return Flexible(
//       child: InkWell(
//         onTap: () {
//           setState(() {
//             _selectedTab = title;
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: isActive ? AppColors.primaryColor : Colors.transparent,
//                 width: 2,
//               ),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 20,
//                 color: isActive ? AppColors.primaryColor : AppColors.textColorSecond,
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                   color: isActive ? AppColors.primaryColor : AppColors.textColorSecond,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// // lib\content\availability&calender\availability_content_tabs.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'schedulesTab/schedule_manager_section.dart';
// import 'schedulesTab/recurring_section/recurring_weekly_hours_section.dart';
// import 'schedulesTab/date_section/date_specific_hours_section.dart';
// import 'widgets/meeting_limits_content.dart';
// import 'widgets/calendars_content.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'package:intl/intl.dart';

// class AvailabilityContent extends StatefulWidget {
//   const AvailabilityContent({Key? key}) : super(key: key);

//   @override
//   _AvailabilityContentState createState() => _AvailabilityContentState();
// }

// class _AvailabilityContentState extends State<AvailabilityContent> {
//   String _selectedTab = 'Schedules';
//   final Map<String, List<TimeRange>> availability = {
//     "Sunday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Monday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Tuesday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Wednesday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Thursday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Friday": [],
//     "Saturday": [],
//   };

//   final Map<DateTimeRange, Map<String, dynamic>> seasonalHours = {
//     DateTimeRange(
//       start: DateTime(2023, 12, 25),
//       end: DateTime(2023, 12, 31),
//     ): {
//       'nickname': 'Holiday Hours',
//       'availability': {
//         "Sunday": [TimeRange(TimeOfDay(hour: 10, minute: 0), TimeOfDay(hour: 14, minute: 0))],
//         "Monday": [TimeRange(TimeOfDay(hour: 10, minute: 0), TimeOfDay(hour: 14, minute: 0))],
//       },
//     },
//     DateTimeRange(
//       start: DateTime(2024, 1, 1),
//       end: DateTime(2024, 1, 7),
//     ): {
//       'nickname': 'New Year Hours',
//       'availability': {
//         "Sunday": [TimeRange(TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 16, minute: 0))],
//         "Monday": [TimeRange(TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 16, minute: 0))],
//       },
//     },
//   };

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Availability & Calendars',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textColor,
//             ),
//           ),
//           const SizedBox(height: 16),

//           Container(
//             decoration: BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(
//                   color: Colors.grey.shade300,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: Row(
//               children: [
//                 _buildTab('Schedules', Icons.schedule),
//                 _buildTab('Calendars', Icons.calendar_today),
//                 _buildTab('Meeting Limits', Icons.lock_clock),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),

//           if (_selectedTab == 'Schedules')
//             Column(
//               children: [
//                 const ScheduleManagerSection(),
//                 const SizedBox(height: 32),
//                 RecurringWeeklyHoursSection(
//                   availability: availability,
//                   seasonalHours: seasonalHours,
//                 ),
//                 const SizedBox(height: 32),
//                 const DateSpecificHoursSection(),
//               ],
//             ),
//           if (_selectedTab == 'Calendars')
//             const CalendarsContent(),
//           if (_selectedTab == 'Meeting Limits')
//             const MeetingLimitsContent(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTab(String title, IconData icon) {
//     final bool isActive = _selectedTab == title;
//     return Flexible(
//       child: InkWell(
//         onTap: () {
//           setState(() {
//             _selectedTab = title;
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: isActive ? AppColors.primaryColor : Colors.transparent,
//                 width: 2,
//               ),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 20,
//                 color: isActive ? AppColors.primaryColor : AppColors.textColorSecond,
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                   color: isActive ? AppColors.primaryColor : AppColors.textColorSecond,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }







// // lib\content\availability&calender\availability_content_tabs.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'schedulesTab/schedule_manager_section.dart';
// import 'schedulesTab/recurring_section/recurring_weekly_hours_section.dart';
// import 'schedulesTab/date_section/date_specific_hours_section.dart';
// import 'widgets/meeting_limits_content.dart';
// import 'widgets/calendars_content.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'package:intl/intl.dart';

// class AvailabilityContent extends StatefulWidget {
//   const AvailabilityContent({Key? key}) : super(key: key);

//   @override
//   _AvailabilityContentState createState() => _AvailabilityContentState();
// }

// class _AvailabilityContentState extends State<AvailabilityContent> {
//   String _selectedTab = 'Schedules';
//   final Map<String, List<TimeRange>> availability = {
//     "Sunday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Monday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Tuesday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Wednesday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Thursday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Friday": [],
//     "Saturday": [],
//   };

//   // Add seasonal hours data
//   final Map<DateTime, List<TimeRange>> seasonalHours = {
//     DateTime(2023, 12, 25): [TimeRange(TimeOfDay(hour: 10, minute: 0), TimeOfDay(hour: 14, minute: 0))],
//     DateTime(2024, 1, 1): [TimeRange(TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 16, minute: 0))],
//   };

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Availability & Calendars',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textColor,
//             ),
//           ),
//           const SizedBox(height: 16),

//           Container(
//             decoration: BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(
//                   color: Colors.grey.shade300,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: Row(
//               children: [
//                 _buildTab('Schedules', Icons.schedule),
//                 _buildTab('Calendars', Icons.calendar_today),
//                 _buildTab('Meeting Limits', Icons.lock_clock),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),

//           if (_selectedTab == 'Schedules')
//             Column(
//               children: [
//                 const ScheduleManagerSection(),
//                 const SizedBox(height: 32),
//                 RecurringWeeklyHoursSection(
//                   availability: availability,
//                 ),
//                 const SizedBox(height: 32),
//                 const DateSpecificHoursSection(),
//               ],
//             ),
//           if (_selectedTab == 'Calendars')
//             const CalendarsContent(),
//           if (_selectedTab == 'Meeting Limits')
//             const MeetingLimitsContent(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTab(String title, IconData icon) {
//     final bool isActive = _selectedTab == title;
//     return Flexible(
//       child: InkWell(
//         onTap: () {
//           setState(() {
//             _selectedTab = title;
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: isActive ? AppColors.primaryColor : Colors.transparent,
//                 width: 2,
//               ),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 20,
//                 color: isActive ? AppColors.primaryColor : AppColors.textColorSecond,
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                   color: isActive ? AppColors.primaryColor : AppColors.textColorSecond,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }








// // lib/content/availability/availability_content.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'widgets/schedule_manager_section.dart';
// import 'widgets/recurring_weekly_hours_section.dart';
// import 'widgets/date_specific_hours_section.dart';
// import 'widgets/meeting_limits_content.dart';
// import 'widgets/calendars_content.dart';
// import 'package:tabourak/models/time_range.dart';

// class AvailabilityContent extends StatefulWidget {
//   const AvailabilityContent({Key? key}) : super(key: key);

//   @override
//   _AvailabilityContentState createState() => _AvailabilityContentState();
// }

// class _AvailabilityContentState extends State<AvailabilityContent> {
//   String _selectedTab = 'Schedules';
//   final Map<String, List<TimeRange>> availability = {
//     "Sunday": [],
//     "Monday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Tuesday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Wednesday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Thursday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Friday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
//     "Saturday": [],
//   };

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Availability & Calendars',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textColor,
//             ),
//           ),
//           const SizedBox(height: 16),

//           Container(
//             decoration: BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(
//                   color: Colors.grey.shade300,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: Row(
//               children: [
//                 _buildTab('Schedules', Icons.schedule),
//                 _buildTab('Calendars', Icons.calendar_today),
//                 _buildTab('Meeting Limits', Icons.lock_clock),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),

//           if (_selectedTab == 'Schedules')
//             Column(
//               children: [
//                 const ScheduleManagerSection(),
//                 const SizedBox(height: 32),
//                 RecurringWeeklyHoursSection(availability: availability),
//                 const SizedBox(height: 32),
//                 const DateSpecificHoursSection(),
//               ],
//             ),
//           if (_selectedTab == 'Calendars')
//             const CalendarsContent(),
//           if (_selectedTab == 'Meeting Limits')
//             const MeetingLimitsContent(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTab(String title, IconData icon) {
//     final bool isActive = _selectedTab == title;
//     return Flexible(
//       child: InkWell(
//         onTap: () {
//           setState(() {
//             _selectedTab = title;
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: isActive ? AppColors.primaryColor : Colors.transparent,
//                 width: 2,
//               ),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 20,
//                 color: isActive ? AppColors.primaryColor : AppColors.textColorSecond,
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                   color: isActive ? AppColors.primaryColor : AppColors.textColorSecond,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }






// // lib\content\availability\availability_content.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'widgets/schedule_manager_section.dart';
// import 'widgets/recurring_weekly_hours_section.dart';
// import 'widgets/date_specific_hours_section.dart';
// import 'widgets/meeting_limits_content.dart';
// import 'widgets/calendars_content.dart';

// class AvailabilityContent extends StatefulWidget {
//   const AvailabilityContent({Key? key}) : super(key: key);

//   @override
//   _AvailabilityContentState createState() => _AvailabilityContentState();
// }

// class _AvailabilityContentState extends State<AvailabilityContent> {
//   String _selectedTab = 'Schedules';

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header
//         const Text(
//           'Availability & Calendars',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: AppColors.textColor
//           ),
//         ),
//         const SizedBox(height: 16),

//         // Tabs
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildTab(Icons.schedule, 'Schedules'),
//             _buildTab(Icons.calendar_today, 'Calendars'),
//             _buildTab(Icons.shield, 'Meeting Limits'), // Updated icon
//           ],
//         ),

//         // Divider Line exactly under the blue line
//         Container(
//           height: 2,
//           color: Colors.grey[300],
//         ),
//         const SizedBox(height: 16),

//         // Dynamic Content
//         if (_selectedTab == 'Schedules')
//           Column(
//             children: const [
//               ScheduleManagerSection(),
//               SizedBox(height: 24),
//               RecurringWeeklyHoursSection(),
//               SizedBox(height: 24),
//               DateSpecificHoursSection(),
//             ],
//           ),
//         if (_selectedTab == 'Calendars')
//           const CalendarsContent(), // Use the new CalendarsContent file
//         if (_selectedTab == 'Meeting Limits')
//           const MeetingLimitsContent(),
//       ],
//     );
//   }

//   Widget _buildTab(IconData icon, String title) {
//     final bool isActive = _selectedTab == title;
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedTab = title;
//         });
//       },
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: isActive ? AppColors.primaryColor : AppColors.textColorSecond, size: 20), // Smaller icons
//               const SizedBox(width: 4),
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: isActive ?  AppColors.primaryColor : AppColors.textColorSecond,
//                   fontSize: 14, // Smaller font size
//                   fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 2),
//           if (isActive)
//             Container(
//               width: title.length * 8.5, // Adjust width based on title length
//               height: 2,
//               color:  AppColors.primaryColor,
//             ),
//         ],
//       ),
//     );
//   }
// }
