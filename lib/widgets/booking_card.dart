import 'package:flutter/material.dart';

class BookingCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;

  BookingCard({required this.title, required this.date, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text('$date at $time'),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          // Handle tap
        },
      ),
    );
  }
}