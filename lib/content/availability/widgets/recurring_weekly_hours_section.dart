import 'package:flutter/material.dart';
import 'custom_widgets.dart';

class RecurringWeeklyHoursSection extends StatelessWidget {
  const RecurringWeeklyHoursSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recurring Weekly Hours',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Edit Recurring Weekly Hours',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildDaySchedule('Mon', '9:00 AM - 5:00 PM'),
              _buildDaySchedule('Tue', '9:00 AM - 5:00 PM'),
              _buildDaySchedule('Wed', '9:00 AM - 5:00 PM'),
              _buildDaySchedule('Thu', '9:00 AM - 5:00 PM'),
              _buildDaySchedule('Fri', '9:00 AM - 5:00 PM'),
              _buildDaySchedule('Sat', 'Unavailable'),
              _buildDaySchedule('Sun', 'Unavailable'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaySchedule(String day, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: time == 'Unavailable' ? Colors.grey.shade100 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  color: time == 'Unavailable' ? Colors.grey : Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}