import 'dart:convert';
import 'package:tabourak/config/config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/web%20pages/CollectFormData.dart';
import 'package:http/http.dart' as http;

class ScheduleScreen extends StatefulWidget {
  final int scheduleId;
  final int duration;
  final int appointmentId;
  final String appointmentType;
  final int member_id;
  final int orgnization_id;
  final String appointmentName;
  final String attendeeType;
  final int pageId;

  ScheduleScreen({
    required this.scheduleId,
    required this.duration,
    required this.appointmentId,
    required this.appointmentType,
    required this.member_id,
    required this.orgnization_id,
    required this.appointmentName,
    required this.attendeeType,
    required this.pageId,
  });

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late Future<List<AvailableDay>> futureAvailableDays;

  Future<List<AvailableDay>> fetchAvailableDays({
    required int scheduleId,
    required int appointmentId,
    required int duration,
    required int pageId,
  }) async {
    print("🔴🔴🔴🔴🔴attendeeType🔴🔴🔴🔴🔴" + widget.attendeeType.toString());

    Uri url = Uri();
    if (widget.attendeeType.toString() == "group") {
      url = Uri.parse(
        '${AppConfig.baseUrl}/api/availability/next-14-days-filtered-group'
        '?schedule_id=$scheduleId'
        '&page_id=$pageId'
        '&appointment_id=$appointmentId'
        '&duration=$duration',
      );
    } else {
      url = Uri.parse(
        '${AppConfig.baseUrl}/api/availability/next-14-days-filtered'
        '?schedule_id=$scheduleId'
        '&page_id=$pageId'
        '&appointment_id=$appointmentId'
        '&duration=$duration',
      );
    }

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Cache-Control': 'no-cache',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((item) => AvailableDay.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load availability');
    }
  }

  @override
  void initState() {
    super.initState();
    futureAvailableDays = fetchAvailableDays(
      scheduleId: widget.scheduleId,
      appointmentId: widget.appointmentId,
      duration: widget.duration,
      pageId: widget.pageId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Choose a time'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: FutureBuilder<List<AvailableDay>>(
        future: futureAvailableDays,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ أثناء تحميل المواعيد'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد مواعيد متاحة'));
          } else {
            return _buildDaysList(snapshot.data!);
          }
        },
      ),
    );
  }

Widget _buildDaysList(List<AvailableDay> availableDays) {
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600), // Optional: set a max width for better appearance on wide screens
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: availableDays.length,
        itemBuilder: (context, index) {
          final day = availableDays[index];
          if (day.slots.isEmpty) {
            return SizedBox.shrink();
          }
          final dayOfWeek = DateFormat('EEEE').format(day.date);
          final dayMonth = DateFormat('MMMM d').format(day.date);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              color: AppColors.backgroundColor,
              margin: EdgeInsets.symmetric(horizontal: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$dayOfWeek, $dayMonth",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    ..._buildTimeRows(context, day.slots),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

  List<Widget> _buildTimeRows(BuildContext context, List<Slot> slots) {
    List<Widget> rows = [];
    for (int i = 0; i < slots.length; i += 3) {
      final chunk = slots.sublist(
        i,
        (i + 3 > slots.length) ? slots.length : i + 3,
      );
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:
                chunk.map((slot) {
                  final rawString = slot.startTime.toString();
                  final utcString = rawString + 'Z';
                  final utcDateTime = DateTime.parse(utcString);
                  final localTime = utcDateTime.toLocal();

                  final startTime = DateFormat.jm().format(localTime);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () async {
                          final rawStart = slot.startTime.toString();
                          final utcStartString = rawStart + 'Z';
                          final utcStartDateTime = DateTime.parse(
                            utcStartString,
                          );
                          final localStartTime = utcStartDateTime.toLocal();

                          final rawEnd = slot.endTime.toString();
                          final utcEndString = rawEnd + 'Z';
                          final utcEndDateTime = DateTime.parse(utcEndString);
                          final localEndTime = utcEndDateTime.toLocal();

                          print("🕒 local start: $localStartTime");
                          print("🕒 local end: $localEndTime");

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => IntakeFormScreen(
                                    appointmentId: widget.appointmentId,
                                    appointmentType: widget.appointmentType,
                                    startTime: localStartTime, // DateTime
                                    endTime: localEndTime, // DateTime
                                    orgnization_id: widget.orgnization_id,
                                    member_id: widget.member_id,
                                    appointmentName: widget.appointmentName,
                                    duration: widget.duration,
                                    attendeeType: widget.attendeeType,
                                  ),
                            ),
                          );

                          setState(() {
                            futureAvailableDays = fetchAvailableDays(
                              scheduleId: widget.scheduleId,
                              appointmentId: widget.appointmentId,
                              duration: widget.duration,
                              pageId: widget.pageId,
                            );
                          });
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            startTime,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      );
    }
    return rows;
  }
}

class AvailableDay {
  final DateTime date;
  final String type;
  final List<Slot> slots;

  AvailableDay({required this.date, required this.type, required this.slots});

  factory AvailableDay.fromJson(Map<String, dynamic> json) {
    return AvailableDay(
      date: DateTime.parse(json['date']),
      type: json['type'],
      slots:
          (json['slots'] as List).map((slot) => Slot.fromJson(slot)).toList(),
    );
  }
}

class Slot {
  final DateTime startTime;
  final DateTime endTime;

  Slot({required this.startTime, required this.endTime});

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
    );
  }
}














/*

class ScheduleScreen extends StatelessWidget {
  final int scheduleId;
  final int duration;

  ScheduleScreen({required this.scheduleId,required this.duration});

  List<DateTime> getUpcomingDays({int totalDays = 14}) {
    DateTime now = DateTime.now();
    return List.generate(totalDays, (index) => now.add(Duration(days: index)));
  }

Future<List<AvailableDay>> fetchAvailableDays() async {
  final response = await http.get(Uri.parse('https://your-api-url.com/availability'));

  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);
    return data.map((item) => AvailableDay.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load availability');
  }
}

  final List<String> availableTimes = [
    '9:00 am',
    '9:30 am',
    '10:00 am',
    '10:30 am',
    '11:00 am',
  ];

  @override
  Widget build(BuildContext context) {
    List<DateTime> days = getUpcomingDays();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: AppBar(
        title: Text('Choose a time'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: ListView.builder(
        itemCount: days.length,
        itemBuilder: (context, index) {
          DateTime date = days[index];
          String dayOfWeek = DateFormat('EEEE').format(date);
          String dayMonth = DateFormat('MMMM d').format(date);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              color: AppColors.backgroundColor,

              margin: EdgeInsets.symmetric(horizontal: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$dayOfWeek, $dayMonth",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    ..._buildTimeRows(context, date),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildTimeRows(BuildContext context, DateTime date) {
    List<Widget> rows = [];
    for (int i = 0; i < availableTimes.length; i += 3) {
      List<String> chunk = availableTimes.sublist(
        i,
        i + 3 > availableTimes.length ? availableTimes.length : i + 3,
      );

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:
                chunk.map((time) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.backgroundColor,
                          foregroundColor: AppColors.primaryColor,
                          side: BorderSide(color: AppColors.textColorSecond),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => IntakeFormScreen(),
                            ),
                          );
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(time, style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      );
    }
    return rows;
  }
}


class AvailableDay {
  final DateTime date;
  final String type;
  final List<String> slots;

  AvailableDay({required this.date, required this.type, required this.slots});

  factory AvailableDay.fromJson(Map<String, dynamic> json) {
    return AvailableDay(
      date: DateTime.parse(json['date']),
      type: json['type'],
      slots: List<String>.from(json['slots']),
    );
  }
}
*/