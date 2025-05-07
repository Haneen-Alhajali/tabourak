// lib/content/availability/widgets/schedule_manager_section.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/content/availability&calender/schedulesTab/create_schedule_modal.dart';
import 'package:tabourak/content/availability&calender/schedulesTab/edit_schedule_modal.dart';

class ScheduleManagerSection extends StatefulWidget {
  const ScheduleManagerSection({Key? key}) : super(key: key);

  @override
  State<ScheduleManagerSection> createState() => _ScheduleManagerSectionState();
}

class _ScheduleManagerSectionState extends State<ScheduleManagerSection> {
  String? _selectedSchedule;
  final List<String> _schedules = [
    'My Availability (default)',
    'Work Hours',
    'Weekend Availability',
    'Custom Schedule'
  ];

  @override
  void initState() {
    super.initState();
    _selectedSchedule = _schedules.first;
  }

  void _handleEditResult(dynamic result) {
    if (result == 'delete') {
      // Handle delete logic
      setState(() {
        _schedules.remove(_selectedSchedule);
        if (_schedules.isNotEmpty) {
          _selectedSchedule = _schedules.first;
        } else {
          _selectedSchedule = null;
        }
      });
    } else if (result != null) {
      // Handle save logic
      setState(() {
        final index = _schedules.indexOf(_selectedSchedule!);
        if (index != -1) {
          _schedules[index] = result['name'];
          _selectedSchedule = _schedules[index];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

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
        
        // Header with Add Schedule button
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
                  builder: (context) => const CreateScheduleModal(),
                ).then((result) {
                  if (result != null) {
                    setState(() {
                      _schedules.add(result['name']);
                      _selectedSchedule = result['name'];
                    });
                  }
                });
              },
            ),
          ],
        ),
        
        // Mobile view - Dropdown with edit button
        if (!isDesktop) Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedSchedule,
                items: _schedules.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedSchedule = newValue;
                  });
                },
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
                    initialName: _selectedSchedule!,
                    initialTimezone: 'Asia/Hebron',
                    isDefault: _selectedSchedule == _schedules.first,
                  ),
                ).then(_handleEditResult);
              } : null,
            ),
          ],
        ),
        
        // Desktop view - Schedule list
        if (isDesktop) Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
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
                        const Text(
                          'DEFAULT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorSecond,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedSchedule ?? 'No schedule selected',
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
                    onPressed: _selectedSchedule != null ? () {
                      showDialog(
                        context: context,
                        builder: (context) => EditScheduleModal(
                          initialName: _selectedSchedule!,
                          initialTimezone: 'Asia/Hebron',
                          isDefault: _selectedSchedule == _schedules.first,
                        ),
                      ).then(_handleEditResult);
                    } : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
        
        // Timezone information
        Text(
          'Times are in Asia/Hebron',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        
        // AI and Help buttons
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Generate Availability with AI'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                  ),
                  onPressed: () {},
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Beta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
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

// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';

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
//     _selectedSchedule = _schedules.first; // Initialize with first item
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
//               onPressed: () {},
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
//                         color: Colors.black, // Ensure text is visible
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
//                 dropdownColor: Colors.white, // Ensure dropdown background is visible
//                 hint: const Text('Select a schedule'), // Fallback text
//               ),
//             ),
//             const SizedBox(width: 8),
//             IconButton(
//               icon: const Icon(Icons.edit_outlined, size: 22),
//               color: AppColors.textColorSecond,
//               onPressed: () {},
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
//                     onPressed: () {},
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
