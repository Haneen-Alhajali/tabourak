import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/web%20pages/TimeBooking.dart';
import 'package:tabourak/config/config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';

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

class MeetingListScreen extends StatefulWidget {
  final int member_id = 1;
  final int orgnization_id = 1;

  @override
  _MeetingListScreenState createState() => _MeetingListScreenState();
}

class _MeetingListScreenState extends State<MeetingListScreen> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    initAppLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> initAppLinks() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      print('Initial link error: $e');
    }

    _sub = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        print('Deep link stream error: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    if (uri.host == 'zoom-auth-success') {
      final accessToken = uri.queryParameters['access_token'];
      if (accessToken != null) {
        sendTokenToBackend(accessToken);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Zoom connected successfully ✅')),
        );
      }
    }
  }

  Future<void> sendTokenToBackend(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/zoom/save-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'access_token': token}),
      );
      print("♻️♻️♻️♻️♻️♻️sendTokenToBackend");
      print(response.body);

      if (response.statusCode == 200) {
        print('Token saved successfully');
      } else {
        print('Failed to save token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending token: $e');
    }
  }

  Future<List<Appointment>> fetchAppointments() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/appointment/page/1'),
    );

    print("♻️♻️♻️♻️♻️♻️fetchAppointments");
    print(response.body);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  void startZoomOAuth(BuildContext context) async {
    final zoomOAuthUrl =
        'https://marketplace.zoom.us/authorize?client_id=dRQS9ByZSUWBKAewqWQ82Q&response_type=code&redirect_uri=http%3A%2F%2F192.168.1.115%3A3000%2Fzoom%2Fcallback&state=${widget.member_id}';

    final uri = Uri.parse(zoomOAuthUrl);

    if (await canLaunchUrl(uri)) {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('error when open link')));
      }
      
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('error in link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a meeting'),
        backgroundColor: AppColors.backgroundColor,
        actions: [
          TextButton.icon(
            onPressed: () => startZoomOAuth(context),
            icon: Icon(Icons.videocam, color: Colors.white),
            label: Text(
              'Connect Zoom',
              style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
            ),
          ),
        ],
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
                            (_) => ScheduleScreen(
                              scheduleId: meeting.scheduleId,
                              duration: meeting.duration,
                              appointmentId: meeting.appointmentId,
                              appointmentType: meeting.appointmentType,
                              member_id: widget.member_id,
                              orgnization_id: widget.orgnization_id,
                              appointmentName: meeting.appointmentName,
                              attendeeType: meeting.attendeeType,
                            ),
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
  final String appointmentType;
  final String appointmentName;
  final String attendeeType;

  Appointment({
    required this.appointmentId,
    required this.name,
    required this.duration,
    required this.scheduleId,
    required this.appointmentType,
    required this.appointmentName,
    required this.attendeeType,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointment_id'],
      name: json['name'],
      duration: json['duration_minutes'],
      scheduleId: json['schedule_id'],
      appointmentType: json['meeting_type'],
      appointmentName: json['name'],
      attendeeType: json['attendee_type'],
    );
  }
}



















































































































/*import 'dart:convert';
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
  int member_id = 1;
  int orgnization_id = 1;

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
                            (_) => ScheduleScreen(
                              scheduleId: meeting.scheduleId,
                              duration: meeting.duration,
                              appointmentId: meeting.appointmentId,
                              appointmentType: meeting.appointmentType,
                              member_id: member_id,
                              orgnization_id: orgnization_id,
                              appointmentName: meeting.appointmentName,
                              attendeeType:meeting.attendeeType,
                            ),
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
  final String appointmentType;
  final String appointmentName;
  final String attendeeType;

  Appointment({
    required this.appointmentId,
    required this.name,
    required this.duration,
    required this.scheduleId,
    required this.appointmentType,
    required this.appointmentName,
    required this.attendeeType,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointment_id'],
      name: json['name'],
      duration: json['duration_minutes'],
      scheduleId: json['schedule_id'],
      appointmentType: json['meeting_type'],
      appointmentName: json['name'],
      attendeeType: json['attendee_type'],
    );
  }
}
*/