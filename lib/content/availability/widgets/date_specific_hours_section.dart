// lib\content\availability\widgets\date_specific_hours_section.dart
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:tabourak/colors/app_colors.dart';

class DateSpecificHoursSection extends StatelessWidget {
  const DateSpecificHoursSection({Key? key}) : super(key: key);

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
                  'DATE-SPECIFIC HOURS',
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
              onPressed: () {},
              child: const Text(
                'Add Hours',
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        
        DottedBorder(
          color: Colors.grey.shade300,
          strokeWidth: 1,
          dashPattern: const [5, 5],
          borderType: BorderType.RRect,
          radius: const Radius.circular(8),
          padding: const EdgeInsets.all(24),
          child: Container(
            color: Colors.grey.shade200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'This schedule doesn\'t have any date-specific hours yet.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Use date-specific hours for one-off adjustments to your availability.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textColorSecond,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


// // lib\content\availability\widgets\date_specific_hours_section.dart
// import 'package:flutter/material.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:tabourak/colors/app_colors.dart';

// class DateSpecificHoursSection extends StatelessWidget {
//   const DateSpecificHoursSection({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Date-Specific Hours',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textColorSecond,
//               ),
//             ),
//             TextButton(
//               onPressed: () {},
//               child: const Text(
//                 'Add Date-Specific Hours',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         DottedBorder(
//           color: Colors.grey.shade300, // Dashed border color
//           strokeWidth: 1, // Dashed border thickness
//           dashPattern: const [5, 5], // Dash pattern (5px dash, 5px gap)
//           borderType: BorderType.RRect, // Rounded rectangle border
//           radius: const Radius.circular(8), // Border radius
//           padding: const EdgeInsets.all(16), // Inner padding
//           child: Container(
//             color: Colors.grey.shade100, // Background color
//             child: const Column(
//               children: [
//                 Text(
//                   'This schedule doesn\'t have any date-specific hours yet.',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,                    color: AppColors.textColor,

//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'Use date-specific hours for one-off adjustments to your availability.',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: AppColors.textColorSecond,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }