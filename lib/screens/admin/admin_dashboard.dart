import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text('Manage Team'),
                onTap: () {
                  // Navigate to manage team screen
                },
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Manage Services'),
                onTap: () {
                  // Navigate to manage services screen
                },
              ),
            ),
            Card(
              child: ListTile(
                title: Text('View Appointments'),
                onTap: () {
                  // Navigate to appointments screen
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}