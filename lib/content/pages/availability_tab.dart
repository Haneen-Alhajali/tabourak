// lib\content\pages\availability_tab.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/config/config.dart';
import 'package:tabourak/config/globals.dart';
import 'package:tabourak/content/availability&calender/schedulesTab/schedule_manager_section.dart';

class AvailabilityTab extends StatefulWidget {
  const AvailabilityTab({Key? key}) : super(key: key);

  @override
  _AvailabilityTabState createState() => _AvailabilityTabState();
}

class _AvailabilityTabState extends State<AvailabilityTab> {
  Map<String, dynamic>? _selectedSchedule;
  List<Map<String, dynamic>> _schedules = [];

  Future<List<Map<String, dynamic>>> _fetchUserSchedules() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/schedules'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data.map((schedule) {
          if (schedule['isDefault'] is int) {
            schedule['isDefault'] = schedule['isDefault'] == 1;
          }
          return schedule;
        }));
      } else {
        throw Exception('Failed to load schedules');
      }
    } catch (e) {
      print('Error fetching schedules: $e');
      throw e;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final schedules = await _fetchUserSchedules();
    setState(() {
      _schedules = schedules;
      _selectedSchedule = schedules.firstWhere(
        (s) => s['isDefault'] == true,
        orElse: () => schedules.first,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Which schedule should be used for availability?",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _schedules.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      borderRadius: BorderRadius.circular(10),
                      elevation: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Map<String, dynamic>>(
                            value: _selectedSchedule,
                            isExpanded: true,
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey.shade600,
                                size: 24,
                              ),
                            ),
                            iconSize: 24,
                            elevation: 8,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            dropdownColor: Colors.white,
                            items: _schedules.map((schedule) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: schedule,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: AppColors.accentColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          schedule['name'],
                                          style: TextStyle(
                                            fontWeight:
                                                schedule['isDefault'] == true
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      if (schedule['isDefault'] == true)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8),
                                          child: Text(
                                            '(default)',
                                            style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontStyle: FontStyle.italic,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newSchedule) {
                              if (newSchedule != null) {
                                setState(() {
                                  _selectedSchedule = newSchedule;
                                });
                                print('Selected schedule: ${newSchedule['name']}');
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScheduleManagerSection(),
                          ),
                        ).then((_) => _loadSchedules());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "Edit schedule",
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}