// lib\content\availability&calender\schedulesTab\date_section\date_specific_hours_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/config/config.dart';
import 'package:tabourak/config/globals.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_hours_modal.dart';
import 'package:tabourak/models/time_range.dart';
import 'package:tabourak/config/snackbar_helper.dart';

class DateSpecificHoursSection extends StatefulWidget {
  final String? scheduleId;

  const DateSpecificHoursSection({Key? key, this.scheduleId}) : super(key: key);

  @override
  _DateSpecificHoursSectionState createState() => _DateSpecificHoursSectionState();
}

class _DateSpecificHoursSectionState extends State<DateSpecificHoursSection> {
  Map<DateTime, List<TimeRange>> dateSpecificHours = {};
  bool _isLoading = true;
  String? _error;
  bool _initialLoadComplete = false;

  @override
  void initState() {
    super.initState();
    if (widget.scheduleId != null) {
      // Use post-frame callback to ensure proper initialization
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchDateSpecificHours();
      });
    } else {
      setState(() {
        _isLoading = false;
        _initialLoadComplete = true;
      });
    }
  }

  @override
  void didUpdateWidget(DateSpecificHoursSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh data if scheduleId changes
    if (widget.scheduleId != oldWidget.scheduleId) {
      _fetchDateSpecificHours();
    }
  }

  Future<void> _fetchDateSpecificHours() async {
    if (widget.scheduleId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/date-specific-availability?scheduleId=${widget.scheduleId}'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('API Response: $data');
        
        final Map<DateTime, List<TimeRange>> parsedHours = {};
        
        // Handle both direct and nested availability data
        final availabilityData = data is Map && data.containsKey('availability') 
            ? data['availability'] 
            : data;

        if (availabilityData is Map) {
          availabilityData.forEach((dateStr, ranges) {
            try {
              final date = DateFormat('yyyy-MM-dd').parse(dateStr);
              final List timeRangeList = ranges is List ? ranges : [ranges];
              
              final timeRanges = timeRangeList.map((range) {
                return TimeRange(
                  TimeOfDay(
                    hour: range['start']['hour'] ?? 9,
                    minute: range['start']['minute'] ?? 0,
                  ),
                  TimeOfDay(
                    hour: range['end']['hour'] ?? 17,
                    minute: range['end']['minute'] ?? 0,
                  ),
                );
              }).toList();
              
              parsedHours[date] = timeRanges;
            } catch (e) {
              debugPrint('Error parsing date $dateStr: $e');
            }
          });
        }

        setState(() {
          dateSpecificHours = parsedHours;
          _initialLoadComplete = true;
        });
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load date-specific hours');
      }
    } catch (err) {
      setState(() {
        _error = 'Failed to load date-specific hours. Please try again.';
      });
      debugPrint('Error fetching date-specific hours: $err');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddHoursModal(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddHoursModal(
        initialDateSpecificHours: Map.from(dateSpecificHours),
        scheduleId: widget.scheduleId,
        onDeleteDate: _handleDateDeleted,
      ),
    );

    if (result != null && result == true) {
      await _fetchDateSpecificHours();
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Date-specific hours updated successfully')),
        // );
      //   ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Date-specific hours updated successfully'),
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(10),
      //     ),
      //     margin: EdgeInsets.all(10),
      //   ),
      // );
      SnackbarHelper.showSuccess(context, 'Date-specific hours updated successfully');

      }
    }
  }

  void _handleDateDeleted(DateTime date) {
    setState(() {
      dateSpecificHours.remove(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && !_initialLoadComplete) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDateSpecificHours,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final sortedDates = dateSpecificHours.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'DATE-SPECIFIC HOURS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorSecond,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline, size: 16),
                  color: AppColors.textColorSecond,
                  onPressed: () {},
                ),
              ],
            ),
            TextButton(
              onPressed: () => _showAddHoursModal(context),
              child: Text(
                'Edit Hours',
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        
        if (sortedDates.isEmpty)
          _buildEmptyState(widget.scheduleId != null)
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedDates.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey.shade300,
              ),
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final timeRanges = dateSpecificHours[date]!;
                return _buildDateItem(date, timeRanges);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(bool hasSchedule) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hasSchedule
              ? "This schedule doesn't have any date-specific hours yet."
              : "No schedule selected or no date-specific hours set.",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Use date-specific hours for one-off adjustments to your availability.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textColorSecond,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(DateTime date, List<TimeRange> timeRanges) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM d, y').format(date),
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (int i = 0; i < timeRanges.length; i++) ...[
                if (i > 0) 
                  Text(
                    ',',
                    style: TextStyle(
                      color: AppColors.textColor,
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightcolor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${_formatTime(timeRanges[i].start)} - ${_formatTime(timeRanges[i].end)}',
                    style: TextStyle(
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}










//edit for delete
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/config/config.dart';
// import 'package:tabourak/config/globals.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'add_hours_modal.dart';
// import 'package:tabourak/models/time_range.dart';

// class DateSpecificHoursSection extends StatefulWidget {
//   final String? scheduleId;

//   const DateSpecificHoursSection({Key? key, this.scheduleId}) : super(key: key);

//   @override
//   _DateSpecificHoursSectionState createState() => _DateSpecificHoursSectionState();
// }

// class _DateSpecificHoursSectionState extends State<DateSpecificHoursSection> {
//   Map<DateTime, List<TimeRange>> dateSpecificHours = {};
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.scheduleId != null) {
//       _fetchDateSpecificHours();
//     } else {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void didUpdateWidget(DateSpecificHoursSection oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.scheduleId != oldWidget.scheduleId) {
//       if (widget.scheduleId != null) {
//         _fetchDateSpecificHours();
//       } else {
//         setState(() {
//           dateSpecificHours = {};
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchDateSpecificHours() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/date-specific-availability?scheduleId=${widget.scheduleId}'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['availability'] == null) {
//           throw Exception('Invalid data format from server');
//         }
        
//         final Map<DateTime, List<TimeRange>> parsedHours = {};
        
//         for (final entry in data['availability'].entries) {
//           final date = DateTime.parse(entry.key);
//           final timeRanges = (entry.value as List).map((range) {
//             return TimeRange(
//               TimeOfDay(hour: range['start']['hour'], minute: range['start']['minute']),
//               TimeOfDay(hour: range['end']['hour'], minute: range['end']['minute']),
//             );
//           }).toList();
          
//           parsedHours[date] = timeRanges;
//         }

//         setState(() {
//           dateSpecificHours = parsedHours;
//         });
//       } else {
//         final errorData = json.decode(response.body);
//         throw Exception(errorData['error'] ?? 'Failed to load date-specific hours');
//       }
//     } catch (err) {
//       setState(() {
//         _error = 'Failed to load date-specific hours. Please try again.';
//       });
//       debugPrint('Error fetching date-specific hours: $err');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _showAddHoursModal(BuildContext context) async {
//     final result = await showDialog(
//       context: context,
//       builder: (context) => AddHoursModal(
//         initialDateSpecificHours: Map.from(dateSpecificHours),
//         scheduleId: widget.scheduleId,
//       ),
//     );

//     if (result != null && result == true) {
//       await _fetchDateSpecificHours();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Date-specific hours updated successfully')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     if (_error != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(_error!),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _fetchDateSpecificHours,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     final sortedDates = dateSpecificHours.keys.toList()..sort();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   'DATE-SPECIFIC HOURS',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textColorSecond,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.help_outline, size: 16),
//                   color: AppColors.textColorSecond,
//                   onPressed: () {},
//                 ),
//               ],
//             ),
//             TextButton(
//               onPressed: () => _showAddHoursModal(context),
//               child: Text(
//                 'Edit Hours',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         if (sortedDates.isEmpty)
//           _buildEmptyState(widget.scheduleId != null)
//         else
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(4),
//               border: Border.all(
//                 color: Colors.grey.shade300,
//               ),
//             ),
//             child: ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: sortedDates.length,
//               separatorBuilder: (context, index) => Divider(
//                 height: 1,
//                 color: Colors.grey.shade300,
//               ),
//               itemBuilder: (context, index) {
//                 final date = sortedDates[index];
//                 final timeRanges = dateSpecificHours[date]!;
//                 return _buildDateItem(date, timeRanges);
//               },
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildEmptyState(bool hasSchedule) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: Colors.grey.shade300,
//         ),
//       ),
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             hasSchedule
//               ? "This schedule doesn't have any date-specific hours yet."
//               : "No schedule selected or no date-specific hours set.",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textColor,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Use date-specific hours for one-off adjustments to your availability.',
//             style: TextStyle(
//               fontSize: 14,
//               color: AppColors.textColorSecond,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateItem(DateTime date, List<TimeRange> timeRanges) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             DateFormat('MMMM d, y').format(date),
//             style: TextStyle(
//               fontSize: 16,
//               color: AppColors.textColor,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             crossAxisAlignment: WrapCrossAlignment.center,
//             children: [
//               for (int i = 0; i < timeRanges.length; i++) ...[
//                 if (i > 0) 
//                   Text(
//                     ',',
//                     style: TextStyle(
//                       color: AppColors.textColor,
//                     ),
//                   ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.lightcolor,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     '${_formatTime(timeRanges[i].start)} - ${_formatTime(timeRanges[i].end)}',
//                     style: TextStyle(
//                       color: AppColors.textColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatTime(TimeOfDay time) {
//     final hour = time.hourOfPeriod;
//     final minute = time.minute.toString().padLeft(2, '0');
//     final period = time.period == DayPeriod.am ? 'AM' : 'PM';
//     return '$hour:$minute $period';
//   }
// }






//edit

// // lib\content\availability&calender\schedulesTab\date_section\date_specific_hours_section.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'add_hours_modal.dart';
// import 'package:tabourak/models/time_range.dart';

// class DateSpecificHoursSection extends StatelessWidget {
//   final Map<DateTime, List<TimeRange>> dateSpecificHours = {
//     DateTime(2025, 5, 6): [
//       TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0)),
//       TimeRange(TimeOfDay(hour: 18, minute: 0), TimeOfDay(hour: 19, minute: 0)),
//     ],
//     DateTime(2025, 5, 7): [
//       TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0)),
//     ],
//     DateTime(2025, 5, 23): [
//       TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0)),
//     ],
//     DateTime(2025, 5, 29): [
//       TimeRange(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 17, minute: 0)),
//       TimeRange(TimeOfDay(hour: 18, minute: 0), TimeOfDay(hour: 19, minute: 0)),
//       TimeRange(TimeOfDay(hour: 20, minute: 0), TimeOfDay(hour: 21, minute: 0)),
//     ],
//   };

//   void _showAddHoursModal(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => const AddHoursModal(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sortedDates = dateSpecificHours.keys.toList()..sort();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   'DATE-SPECIFIC HOURS',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textColorSecond,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.help_outline, size: 16),
//                   color: AppColors.textColorSecond,
//                   onPressed: () {},
//                 ),
//               ],
//             ),
//             TextButton(
//               onPressed: () => _showAddHoursModal(context),
//               child: Text(
//                 'Edit Hours',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         if (sortedDates.isEmpty)
//           _buildEmptyState()
//         else
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(4),
//               border: Border.all(
//                 color: Colors.grey.shade300,
//               ),
//             ),
//             child: ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: sortedDates.length,
//               separatorBuilder: (context, index) => Divider(
//                 height: 1,
//                 color: Colors.grey.shade300,
//               ),
//               itemBuilder: (context, index) {
//                 final date = sortedDates[index];
//                 final timeRanges = dateSpecificHours[date]!;
//                 return _buildDateItem(date, timeRanges);
//               },
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildEmptyState() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: Colors.grey.shade300,
//         ),
//       ),
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             "This schedule doesn't have any date-specific hours yet.",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textColor,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Use date-specific hours for one-off adjustments to your availability.',
//             style: TextStyle(
//               fontSize: 14,
//               color: AppColors.textColorSecond,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateItem(DateTime date, List<TimeRange> timeRanges) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             DateFormat('MMMM d, y').format(date),
//             style: TextStyle(
//               fontSize: 16,
//               color: AppColors.textColor,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             crossAxisAlignment: WrapCrossAlignment.center,
//             children: [
//               for (int i = 0; i < timeRanges.length; i++) ...[
//                 if (i > 0) 
//                   Text(
//                     ',',
//                     style: TextStyle(
//                       color: AppColors.textColor,
//                     ),
//                   ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.lightcolor,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     '${_formatTime(timeRanges[i].start)} - ${_formatTime(timeRanges[i].end)}',
//                     style: TextStyle(
//                       color: AppColors.textColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatTime(TimeOfDay time) {
//     final hour = time.hourOfPeriod;
//     final minute = time.minute.toString().padLeft(2, '0');
//     final period = time.period == DayPeriod.am ? 'AM' : 'PM';
//     return '$hour:$minute $period';
//   }
// }














// // lib\content\availability&calender\schedulesTab\date_section\date_specific_hours_section.dart
// import 'package:flutter/material.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'add_hours_modal.dart';

// class DateSpecificHoursSection extends StatelessWidget {
//   const DateSpecificHoursSection({Key? key}) : super(key: key);

//   void _showAddHoursModal(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => const AddHoursModal(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'DATE-SPECIFIC HOURS',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textColorSecond,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.help_outline, size: 16),
//                   color: AppColors.textColorSecond,
//                   onPressed: () {},
//                 ),
//               ],
//             ),
//             TextButton(
//               onPressed: () => _showAddHoursModal(context),
//               child: const Text(
//                 'Add & Edit Hours',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         DottedBorder(
//           color: Colors.grey.shade400,
//           strokeWidth: 1,
//           dashPattern: const [5, 5],
//           borderType: BorderType.RRect,
//           radius: const Radius.circular(8),
//           padding: const EdgeInsets.all(24),
//           child: Container(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'This schedule doesn\'t have any date-specific hours yet.',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Use date-specific hours for one-off adjustments to your availability.',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: AppColors.textColorSecond,
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }




// // lib/content/availability/widgets/date_specific_hours_section.dart
// import 'package:flutter/material.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'add_hours_modal.dart';

// class DateSpecificHoursSection extends StatelessWidget {
//   const DateSpecificHoursSection({Key? key}) : super(key: key);

//   void _showAddHoursModal(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => const AddHoursModal(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'DATE-SPECIFIC HOURS',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textColorSecond,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.help_outline, size: 16),
//                   color: AppColors.textColorSecond,
//                   onPressed: () {},
//                 ),
//               ],
//             ),
//             TextButton(
//               onPressed: () => _showAddHoursModal(context),
//               child: const Text(
//                 'Add Hours',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         DottedBorder(
//           color: Colors.grey.shade300,
//           strokeWidth: 1,
//           dashPattern: const [5, 5],
//           borderType: BorderType.RRect,
//           radius: const Radius.circular(8),
//           padding: const EdgeInsets.all(24),
//           child: Container(
//             color: AppColors.lightcolor,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'This schedule doesn\'t have any date-specific hours yet.',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Use date-specific hours for one-off adjustments to your availability.',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: AppColors.textColorSecond,
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }



// // lib\content\availability\widgets\date_specific_hours_section.dart
// import 'package:flutter/material.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:tabourak/colors/app_colors.dart';

// class DateSpecificHoursSection extends StatelessWidget {
//   const DateSpecificHoursSection({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'DATE-SPECIFIC HOURS',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textColorSecond,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.help_outline, size: 16),
//                   color: AppColors.textColorSecond,
//                   onPressed: () {},
//                 ),
//               ],
//             ),
//             TextButton(
//               onPressed: () {},
//               child: const Text(
//                 'Add Hours',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         DottedBorder(
//           color: Colors.grey.shade300,
//           strokeWidth: 1,
//           dashPattern: const [5, 5],
//           borderType: BorderType.RRect,
//           radius: const Radius.circular(8),
//           padding: const EdgeInsets.all(24),
//           child: Container(
//             color: Colors.grey.shade200,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'This schedule doesn\'t have any date-specific hours yet.',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Use date-specific hours for one-off adjustments to your availability.',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: AppColors.textColorSecond,
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


// // lib\content\availability\widgets\date_specific_hours_section.dart
// import 'package:flutter/material.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:tabourak/colors/app_colors.dart';

// class DateSpecificHoursSection extends StatelessWidget {
//   const DateSpecificHoursSection({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Date-Specific Hours',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textColorSecond,
//               ),
//             ),
//             TextButton(
//               onPressed: () {},
//               child: const Text(
//                 'Add Date-Specific Hours',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         DottedBorder(
//           color: Colors.grey.shade300, // Dashed border color
//           strokeWidth: 1, // Dashed border thickness
//           dashPattern: const [5, 5], // Dash pattern (5px dash, 5px gap)
//           borderType: BorderType.RRect, // Rounded rectangle border
//           radius: const Radius.circular(8), // Border radius
//           padding: const EdgeInsets.all(16), // Inner padding
//           child: Container(
//             color: Colors.grey.shade100, // Background color
//             child: const Column(
//               children: [
//                 Text(
//                   'This schedule doesn\'t have any date-specific hours yet.',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,                    color: AppColors.textColor,

//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'Use date-specific hours for one-off adjustments to your availability.',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: AppColors.textColorSecond,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }