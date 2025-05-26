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

  ScheduleScreen({
    required this.scheduleId,
    required this.duration,
    required this.appointmentId,
    required this.appointmentType,
    required this.member_id,
    required this.orgnization_id,
    required this.appointmentName,
    required this.attendeeType,
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
  }) async {
    final url = Uri.parse(
      '${AppConfig.baseUrl}/api/availability/next-14-days-filtered'
      '?schedule_id=$scheduleId&appointment_id=$appointmentId&duration=$duration',
    );

    final response = await http.get(url);

    print("✅✅✅url: $url");
    print("✅✅✅status code: ${response.statusCode}");
    print("✅✅✅body: ${response.body}");

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
    );
  }

  /*

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
  return ListView.builder(
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
                _buildTimeRows(context, day.slots), // Updated to pass context
              ],
            ),
          ),
        ),
      );
    },
  );
}
*/

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
    return ListView.builder(
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
                      color: AppColors.textColor, // لون النص غامق
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
                  /*  print( "🔴🔴🔴🔴🔴🔴🔴🔴 slot.startTime 🔴🔴🔴🔴🔴🔴🔴🔴" + slot.startTime.toString() );

                final startTimeUtc = slot.startTime.toUtc(); 
                final startTimeLocal = startTimeUtc.toLocal();
                
                print( "💡💡💡💡💡💡💡💡 startTimeUtc 💡💡💡💡💡💡💡💡" + startTimeUtc.toString() );

                // Convert to local device time
                print( "💡💡💡💡💡💡💡💡 startTimeLocal 💡💡💡💡💡💡💡💡" + startTimeLocal.toString() );

                final startTimeLoca2l = startTimeUtc.toLocal().toLocal();
                print( "♻️♻️♻️♻️♻️♻️♻️♻️ startTimeLocal ♻️♻️♻️♻️♻️♻️♻️♻️" + startTimeLoca2l.toString() );
*/

                  final rawString =
                      slot.startTime
                          .toString(); // الناتج مثل "2025-05-21 10:00:00.000"
                  final utcString =
                      rawString + 'Z'; // إضافة Z لتمثيل الوقت كـ UTC
                  final utcDateTime = DateTime.parse(
                    utcString,
                  ); // الآن يتم تفسيره كـ UTC
                  final localTime =
                      utcDateTime.toLocal(); // تحويله للتوقيت المحلي

                  //    print("🕒🕒localTime : $localTime");

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
                          // تحويل وقت البداية
                          final rawStart =
                              slot.startTime
                                  .toString(); // مثال: "2025-05-21 10:00:00.000"
                          final utcStartString = rawStart + 'Z';
                          final utcStartDateTime = DateTime.parse(
                            utcStartString,
                          );
                          final localStartTime = utcStartDateTime.toLocal();

                          // تحويل وقت النهاية
                          final rawEnd =
                              slot.endTime
                                  .toString(); // مثال: "2025-05-21 10:30:00.000"
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

  /*

//depp zeeck code
Widget _buildTimeRows(BuildContext context, List<Slot> slots) {
  return GridView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 2.5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
    itemCount: slots.length,
    itemBuilder: (context, index) {
      final slot = slots[index];
      
      // Parse UTC time from the database
      final startTimeUtc = DateTime.parse(slot.startTime.toString());
      final endTimeUtc = DateTime.parse(slot.endTime.toString());
      print( "💡💡💡💡💡💡💡💡 startTimeUtc 💡💡💡💡💡💡💡💡" + startTimeUtc.toString() );



      // Convert to local device time
      final startTimeLocal = startTimeUtc.toLocal();
      final endTimeLocal = endTimeUtc.toLocal();

      print( "💡💡💡💡💡💡💡💡 startTimeLocal 💡💡💡💡💡💡💡💡" + startTimeLocal.toString() );


      // Format in 12-hour or 24-hour format (based on device settings)
      final timeFormat = MediaQuery.of(context).alwaysUse24HourFormat 
          ? DateFormat.Hm() 
          : DateFormat.jm();

      final startFormatted = timeFormat.format(startTimeLocal);
      final endFormatted = timeFormat.format(endTimeLocal);

      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          // Handle time slot selection
        },
        child: Text(
          '$startFormatted',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    },
  );
}


*/

  /*
  Widget _buildDaysList(List<AvailableDay> availableDays) {
    return ListView.builder(
      itemCount: availableDays.length,
      itemBuilder: (context, index) {
        final day = availableDays[index];
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
                  if (day.slots.isEmpty)
                    Text(
                      "لا يوجد مواعيد متاحة",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ..._buildTimeRows(context, day.slots),
                ],
              ),
            ),
          ),
        );
      },
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
                  // نعرض الوقت بنسق الساعة:الدقيقة
                  final start = TimeOfDay.fromDateTime(
                    slot.startTime,
                  ).format(context);
                  final end = TimeOfDay.fromDateTime(
                    slot.endTime,
                  ).format(context);
                  final timeLabel = "$start - $end";

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
                          child: Text(
                            timeLabel,
                            style: TextStyle(fontSize: 14),
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
  }*/
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