import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/web%20pages/TimeBooking.dart';
import 'package:tabourak/config/config.dart';
/*
void main() {
  runApp(MeetingApp());
}

class MeetingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tabourak',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: MeetingListScreen( slug: 'dr-smith',
      memberId: 1,
      orgnizationId: 1,),
    );
  }
}*/

void main() {
  final uri = Uri.base;

  final slug = uri.queryParameters['slug'] ?? 'dr-smith';
  final memberId = int.tryParse(uri.queryParameters['mid'] ?? '') ?? 1;
  final orgId = int.tryParse(uri.queryParameters['oid'] ?? '') ?? 1;

  runApp(MeetingApp(slug: slug, memberId: memberId, orgnizationId: orgId));
}

class MeetingApp extends StatelessWidget {
  final String slug;
  final int memberId;
  final int orgnizationId;

  MeetingApp({
    required this.slug,
    required this.memberId,
    required this.orgnizationId,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tabourak',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: MeetingListScreen(
        slug: slug,
        memberId: memberId,
        orgnizationId: orgnizationId,
      ),
    );
  }
}

class MeetingListScreen extends StatelessWidget {
  final String slug;
  final int memberId;
  final int orgnizationId;

  MeetingListScreen({
    required this.slug,
    required this.memberId,
    required this.orgnizationId,
  });

  Future<int?> fetchPageIdBySlug(String slug) async {
    print('🚀 بدأ تنفيذ fetchPageIdBySlug مع الـ slug: $slug');

    final url = Uri.parse('${AppConfig.baseUrl}/api/page-id/$slug');
    print('🌐 URL المرسل للطلب: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      print('📡 إرسال طلب GET إلى السيرفر...');
      print('📥 تم استلام الرد من السيرفر');
      print('🔢 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      print('🧠 Content-Type: ${response.headers['content-type']}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ تم تحويل البيانات بنجاح: $data');
        return data['page_id'];
      } else {
        print('❌ فشل تحميل page ID: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('🚨 حدث خطأ أثناء جلب page ID: $e');
      return null;
    }
  }

  Future<List<Appointment>> fetchAppointments(int pageId) async {
    print('🔎 pageId: $pageId');
    print('🌐 baseUrl: ${AppConfig.baseUrl}');
    print('🔗 Full URL: ${AppConfig.baseUrl}/api/appointment/page/$pageId');

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/appointment/page/$pageId'),
      headers: {
        'Accept': 'application/json',
        'Cache-Control': 'no-cache',
        'ngrok-skip-browser-warning': 'true',
      },
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
    return FutureBuilder<int?>(
      future: fetchPageIdBySlug(slug),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(body: Center(child: Text('❌ Page not found')));
        }

        final pageId = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text('Choose a meeting'),
            backgroundColor: AppColors.backgroundColor,
          ),
          backgroundColor: AppColors.backgroundColor,
          body: FutureBuilder<List<Appointment>>(
            future: fetchAppointments(pageId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No appointments found'));
              }

              final appointments = snapshot.data!;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 600,
                  ), // حدي العرض الأقصى مثلاً 600 بكسل
                  child: ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final meeting = appointments[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
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
                                      member_id: memberId,
                                      orgnization_id: orgnizationId,
                                      appointmentName: meeting.appointmentName,
                                      attendeeType: meeting.attendeeType,
                                      pageId: pageId,
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
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











































































/*import 'dart:async';
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
  final int pageId = 1;

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
                              pageId: widget.pageId,
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