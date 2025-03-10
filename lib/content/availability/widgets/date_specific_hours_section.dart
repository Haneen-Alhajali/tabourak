import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

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
            const Text(
              'Date-Specific Hours',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Add Date-Specific Hours',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DottedBorder(
          color: Colors.grey.shade300, // Dashed border color
          strokeWidth: 1, // Dashed border thickness
          dashPattern: const [5, 5], // Dash pattern (5px dash, 5px gap)
          borderType: BorderType.RRect, // Rounded rectangle border
          radius: const Radius.circular(8), // Border radius
          padding: const EdgeInsets.all(16), // Inner padding
          child: Container(
            color: Colors.grey.shade100, // Background color
            child: const Column(
              children: [
                Text(
                  'This schedule doesn\'t have any date-specific hours yet.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Use date-specific hours for one-off adjustments to your availability.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}