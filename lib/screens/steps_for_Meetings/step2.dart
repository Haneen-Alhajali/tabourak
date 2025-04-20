import 'package:flutter/material.dart';
import 'step3.dart';
import '../../colors/app_colors.dart';

class AvailabilityScreen extends StatefulWidget {
  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  Map<String, List<TimeRange>> availability = {
    "Monday": [
      TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0)),
    ],
    "Tuesday": [
      TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0)),
    ],
    "Wednesday": [
      TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0)),
    ],
    "Thursday": [
      TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0)),
    ],
    "Friday": [
      TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0)),
    ],
  };

  Future<void> _pickTime(
    BuildContext context,
    bool isStart,
    TimeRange range,
    String day,
  ) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? range.start : range.end,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          range.start = picked;
        } else {
          range.end = picked;
        }
      });
    }
  }

  void _copyToOtherDays(String sourceDay) async {
    List<String> days = availability.keys.toList();
    List<String> selectedDays = [];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Copy to other days"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: days.where((d) => d != sourceDay).map((day) {
                return CheckboxListTile(
                  title: Text(day),
                  value: selectedDays.contains(day),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        selectedDays.add(day);
                      } else {
                        selectedDays.remove(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    for (String day in selectedDays) {
                      // Add appointments to the selected days without clearing existing ones
                      availability[day]!.addAll(availability[sourceDay]!);
                    }
                  });
                  Navigator.pop(context);
                },
                child: Text("Copy"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                "When are you available to be booked?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Text(
                "These are the times that will show up on your scheduling page.",
                style: TextStyle(color: AppColors.textColorSecond),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: availability.keys.map((day) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              day,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(
                                Icons.copy,
                                color: AppColors.primaryColor,
                              ),
                              onPressed: () => _copyToOtherDays(day),
                            ),
                          ],
                        ),
                        ...availability[day]!.map((range) {
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.textColorSecond,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.backgroundColor,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _pickTime(context, true, range, day),
                                    child: _timeBox(range.start),
                                  ),
                                ),
                                Text(" - "),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _pickTime(context, false, range, day),
                                    child: _timeBox(range.end),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: AppColors.textColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      availability[day]!.remove(range);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              availability[day]!.add(
                                TimeRange(
                                  TimeOfDay(hour: 9, minute: 0),
                                  TimeOfDay(hour: 17, minute: 0),
                                ),
                              );
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: AppColors.primaryColor,
                              ),
                              Text(
                                "Add Time",
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  }).toList(),
                ),
              ),
              SwitchListTile(
                title: Text("Show Weekend"),
                value: availability.containsKey("Saturday"),
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      availability["Saturday"] = [
                        TimeRange(
                          TimeOfDay(hour: 9, minute: 0),
                          TimeOfDay(hour: 17, minute: 0),
                        ),
                      ];
                      availability["Sunday"] = [
                        TimeRange(
                          TimeOfDay(hour: 9, minute: 0),
                          TimeOfDay(hour: 17, minute: 0),
                        ),
                      ];
                    } else {
                      availability.remove("Saturday");
                      availability.remove("Sunday");
                    }
                  });
                },
                activeColor: AppColors.primaryColor,
                inactiveThumbColor: AppColors.textColorSecond,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 500),
                      pageBuilder: (_, __, ___) => ConnectCalendarPage(),
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(1, 0),
                            end: Offset(0, 0),
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  "Next: Calendar Sync →",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Privacy Policy | Terms & Conditions",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(height: 8),
              Text(
                "© 2025 Tabourak",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeBox(TimeOfDay time) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(child: Text("${time.format(context)}")),
    );
  }
}

class TimeRange {
  TimeOfDay start;
  TimeOfDay end;
  TimeRange(this.start, this.end);
}