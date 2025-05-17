import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/web%20pages/TimeBooking.dart';
import 'package:tabourak/config/config.dart';

void main() {
  runApp(MeetingApp());
}

class MeetingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meet with Shahd',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: MeetingListScreen(),
    );
  }
}

class MeetingListScreen extends StatelessWidget {
  Future<List<Appointment>> fetchAppointments() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/appointment/page/1'),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a meeting'),
        backgroundColor: AppColors.backgroundColor,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<List<Appointment>>(
        future: fetchAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No appointments found'));
          }

          final appointments = snapshot.data!;
          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final meeting = appointments[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.backgroundColor,
                child: ListTile(
                  leading: Icon(
                    Icons.access_time,
                    color: AppColors.primaryColor,
                  ),
                  title: Text(meeting.name),
                  subtitle: Text('${meeting.duration} minutes'),
                  trailing: Icon(Icons.info_outline),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                ScheduleScreen(scheduleId: meeting.scheduleId, duration:meeting.duration, appointmentId: meeting.appointmentId,),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Appointment {
  final int appointmentId;
  final String name;
  final int duration;
  final int scheduleId;

  Appointment({
    required this.appointmentId,
    required this.name,
    required this.duration,
    required this.scheduleId,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointment_id'],
      name: json['name'],
      duration: json['duration_minutes'],
      scheduleId: json['schedule_id'],
    );
  }
}
