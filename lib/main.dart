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







/*import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/steps_for_Meetings/step1.dart';
import 'screens/steps_for_Meetings/step2.dart';
import 'screens/steps_for_Meetings/step3.dart';
import 'screens/steps_for_Meetings/step4.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/home_screen.dart';
import '../colors/app_colors.dart';
import '../config/globals.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tabourak/web%20pages/MeetingBooking.dart';
/*
void main() {
  //    globalAuthToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNzQ4MTY2OTYxLCJleHAiOjE3NDgxODQ5NjF9.syDAGYbekzu_yF85fYKnMXgSNMFOAsise_ev55QnxvE';
  if (kIsWeb) {
    runApp(MaterialApp(home: MeetingBooking(pageSlug: "slug")));
  } else {
    runApp(MyApp());
  }
}*/


void main() {
  runApp(MyApp());
}
/*
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabourak Clone',
      theme: ThemeData(
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentTextStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        primarySwatch: AppColors.primarySwatch,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16, color: AppColors.textColor),
        ),
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (RouteSettings settings) {
        Uri uri = Uri.parse(settings.name ?? '/');

        // default route
        if (uri.path == '/' || uri.path.isEmpty) {
          return MaterialPageRoute(builder: (context) => HomeScreen());
        }

        // Check for single slug like: /healthplus
        if (uri.pathSegments.length == 1) {
          String slug = uri.pathSegments[0];
          return MaterialPageRoute(
            builder: (context) => MeetingBooking(pageSlug: slug),
          );
        }

        // fallback route
        return MaterialPageRoute(
          builder:
              (context) =>
                  Scaffold(body: Center(child: Text('404 - Page not found'))),
        );
      },
    );
  }
}
*/























class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabourak Clone',
      theme: ThemeData(
            snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentTextStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        primarySwatch:  AppColors.primarySwatch,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16, color: AppColors.textColor),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
      //  '/': (context) => HomeScreen(),
        // '/': (context) => SchedulingPage(), // Step 4
      //'/': (context) => ConnectCalendarPage(), // Step 3
      // '/': (context) => AvailabilityScreen(), // Step 2
      // '/step2': (context) => AvailabilityScreen(), // Step 2
    //    '/': (context) => AppointmentSetupScreen(), // step1
         '/step1': (context) => AppointmentSetupScreen(), // Provide actual token
         '/': (context) => LoginPage(),
        '/login': (context) => LoginPage(),
        '/admin': (context) => AdminDashboard(),
      },
    );
  }
}

class ErrorHandler extends StatelessWidget {
  final Widget child;

  ErrorHandler({required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e) {
          return Center(
            child: Text('An error occurred: $e'),
          );
        }
      },
    );
  }
}
*/