// lib/screens/steps_for_Meetings/step2.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'step3.dart';
import '../../colors/app_colors.dart';
import '../../config/config.dart';
import '../../config/globals.dart';


class AvailabilityScreen extends StatefulWidget {

  const AvailabilityScreen({Key? key}) : super(key: key);

  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  Map<String, List<TimeRange>> availability = {
    "Sunday": [],
    "Monday": [],
    "Tuesday": [],
    "Wednesday": [],
    "Thursday": [],
  };
  bool _isLoading = false;
  bool _hasExistingAvailability = false;
  String? _scheduleId;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/availability'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _hasExistingAvailability = data['exists'] ?? false;
          _scheduleId = data['scheduleId'];
          
          if (data['availability'] != null) {
            final apiAvailability = data['availability'] as Map<String, dynamic>;
            availability = {
              "Sunday": [],
              "Monday": [],
              "Tuesday": [],
              "Wednesday": [],
              "Thursday": [],
              "Friday": [],
              "Saturday": [],
            };
            
            apiAvailability.forEach((day, ranges) {
              if (availability.containsKey(day)) {
                availability[day] = (ranges as List).map((range) {
                  return TimeRange(
                    TimeOfDay(hour: range['start']['hour'], minute: range['start']['minute']),
                    TimeOfDay(hour: range['end']['hour'], minute: range['end']['minute']),
                  );
                }).toList();
              }
            });

            // Remove empty weekend days if they weren't in the response
            if (availability["Friday"]!.isEmpty && availability["Saturday"]!.isEmpty) {
              availability.remove("Friday");
              availability.remove("Saturday");
            }
          }
        });
      }
    } catch (e) {
      print('Error loading availability: $e');
      // Initialize with default values if loading fails
      setState(() {
        availability = {
          "Sunday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
          "Monday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
          "Tuesday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
          "Wednesday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
          "Thursday": [TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0))],
        };
      });
    }
  }

  Future<void> _saveAvailability() async {
    setState(() => _isLoading = true);

    // Validate all time slots first
    bool hasInvalid = false;
    availability.forEach((day, ranges) {
      for (final range in ranges) {
        if (_isStartAfterEnd(range) || _hasOverlap(day, range) || _isStartSameAsEnd(range)) {
          hasInvalid = true;
          return;
        }
      }
    });

    if (hasInvalid) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please resolve invalid time slots")),
      );
      return;
    }

    // Convert our availability to API format
    final apiAvailability = {};
    availability.forEach((day, ranges) {
      apiAvailability[day] = ranges.map((range) {
        return {
          'start': {
            'hour': range.start.hour,
            'minute': range.start.minute,
          },
          'end': {
            'hour': range.end.hour,
            'minute': range.end.minute,
          },
        };
      }).toList();
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/availability'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $globalAuthToken',
        },
        body: json.encode({
          'availability': apiAvailability,
          'scheduleId': _scheduleId, // Send existing scheduleId if we have one
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Availability ${responseData['action']} successfully')),
        );
        
        // Navigate to next screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConnectCalendarPage(),
          ),
        );
      } else {
        final error = json.decode(response.body)['error'] ?? 'Failed to save availability';
        throw Exception(error);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickTime(BuildContext context, bool isStart, TimeRange range, String day) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? range.start : range.end,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
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
    final days = availability.keys.toList();
    final selectedDays = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        final selected = <String>[];
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Copy to other days"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: days.where((d) => d != sourceDay).map((day) {
                    return CheckboxListTile(
                      title: Text(day),
                      value: selected.contains(day),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            selected.add(day);
                          } else {
                            selected.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () => Navigator.of(context).pop(selected),
                  child: Text("Copy"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedDays != null && selectedDays.isNotEmpty) {
      setState(() {
        for (final day in selectedDays) {
          availability[day] = availability[sourceDay]!
              .map((tr) => TimeRange(tr.start, tr.end))
              .toList();
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Copied to ${selectedDays.length} day(s)"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _addTimeSlot(String day) {
    setState(() {
      if (availability[day]!.isEmpty) {
        availability[day]!.add(TimeRange(
          TimeOfDay(hour: 9, minute: 0),
          TimeOfDay(hour: 17, minute: 0),
        ));
      } else {
        final lastSlot = availability[day]!.last;
        TimeOfDay newStart = lastSlot.end;
        TimeOfDay newEnd;
        
        int newHour = newStart.hour + 1;
        int newMinute = newStart.minute;
        
        if (newHour >= 24) {
          newHour = newHour % 24;
        }
        
        newEnd = TimeOfDay(hour: newHour, minute: newMinute);
        
        availability[day]!.add(TimeRange(newStart, newEnd));
      }
    });
  }

  bool _hasOverlap(String day, TimeRange newRange) {
    for (final existingRange in availability[day]!) {
      if (existingRange == newRange) continue;
      
      final existingStart = existingRange.start;
      final existingEnd = existingRange.end;
      final newStart = newRange.start;
      final newEnd = newRange.end;

      if (_isStartSameAsEnd(existingRange) || _isStartSameAsEnd(newRange)) {
        continue;
      }

      if ((newStart.hour < existingEnd.hour || 
          (newStart.hour == existingEnd.hour && newStart.minute < existingEnd.minute)) &&
          (newEnd.hour > existingStart.hour || 
          (newEnd.hour == existingStart.hour && newEnd.minute > existingStart.minute))) {
        return true;
      }
    }
    return false;
  }

  bool _isStartAfterEnd(TimeRange range) {
    return range.end.hour < range.start.hour || 
          (range.end.hour == range.start.hour && range.end.minute < range.start.minute);
  }

  bool _isStartSameAsEnd(TimeRange range) {
    return range.start.hour == range.end.hour && 
           range.start.minute == range.end.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Row(
              children: [
                Image.asset(
                  'images/tabourakNobackground.png',
                  width: 60,
                  height: 60,
                ),
                const Spacer(),
                Text(
                  "Step 2 of 4",
                  style: TextStyle(
                    color: AppColors.textColorSecond,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  "When are you available to be booked?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  "These are the times that will show up on your scheduling page.",
                  style: TextStyle(color: AppColors.textColorSecond),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),          
          
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      ...availability.keys.map((day) {
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
                                  tooltip: 'Copy to other days',
                                ),
                              ],
                            ),
                            ...availability[day]!.map((range) {
                              final hasOverlap = _hasOverlap(day, range);
                              final isStartAfterEnd = _isStartAfterEnd(range);
                              final isStartSameAsEnd = _isStartSameAsEnd(range);
                              final isInvalid = hasOverlap || isStartAfterEnd || isStartSameAsEnd;
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isInvalid ? Colors.red : AppColors.textColorSecond,
                                    width: isInvalid ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isInvalid 
                                      ? Colors.red.withOpacity(0.1) 
                                      : AppColors.backgroundColor,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => _pickTime(context, true, range, day),
                                            child: _timeBox(range.start, isInvalid: isInvalid),
                                          ),
                                        ),
                                        Text(" - "),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => _pickTime(context, false, range, day),
                                            child: _timeBox(range.end, isInvalid: isInvalid),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color: isInvalid ? Colors.red : AppColors.textColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              availability[day]!.remove(range);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    if (isInvalid)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          isStartAfterEnd 
                                              ? "Start can't be after end" 
                                              : isStartSameAsEnd
                                                ? "Start time can't be same as end time"
                                                : "Time ranges can't overlap",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                            TextButton(
                              onPressed: () => _addTimeSlot(day),
                              child: Row(
                                children: [
                                  Icon(Icons.add, color: AppColors.primaryColor),
                                  Text(
                                    "Add Time",
                                    style: TextStyle(color: AppColors.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Show Weekend",
                              style: TextStyle(fontSize: 16),
                            ),
                            Switch(
                              value: availability.containsKey("Friday"),
                              onChanged: (value) {
                                setState(() {
                                  if (value) {
                                    availability["Friday"] = [
                                      TimeRange(
                                        TimeOfDay(hour: 9, minute: 0),
                                        TimeOfDay(hour: 17, minute: 0),
                                      ),
                                    ];
                                    availability["Saturday"] = [
                                      TimeRange(
                                        TimeOfDay(hour: 9, minute: 0),
                                        TimeOfDay(hour: 17, minute: 0),
                                      ),
                                    ];
                                  } else {
                                    availability.remove("Friday");
                                    availability.remove("Saturday");
                                  }
                                });
                              },
                              activeColor: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveAvailability,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Next: Calendar Sync →",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
                SizedBox(height: 20),
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
        ],
      ),
    );
  }

  Widget _timeBox(TimeOfDay time, {bool isInvalid = false}) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: isInvalid ? Colors.red : Colors.grey,
          width: isInvalid ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(5),
        color: isInvalid ? Colors.red.withOpacity(0.1) : null,
      ),
      child: Center(
        child: Text(
          time.format(context),
          style: TextStyle(
            color: isInvalid ? Colors.red : null,
          ),
        ),
      ),
    );
  }
}

class TimeRange {
  TimeOfDay start;
  TimeOfDay end;
  TimeRange(this.start, this.end);
}

