import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tabourak/config/config.dart';

/*
void main() {
  runApp(BookingConfirmationApp());
}

class BookingConfirmationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BookingConfirmationScreen(),
    );
  }
}
*/

class BookingConfirmationScreen extends StatefulWidget {
  final String appointmentType;
  final DateTime startTime; //
  final DateTime endTime; //
  final String appointmentName; //
  final int appointmentId;
  final String emailController;
  final int member_id;
  final int userId;
  final int duration;
  final String attendeeType;
  final int? meetingId;

  const BookingConfirmationScreen({
    Key? key,
    required this.appointmentType,
    required this.startTime,
    required this.endTime,
    required this.appointmentName,
    required this.appointmentId,
    required this.emailController,
    required this.member_id,
    required this.userId,
    required this.duration,
    required this.attendeeType,
    required this.meetingId,
  }) : super(key: key);

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    sendEmailMessage();
  }

  /////////////////////////////////////////////////////////////////////////////////

  Future<String?> fetchJoinUrl() async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/get-join-url');

    final body = jsonEncode({
      "appointment_id": widget.appointmentId,
      "startTime": formatForCalendar(widget.startTime),
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
          'ngrok-skip-browser-warning': 'true',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['meeting'] != null && data['meeting']['join_url'] != null) {
          return data['meeting']['join_url'];
        } else if (data['join_url'] != null) {
          return data['join_url'];
        } else {
          return null;
        }
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  /////////////////////////////////////////////////////////////////////////////////
  String formatForCalendar(DateTime dateTime) {
    final utcTime = dateTime.toUtc();
    return utcTime
        .toIso8601String()
        .replaceAll(RegExp(r'[:-]|\.\d{3}'), '')
        .split('.')
        .first;
  }

  Future<void> sendEmailMessage() async {
    final result = await buildEmailMessage();

    final subject = result['subject'];
    final message = result['message'];

    final url = Uri.parse('${AppConfig.baseUrl}/api/otp/send-email');
    print('🚀🚀🚀🚀🚀🚀🚀🚀🚀widget.meetingId  ' + widget.meetingId.toString());
    final body = {
      "email": widget.emailController,
      "subject": subject,
      "message": message,
      "startTime": formatForCalendar(widget.startTime),
      "endTime": formatForCalendar(widget.endTime),
      "appointmentName": widget.appointmentName,
      "locationLine": result['locationLine'],
      "bookingId": widget.meetingId,
    };
    print('🚀 Sending email body: $body'); // 👈 مهم جداً
    print(
      '🚀🚀🚀🚀🚀🚀🚀🚀🚀startTime  ' + formatForCalendar(widget.startTime),
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ Email sent successfully!');
        print(response.body);
      } else {
        print('❌ Failed to send email. Status: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  ///////////////////////////////////////////////////////////////////////////////

  Future<Map<String, dynamic>?> createZoomMeeting() async {
    print("🚀🚀🚀 createZoomMeeting() is being called");

    final Uri url = Uri.parse('${AppConfig.baseUrl}/zoom/create-meeting');

    final String startTimeUtc = formatForCalendar(widget.startTime);

    final Map<String, dynamic> body = {
      "topic": widget.appointmentName,
      "start_time": startTimeUtc,
      "duration": widget.duration,
      "timezone": 'Asia/Riyadh',
      "member_id": widget.member_id,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
          'ngrok-skip-browser-warning': 'true',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // طبعًا تتأكدي ان API يرجع هذه الحقول
        final String? startUrl = data['start_url'];
        final String? joinUrl = data['join_url'];
        final String? uuid = data['uuid'];
        final meetingId = data['id']; // ✅ خذنا ID من هنا

        print(
          "🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨 Meeting created: join_url=$joinUrl, start_url=$startUrl, uuid=$uuid ,meetingId=$meetingId",
        );

        return {"start_url": startUrl, "join_url": joinUrl, "uuid": meetingId};
      } else {
        print("❌ Failed to create meeting. Status: ${response.statusCode}");
        print("📩 Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("🚨 Error sending request: $e");
      return null;
    }
  }
  /////////////////////////////////////////////////////////////////////////////////////

  Future<void> sendGeneratedMeetingToBackend({
    required String joinUrl,
    required String meetingCode,
    String? startUrl,
  }) async {
    print("🟠🟠🟠 About to send meeting to backend");

    final Uri url = Uri.parse(
      '${AppConfig.baseUrl}/api/generated-meetings-for-database',
    );

    final DateTime parsed = DateTime.parse(widget.startTime.toString());
    final String formatted = parsed.toIso8601String();

    final Map<String, dynamic> body = {
      "booking_id": widget.meetingId,
      "provider": "zoom",
      "join_url": joinUrl,
      "meeting_code": meetingCode,
      "password": "123456",
      "start_url": startUrl,
      "startTime": formatted,
      "appointment_id": widget.appointmentId,
    };

    print("📦📦📦📦📦📦📦📦formatted📦📦📦📦📦📦📦📦" + formatted);

    print("📦📦📦📦📦📦📦📦body.toString()📦📦📦📦📦📦📦📦" + body.toString());

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        print("✅ Meeting saved in database successfully");
      } else {
        print("❌ Failed to save meeting. Status: ${response.statusCode}");
        print("📩 Body: ${response.body}");
      }
    } catch (e) {
      print("🚨 Error sending meeting to backend: $e");
    }
  }

  ////////////////////////////////////////////////////////////////////////////////
  Future<Map<String, String>> buildEmailMessage() async {
    final appointmentUrl = Uri.parse(
      '${AppConfig.baseUrl}/api/appointment/${widget.appointmentId}',
    );
    final appointmentResponse = await http.get(
      appointmentUrl,
      headers: {
        'Accept': 'application/json',
        'Cache-Control': 'no-cache',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (appointmentResponse.statusCode != 200) {
      throw Exception('error in meeting data ');
    }
    final appointmentData = jsonDecode(appointmentResponse.body);
    final message = appointmentData['message'];

    final memberUrl = Uri.parse(
      '${AppConfig.baseUrl}/api/members/${widget.member_id}',
    );
    final memberResponse = await http.get(
      memberUrl,
      headers: {
        'Accept': 'application/json',
        'Cache-Control': 'no-cache',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (memberResponse.statusCode != 200) {
      throw Exception('error in member data');
    }
    final memberData = jsonDecode(memberResponse.body);
    final guestName = '${memberData["first_name"]} ${memberData["last_name"]}';
    final guestEmail = memberData["email"];

    final responsesUrl = Uri.parse(
      '${AppConfig.baseUrl}/api/responses_user_info/${widget.userId}',
    );
    final responsesResponse = await http.get(
      responsesUrl,
      headers: {
        'Accept': 'application/json',
        'Cache-Control': 'no-cache',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (responsesResponse.statusCode != 200) {
      throw Exception('error responce data');
    }
    final List<dynamic> responses = jsonDecode(responsesResponse.body);

    final answersSection = StringBuffer();
    answersSection.write(
      '<div style="font-family: Arial, sans-serif; font-size: 16px; color: #333;">',
    );
    answersSection.write('<h3>📝 Form Responses</h3>');

    for (var response in responses) {
      answersSection.write('''
      <p>
        <strong>${response["label"]}</strong><br>
        ${response["response_text"]}
      </p><hr>
    ''');
    }

    answersSection.write('</div>');

    final String day = DateFormat(
      'EEEE MMMM dd, yyyy',
    ).format(widget.startTime);
    final String timeRange =
        DateFormat('h:mma').format(widget.startTime) +
        ' – ' +
        DateFormat('h:mma').format(widget.endTime);
    final String timeZone = 'Asia/Jerusalem';

    final String formattedTime = DateFormat('h:mma').format(widget.startTime);
    final String formattedDate = DateFormat(
      'MMMM dd, yyyy',
    ).format(widget.startTime);

    String locationLine = '';
    String meetingTypeLine = '';
    if (message.contains('Phone call')) {
      meetingTypeLine = 'You\'ll meet on a phone call';
      locationLine = '📞 Phone Number \n${appointmentData["phone"]}';
    } else if (message.contains('In-person')) {
      meetingTypeLine = 'You\'ll meet in person';
      final rawLocation = '📍 Location \n${appointmentData["location"]}';

      locationLine = rawLocation;
    } else if (message.contains('Zoom')) {
      meetingTypeLine = 'You\'ll meet on a web conference';

      String? zoomLink = 'https://tabourak.link/m/MmtPulhdhk/conference';

      if (widget.attendeeType == "one_on_one") {
        final meetingData = await createZoomMeeting();

        if (meetingData != null) {
          final startUrl = meetingData['start_url'];
          final joinUrl = meetingData['join_url'];
          final uuid = meetingData['uuid'];
          zoomLink = joinUrl;
          await sendGeneratedMeetingToBackend(
            joinUrl: joinUrl,
            meetingCode: uuid.toString(),
            startUrl: startUrl,
          );
        }
      } else {
        final getzoomLink = await fetchJoinUrl();
        zoomLink = getzoomLink;

        //get the exist zoom link
      }
      //check if the many to one meeting , or one to one , if one to one make URL if not get the URL from databaze
      locationLine = '🔗 Zoom join link \n$zoomLink\n ';
    }

    String mapViewLink = '';
    if (message.contains('In-person')) {
      final rawLocation = '${appointmentData["location"]}';
      final encodedLocation = Uri.encodeComponent(rawLocation);
      final mapLink =
          'https://www.google.com/maps/search/?api=1&query=$encodedLocation';
      mapViewLink = '<a href="$mapLink" target="_blank">🔗 View on Map</a>';
    }

    final emailBody = '''
${answersSection.toString()}

<div style="font-family: Arial, sans-serif; font-size: 16px; color: #333;">
  <p>$meetingTypeLine</p>

  <hr>

  <p><strong>🕒 When</strong><br>
  $day ⋅ $timeRange ($timeZone)</p>

  <hr>

  <p><strong>$locationLine</strong></p>
    $mapViewLink</p> 

  <hr>

  <p><strong>👤 Guests</strong><br>
  $guestName - organizer<br>
  $guestEmail</p>
</div>
''';

    final emailSubject =
        'Scheduled: $guestName - ${widget.appointmentName} Meeting - $formattedTime $formattedDate';

    return {
      "subject": emailSubject,
      "message": emailBody,
      "locationLine": locationLine,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FB),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 500,
                ), // Limits card width on large screens
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 64),
                        SizedBox(height: 16),
                        Text(
                          'Thanks for booking!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'You\'ll receive an email with meeting details.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),

                        // Meeting Type
                        _buildDetailRow(
                          icon: Icon(Icons.event, color: Colors.orange),
                          backgroundColor: Colors.orange[100],
                          mainText: widget.appointmentName,
                        ),
                        SizedBox(height: 16),

                        // Date and Time
                        _buildDetailRow(
                          icon: Icon(Icons.calendar_today, color: Colors.green),
                          backgroundColor: Colors.green[100],
                          mainText:
                              DateFormat.jm()
                                  .format(widget.startTime)
                                  .toString() +
                              " - " +
                              DateFormat.jm().format(widget.endTime).toString(),
                          secondaryText:
                              DateFormat.yMMMMEEEEd()
                                  .format(widget.endTime)
                                  .toString(),
                        ),
                        SizedBox(height: 16),

                        // Location
                        _buildDetailRow(
                          icon: Icon(Icons.location_on, color: Colors.pink),
                          backgroundColor: Colors.pink[100],
                          mainText: widget.appointmentType,
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for consistent detail rows
  Widget _buildDetailRow({
    required Icon icon,
    required Color? backgroundColor,
    required String mainText,
    String? secondaryText,
  }) {
    return Row(
      crossAxisAlignment:
          secondaryText != null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
      children: [
        CircleAvatar(backgroundColor: backgroundColor, child: icon),
        SizedBox(width: 12),
        secondaryText != null
            ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mainText, style: TextStyle(fontSize: 16)),
                Text(secondaryText, style: TextStyle(color: Colors.grey[600])),
              ],
            )
            : Text(mainText, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
