// lib\content\availability\widgets\meeting_limits_content.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';

class MeetingLimitsContent extends StatelessWidget {
  const MeetingLimitsContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          'Meeting Limits',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Rules that limit the number of meetings that can be scheduled with you.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textColorSecond,
          ),
        ),
        const SizedBox(height: 24),
        const Divider(color:AppColors.mediumColor,),
        const SizedBox(height: 24),

        // Maximum Meetings Section
        _buildMeetingLimitSection(
          icon: Icons.event_busy,
          title: 'Maximum Meetings',
          description: 'Limit the number of meetings per day or week. (e.g., Max 5 meetings/day)',
          label1: 'Per Day',
          label2: 'Per Week',
        ),
        const SizedBox(height: 24),

        // Divider
        const Divider(color: AppColors.mediumColor,),
        const SizedBox(height: 24),

        // Maximum Meeting Hours Section
        _buildMeetingLimitSection(
          icon: Icons.access_time,
          title: 'Maximum Meeting Hours',
          description: 'Control the total hours you spend in meetings per day or week. (e.g., Max 4 hours/day)',
          label1: 'Hours Per Day',
          label2: 'Hours Per Week',
        ),
        const SizedBox(height: 24),
        const Divider(color: AppColors.mediumColor,),

      ],
    );
  }

  Widget _buildMeetingLimitSection({
    required IconData icon,
    required String title,
    required String description,
    required String label1,
    required String label2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Icon
        Row(
          children: [
            Icon(icon, size: 24, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Description
        Text(
          description,
          style: const TextStyle(
            fontSize: 13,
            color:AppColors.textColorSecond,
          ),
        ),
        const SizedBox(height: 16),

        // Dropdowns for Per Day and Per Week
        Row(
          children: [
            Expanded(
              child: _buildDropdown(label1, _getMeetingOptions()),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdown(label2, _getMeetingOptions()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorSecond,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: options.first,
            icon: const Icon(Icons.arrow_drop_down),
            underline: const SizedBox(), // Remove the default underline
            onChanged: (String? newValue) {
              // Handle dropdown value change
            },
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<String> _getMeetingOptions() {
    return [
      'No Limit',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13',
      '14',
      '15',
      '16',
      '17',
      '18',
      '19',
      '20',
      '21',
      '22',
      '23',
      '24',
      '25',
    ];
  }

  List<String> _getHoursOptions() {
    return [
      'No Limit',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13',
      '14',
      '15',
      '16',
      '17',
      '18',
      '19',
      '20',
      '21',
      '22',
      '23',
      '24',
      '30',
      '36',
      '42',
      '48',
      '54',
      '60',
      '66',
      '72',
      '78',
      '84',
      '90',
      '96',
      '102',
      '108',
      '114',
      '120',
      '126',
      '132',
      '138',
      '144',
      '150',
      '156',
      '162',
      '168',
    ];
  }
}