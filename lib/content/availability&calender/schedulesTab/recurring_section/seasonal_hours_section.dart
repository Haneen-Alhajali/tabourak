// lib\content\availability&calender\schedulesTab\recurring_section\seasonal_hours_section.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/models/time_range.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tabourak/config/config.dart';
import 'package:tabourak/config/globals.dart';
import 'add_seasonal_hours_modal.dart';
import 'package:intl/intl.dart';
import 'package:tabourak/config/snackbar_helper.dart';

class SeasonalHoursSection extends StatefulWidget {
  final String scheduleId;
  final Future<Map<String, dynamic>?> Function() onAdd;
  final Function(Map<String, List<TimeRange>>) onAvailabilityUpdated;

  const SeasonalHoursSection({
    Key? key,
    required this.scheduleId,
    required this.onAdd,
    required this.onAvailabilityUpdated,
  }) : super(key: key);

  @override
  _SeasonalHoursSectionState createState() => _SeasonalHoursSectionState();
}

class _SeasonalHoursSectionState extends State<SeasonalHoursSection> {
  List<Map<String, dynamic>> _seasonalHours = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSeasonalHours();
  }

  Future<void> _fetchSeasonalHours() async {
    if (widget.scheduleId.isEmpty) {
      setState(() {
        _error = 'No schedule selected';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/seasonal-availability?scheduleId=${widget.scheduleId}'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _seasonalHours = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to load seasonal hours');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _editSeasonalHours(Map<String, dynamic> season) async {
    final Map<String, List<TimeRange>> availability = {};
    
    if (season['availability'] != null) {
      season['availability'].forEach((day, slots) {
        availability[day] = (slots as List).map((slot) {
          return TimeRange(
            TimeOfDay(hour: slot['start']['hour'], minute: slot['start']['minute']),
            TimeOfDay(hour: slot['end']['hour'], minute: slot['end']['minute']),
          );
        }).toList();
      });
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddSeasonalHoursModal(
        initialAvailability: availability,
        initialNickname: season['nickname'],
        initialDateRange: DateTimeRange(
          start: DateTime.parse(season['startDate']),
          end: DateTime.parse(season['endDate']),
        ),
        isEditing: true,
        scheduleId: widget.scheduleId,
        initialSeasonId: season['uuid'],
      ),
    );

    if (result != null) {
      await _saveSeasonalHours(
        season['uuid'],
        result['nickname'],
        result['dateRange'],
        result['availability'],
      );
    }
  }

  // Future<void> _saveSeasonalHours(
  //   String? seasonId,
  //   String nickname,
  //   DateTimeRange dateRange,
  //   Map<String, List<TimeRange>> availability,
  // ) async {
  //   setState(() {
  //     _isLoading = true;
  //     _error = null;
  //   });

  //   try {
  //     final response = await http.post(
  //       Uri.parse('${AppConfig.baseUrl}/api/seasonal-availability'),
  //       headers: {
  //         'Authorization': 'Bearer $globalAuthToken',
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode({
  //         'scheduleId': widget.scheduleId,
  //         'seasonId': seasonId,
  //         'nickname': nickname,
  //         'startDate': dateRange.start.toIso8601String(),
  //         'endDate': dateRange.end.toIso8601String(),
  //         'availability': _convertToApiFormat(availability),
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       await _fetchSeasonalHours();
  //       widget.onAvailabilityUpdated(availability);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Seasonal hours saved successfully')),
  //       );
  //     } else {
  //       final responseBody = json.decode(response.body);
  //       final error = responseBody['error'] ?? 'Failed to save seasonal hours';
        
  //       if (response.statusCode == 409 && responseBody['conflicts'] != null) {
  //         final conflicts = (responseBody['conflicts'] as List).map((c) => 
  //           '${c['nickname']} (${DateFormat.yMd().format(DateTime.parse(c['startDate']))} - '
  //           '${DateFormat.yMd().format(DateTime.parse(c['endDate']))})'
  //         ).join(', ');
          
  //         throw Exception('Date range overlaps with: $conflicts');
  //       } else {
  //         throw Exception(error);
  //       }
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _error = e.toString();
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to save seasonal hours: ${e.toString()}'),
  //         duration: const Duration(seconds: 5),
  //       ),
  //     );
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }
Future<void> _saveSeasonalHours(
  String? seasonId,
  String nickname,
  DateTimeRange dateRange,
  Map<String, List<TimeRange>> availability,
) async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/seasonal-availability'),
      headers: {
        'Authorization': 'Bearer $globalAuthToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'scheduleId': widget.scheduleId,
        'seasonId': seasonId,
        'nickname': nickname,
        'startDate': dateRange.start.toIso8601String(),
        'endDate': dateRange.end.toIso8601String(),
        'availability': _convertToApiFormat(availability),
      }),
    );

    if (response.statusCode == 200) {
      await _fetchSeasonalHours();
      widget.onAvailabilityUpdated(availability);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Seasonal hours saved successfully')),
      // );
      SnackbarHelper.showSuccess(context, 'Seasonal hours saved successfully');

    } else {
      // If there was an overlap that client-side check missed
      final responseBody = json.decode(response.body);
      if (response.statusCode == 409) {
        throw Exception('Date range conflict detected by server');
      } else {
        throw Exception('Failed to save seasonal hours');
      }
    }
  } catch (e) {
    // Don't show overlap errors here - they should have been caught in the modal
    if (!e.toString().contains('overlap') && !e.toString().contains('conflict')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> _deleteSeasonalHours(String seasonId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/seasonal-availability/$seasonId'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
        },
      );

      if (response.statusCode == 200) {
        await _fetchSeasonalHours();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seasonal hours deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete seasonal hours');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete seasonal hours: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _convertToApiFormat(Map<String, List<TimeRange>> availability) {
    final result = <String, dynamic>{};
    
    availability.forEach((day, timeRanges) {
      result[day] = timeRanges.map((range) {
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

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SEASONAL HOURS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorSecond,
              ),
            ),
            TextButton(
              onPressed: () async {
                final result = await widget.onAdd();
                if (result != null) {
                  await _saveSeasonalHours(
                    null,
                    result['nickname'],
                    result['dateRange'],
                    result['availability'],
                  );
                }
              },
              child: const Text(
                'Add Seasonal Hours',
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          )
        else if (_seasonalHours.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No seasonal hours added yet',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _seasonalHours.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final season = _seasonalHours[index];
              final startDate = DateTime.parse(season['startDate']);
              final endDate = DateTime.parse(season['endDate']);
              final isPast = endDate.isBefore(DateTime.now());
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                season['nickname'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (isPast)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Past',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${DateFormat.yMMMd().format(startDate)} - ${DateFormat.yMMMd().format(endDate)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: AppColors.primaryColor,
                          onPressed: () => _editSeasonalHours(season),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => _deleteSeasonalHours(season['uuid']),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}





// edit for overlap2
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:tabourak/config/config.dart';
// import 'package:tabourak/config/globals.dart';
// import 'add_seasonal_hours_modal.dart';
// import 'package:intl/intl.dart';

// class SeasonalHoursSection extends StatefulWidget {
//   final String scheduleId;
//   final Future<Map<String, dynamic>?> Function() onAdd;
//   final Function(Map<String, List<TimeRange>>) onAvailabilityUpdated;

//   const SeasonalHoursSection({
//     Key? key,
//     required this.scheduleId,
//     required this.onAdd,
//     required this.onAvailabilityUpdated,
//   }) : super(key: key);

//   @override
//   _SeasonalHoursSectionState createState() => _SeasonalHoursSectionState();
// }

// class _SeasonalHoursSectionState extends State<SeasonalHoursSection> {
//   List<Map<String, dynamic>> _seasonalHours = [];
//   bool _isLoading = false;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSeasonalHours();
//   }

//   Future<void> _fetchSeasonalHours() async {
//     if (widget.scheduleId.isEmpty) {
//       setState(() {
//         _error = 'No schedule selected';
//         _isLoading = false;
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/seasonal-availability?scheduleId=${widget.scheduleId}'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           _seasonalHours = List<Map<String, dynamic>>.from(data);
//         });
//       } else {
//         throw Exception('Failed to load seasonal hours');
//       }
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _editSeasonalHours(Map<String, dynamic> season) async {
//     // Convert the availability data to the correct type
//     final Map<String, List<TimeRange>> availability = {};
    
//     if (season['availability'] != null) {
//       season['availability'].forEach((day, slots) {
//         availability[day] = (slots as List).map((slot) {
//           return TimeRange(
//             TimeOfDay(hour: slot['start']['hour'], minute: slot['start']['minute']),
//             TimeOfDay(hour: slot['end']['hour'], minute: slot['end']['minute']),
//           );
//         }).toList();
//       });
//     }

//     final result = await showDialog<Map<String, dynamic>>(
//       context: context,
//       builder: (context) => AddSeasonalHoursModal(
//         initialAvailability: availability,
//         initialNickname: season['nickname'],
//         initialDateRange: DateTimeRange(
//           start: DateTime.parse(season['startDate']),
//           end: DateTime.parse(season['endDate']),
//         ),
//         isEditing: true,
//         scheduleId: widget.scheduleId,
//         initialSeasonId: season['uuid'],
//       ),
//     );

//     if (result != null) {
//       await _saveSeasonalHours(
//         season['uuid'],
//         result['nickname'],
//         result['dateRange'],
//         result['availability'],
//       );
//     }
//   }

//   Future<void> _saveSeasonalHours(
//     String? seasonId,
//     String nickname,
//     DateTimeRange dateRange,
//     Map<String, List<TimeRange>> availability,
//   ) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/seasonal-availability'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'scheduleId': widget.scheduleId,
//           'seasonId': seasonId,
//           'nickname': nickname,
//           'startDate': dateRange.start.toIso8601String(),
//           'endDate': dateRange.end.toIso8601String(),
//           'availability': _convertToApiFormat(availability),
//         }),
//       );

//       if (response.statusCode == 200) {
//         await _fetchSeasonalHours();
//         widget.onAvailabilityUpdated(availability);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Seasonal hours saved successfully')),
//         );
//       } else {
//         final responseBody = json.decode(response.body);
//         final error = responseBody['error'] ?? 'Failed to save seasonal hours';
        
//         if (response.statusCode == 409 && responseBody['conflicts'] != null) {
//           final conflicts = (responseBody['conflicts'] as List).map((c) => 
//             '${c['nickname']} (${DateFormat.yMd().format(DateTime.parse(c['startDate']))} - '
//             '${DateFormat.yMd().format(DateTime.parse(c['endDate']))})'
//           ).join(', ');
          
//           throw Exception('Date range overlaps with: $conflicts');
//         } else {
//           throw Exception(error);
//         }
//       }
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to save seasonal hours: ${e.toString()}'),
//           duration: const Duration(seconds: 5),
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _deleteSeasonalHours(String seasonId) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.delete(
//         Uri.parse('${AppConfig.baseUrl}/api/seasonal-availability/$seasonId'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         await _fetchSeasonalHours();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Seasonal hours deleted successfully')),
//         );
//       } else {
//         throw Exception('Failed to delete seasonal hours');
//       }
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete seasonal hours: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Map<String, dynamic> _convertToApiFormat(Map<String, List<TimeRange>> availability) {
//     final result = <String, dynamic>{};
    
//     availability.forEach((day, timeRanges) {
//       result[day] = timeRanges.map((range) {
//         return {
//           'start': {
//             'hour': range.start.hour,
//             'minute': range.start.minute,
//           },
//           'end': {
//             'hour': range.end.hour,
//             'minute': range.end.minute,
//           },
//         };
//       }).toList();
//     });

//     return result;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'SEASONAL HOURS',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textColorSecond,
//               ),
//             ),
//             TextButton(
//               onPressed: () async {
//                 final result = await widget.onAdd();
//                 if (result != null) {
//                   await _saveSeasonalHours(
//                     null,
//                     result['nickname'],
//                     result['dateRange'],
//                     result['availability'],
//                   );
//                 }
//               },
//               child: const Text(
//                 'Add Seasonal Hours',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         if (_isLoading)
//           const Center(child: CircularProgressIndicator())
//         else if (_error != null)
//           Text(
//             _error!,
//             style: const TextStyle(color: Colors.red),
//           )
//         else if (_seasonalHours.isEmpty)
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Center(
//               child: Text(
//                 'No seasonal hours added yet',
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//           )
//         else
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: _seasonalHours.length,
//             separatorBuilder: (context, index) => const SizedBox(height: 8),
//             itemBuilder: (context, index) {
//               final season = _seasonalHours[index];
//               final startDate = DateTime.parse(season['startDate']);
//               final endDate = DateTime.parse(season['endDate']);
//               final isPast = endDate.isBefore(DateTime.now());
              
//               return Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 season['nickname'],
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               if (isPast)
//                                 Container(
//                                   margin: const EdgeInsets.only(left: 8),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 8,
//                                     vertical: 2,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.red,
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: const Text(
//                                     'Past',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             '${DateFormat.yMMMd().format(startDate)} - ${DateFormat.yMMMd().format(endDate)}',
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit),
//                           color: AppColors.primaryColor,
//                           onPressed: () => _editSeasonalHours(season),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete),
//                           color: Colors.red,
//                           onPressed: () => _deleteSeasonalHours(season['uuid']),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//       ],
//     );
//   }
// }




 // edit for overlap

// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:tabourak/config/config.dart';
// import 'package:tabourak/config/globals.dart';
// import 'add_seasonal_hours_modal.dart';
// import 'package:intl/intl.dart'; // Added this import for DateFormat

// class SeasonalHoursSection extends StatefulWidget {
//   final String scheduleId;
//   final Future<Map<String, dynamic>?> Function() onAdd;
//   final Function(Map<String, List<TimeRange>>) onAvailabilityUpdated;

//   const SeasonalHoursSection({
//     Key? key,
//     required this.scheduleId,
//     required this.onAdd,
//     required this.onAvailabilityUpdated,
//   }) : super(key: key);

//   @override
//   _SeasonalHoursSectionState createState() => _SeasonalHoursSectionState();
// }

// class _SeasonalHoursSectionState extends State<SeasonalHoursSection> {
//   List<Map<String, dynamic>> _seasonalHours = [];
//   bool _isLoading = false;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSeasonalHours();
//   }

//   Future<void> _fetchSeasonalHours() async {
//     if (widget.scheduleId.isEmpty) {
//       setState(() {
//         _error = 'No schedule selected';
//         _isLoading = false;
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/seasonal-availability?scheduleId=${widget.scheduleId}'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           _seasonalHours = List<Map<String, dynamic>>.from(data);
//         });
//       } else {
//         throw Exception('Failed to load seasonal hours');
//       }
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Future<void> _editSeasonalHours(Map<String, dynamic> season) async {
//   //   final result = await showDialog<Map<String, dynamic>>(
//   //     context: context,
//   //     builder: (context) => AddSeasonalHoursModal(
//   //       initialAvailability: season['availability'],
//   //       initialNickname: season['nickname'],
//   //       initialDateRange: DateTimeRange(
//   //         start: DateTime.parse(season['startDate']),
//   //         end: DateTime.parse(season['endDate']),
//   //       ),
//   //       isEditing: true,
//   //     ),
//   //   );

//   //   if (result != null) {
//   //     await _saveSeasonalHours(
//   //       season['uuid'],
//   //       result['nickname'],
//   //       result['dateRange'],
//   //       result['availability'],
//   //     );
//   //   }
//   // }

// // Future<void> _editSeasonalHours(Map<String, dynamic> season) async {
// //   // Convert the availability data to the correct type
// //   final Map<String, List<TimeRange>> availability = {};
  
// //   if (season['availability'] != null) {
// //     season['availability'].forEach((day, slots) {
// //       availability[day] = (slots as List).map((slot) {
// //         return TimeRange(
// //           TimeOfDay(hour: slot['start']['hour'], minute: slot['start']['minute']),
// //           TimeOfDay(hour: slot['end']['hour'], minute: slot['end']['minute']),
// //         );
// //       }).toList();
// //     });
// //   }

// //   final result = await showDialog<Map<String, dynamic>>(
// //     context: context,
// //     builder: (context) => AddSeasonalHoursModal(
// //       initialAvailability: availability,
// //       initialNickname: season['nickname'],
// //       initialDateRange: DateTimeRange(
// //         start: DateTime.parse(season['startDate']),
// //         end: DateTime.parse(season['endDate']),
// //       ),
// //       isEditing: true,
// //     ),
// //   );

// //   if (result != null) {
// //     await _saveSeasonalHours(
// //       season['uuid'],
// //       result['nickname'],
// //       result['dateRange'],
// //       result['availability'],
// //     );
// //   }
// // }

// Future<void> _editSeasonalHours(Map<String, dynamic> season) async {
//   // Convert the availability data to the correct type
//   final Map<String, List<TimeRange>> availability = {};
  
//   if (season['availability'] != null) {
//     season['availability'].forEach((day, slots) {
//       availability[day] = (slots as List).map((slot) {
//         return TimeRange(
//           TimeOfDay(hour: slot['start']['hour'], minute: slot['start']['minute']),
//           TimeOfDay(hour: slot['end']['hour'], minute: slot['end']['minute']),
//         );
//       }).toList();
//     });
//   }

//   final result = await showDialog<Map<String, dynamic>>(
//     context: context,
//     builder: (context) => AddSeasonalHoursModal(
//       initialAvailability: availability,
//       initialNickname: season['nickname'],
//       initialDateRange: DateTimeRange(
//         start: DateTime.parse(season['startDate']),
//         end: DateTime.parse(season['endDate']),
//       ),
//       isEditing: true,
//     ),
//   );

//   if (result != null) {
//     await _saveSeasonalHours(
//       season['uuid'],
//       result['nickname'],
//       result['dateRange'],
//       result['availability'],
//     );
//   }
// }


//   Future<void> _saveSeasonalHours(
//     String? seasonId,
//     String nickname,
//     DateTimeRange dateRange,
//     Map<String, List<TimeRange>> availability,
//   ) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/seasonal-availability'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'scheduleId': widget.scheduleId,
//           'seasonId': seasonId,
//           'nickname': nickname,
//           'startDate': dateRange.start.toIso8601String(),
//           'endDate': dateRange.end.toIso8601String(),
//           'availability': _convertToApiFormat(availability),
//         }),
//       );

//       if (response.statusCode == 200) {
//         await _fetchSeasonalHours();
//         widget.onAvailabilityUpdated(availability);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Seasonal hours saved successfully')),
//         );
//       } else {
//         final error = json.decode(response.body)['error'] ?? 'Failed to save seasonal hours';
//         throw Exception(error);
//       }
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save seasonal hours: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _deleteSeasonalHours(String seasonId) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.delete(
//         Uri.parse('${AppConfig.baseUrl}/api/seasonal-availability/$seasonId'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         await _fetchSeasonalHours();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Seasonal hours deleted successfully')),
//         );
//       } else {
//         throw Exception('Failed to delete seasonal hours');
//       }
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete seasonal hours: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Map<String, dynamic> _convertToApiFormat(Map<String, List<TimeRange>> availability) {
//     final result = <String, dynamic>{};
    
//     availability.forEach((day, timeRanges) {
//       result[day] = timeRanges.map((range) {
//         return {
//           'start': {
//             'hour': range.start.hour,
//             'minute': range.start.minute,
//           },
//           'end': {
//             'hour': range.end.hour,
//             'minute': range.end.minute,
//           },
//         };
//       }).toList();
//     });

//     return result;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'SEASONAL HOURS',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textColorSecond,
//               ),
//             ),
//             TextButton(
//               onPressed: () async {
//                 final result = await widget.onAdd();
//                 if (result != null) {
//                   await _saveSeasonalHours(
//                     null,
//                     result['nickname'],
//                     result['dateRange'],
//                     result['availability'],
//                   );
//                 }
//               },
//               child: const Text(
//                 'Add Seasonal Hours',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         if (_isLoading)
//           const Center(child: CircularProgressIndicator())
//         else if (_error != null)
//           Text(
//             _error!,
//             style: const TextStyle(color: Colors.red),
//           )
//         else if (_seasonalHours.isEmpty)
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Center(
//               child: Text(
//                 'No seasonal hours added yet',
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//           )
//         else
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: _seasonalHours.length,
//             separatorBuilder: (context, index) => const SizedBox(height: 8),
//             itemBuilder: (context, index) {
//               final season = _seasonalHours[index];
//               final startDate = DateTime.parse(season['startDate']);
//               final endDate = DateTime.parse(season['endDate']);
//               final isPast = endDate.isBefore(DateTime.now());
              
//               return Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 season['nickname'],
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               if (isPast)
//                                 Container(
//                                   margin: const EdgeInsets.only(left: 8),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 8,
//                                     vertical: 2,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.red,
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: const Text(
//                                     'Past',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             '${DateFormat.yMMMd().format(startDate)} - ${DateFormat.yMMMd().format(endDate)}',
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit),
//                           color: AppColors.primaryColor,
//                           onPressed: () => _editSeasonalHours(season),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete),
//                           color: Colors.red,
//                           onPressed: () => _deleteSeasonalHours(season['uuid']),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//       ],
//     );
//   }
// }





//edit2 for add seasonal



// // lib\content\availability&calender\schedulesTab\recurring_section\seasonal_hours_section.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:tabourak/config/config.dart';
// import 'package:tabourak/config/globals.dart';
// import 'add_seasonal_hours_modal.dart';

// class SeasonalHoursSection extends StatefulWidget {
//   final String scheduleId;
//   final Function() onAdd;
//   final Function(Map<String, List<TimeRange>>) onAvailabilityUpdated;

//   const SeasonalHoursSection({
//     Key? key,
//     required this.scheduleId,
//     required this.onAdd,
//     required this.onAvailabilityUpdated,
//   }) : super(key: key);

//   @override
//   _SeasonalHoursSectionState createState() => _SeasonalHoursSectionState();
// }

// class _SeasonalHoursSectionState extends State<SeasonalHoursSection> {
//   List<Map<String, dynamic>> _seasonalHours = [];
//   bool _isLoading = false;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSeasonalHours();
//   }

//   // Future<void> _fetchSeasonalHours() async {
//   //   setState(() {
//   //     _isLoading = true;
//   //     _error = null;
//   //   });
// Future<void> _fetchSeasonalHours() async {
//   if (widget.scheduleId.isEmpty) {
//     setState(() {
//       _error = 'No schedule selected';
//       _isLoading = false;
//     });
//     return;
//   }

//   setState(() {
//     _isLoading = true;
//     _error = null;
//   });
//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/seasonal-availability?scheduleId=${widget.scheduleId}'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           _seasonalHours = List<Map<String, dynamic>>.from(data);
//         });
//       } else {
//         throw Exception('🛑🛑🛑 Failed to load seasonal hours 🛑🛑🛑');
//       }
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _editSeasonalHours(Map<String, dynamic> season) async {
//     final result = await showDialog(
//       context: context,
//       builder: (context) => AddSeasonalHoursModal(
//         initialAvailability: season['availability'],
//         initialNickname: season['nickname'],
//         initialDateRange: DateTimeRange(
//           start: DateTime.parse(season['startDate']),
//           end: DateTime.parse(season['endDate']),
//         ),
//         isEditing: true,
//       ),
//     );

//     if (result != null) {
//       await _saveSeasonalHours(
//         season['uuid'],
//         result['nickname'],
//         result['dateRange'],
//         result['availability'],
//       );
//     }
//   }

//   Future<void> _saveSeasonalHours(
//     String? seasonId,
//     String nickname,
//     DateTimeRange dateRange,
//     Map<String, List<TimeRange>> availability,
//   ) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/seasonal-availability'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'scheduleId': widget.scheduleId,
//           'seasonId': seasonId,
//           'nickname': nickname,
//           'startDate': dateRange.start.toIso8601String(),
//           'endDate': dateRange.end.toIso8601String(),
//           'availability': _convertToApiFormat(availability),
//         }),
//       );

//       if (response.statusCode == 200) {
//         await _fetchSeasonalHours();
//         widget.onAvailabilityUpdated(availability);
//       } else {
//         throw Exception('🛑🛑🛑 Failed to save seasonal hours 🛑🛑🛑');
//       }
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save seasonal hours: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _deleteSeasonalHours(String seasonId) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.delete(
//         Uri.parse('${AppConfig.baseUrl}/api/seasonal-availability/$seasonId'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         await _fetchSeasonalHours();
//       } else {
//         throw Exception('🛑🛑🛑 Failed to delete seasonal hours 🛑🛑🛑');
//       }
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete seasonal hours: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Map<String, dynamic> _convertToApiFormat(Map<String, List<TimeRange>> availability) {
//     final result = <String, dynamic>{};
    
//     availability.forEach((day, timeRanges) {
//       result[day] = timeRanges.map((range) {
//         return {
//           'start': {
//             'hour': range.start.hour,
//             'minute': range.start.minute,
//           },
//           'end': {
//             'hour': range.end.hour,
//             'minute': range.end.minute,
//           },
//         };
//       }).toList();
//     });

//     return result;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'SEASONAL HOURS',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textColorSecond,
//               ),
//             ),
//             TextButton(
//               onPressed: widget.onAdd,
//               child: const Text(
//                 'Add Seasonal Hours',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         if (_isLoading)
//           const Center(child: CircularProgressIndicator())
//         else if (_error != null)
//           Text(
//             _error!,
//             style: const TextStyle(color: Colors.red),
//           )
//         else if (_seasonalHours.isEmpty)
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Center(
//               child: Text(
//                 'No seasonal hours added yet',
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//           )
//         else
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: _seasonalHours.length,
//             separatorBuilder: (context, index) => const SizedBox(height: 8),
//             itemBuilder: (context, index) {
//               final season = _seasonalHours[index];
//               final startDate = DateTime.parse(season['startDate']);
//               final endDate = DateTime.parse(season['endDate']);
//               final isPast = endDate.isBefore(DateTime.now());
              
//               return Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 season['nickname'],
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               if (isPast)
//                                 Container(
//                                   margin: const EdgeInsets.only(left: 8),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 8,
//                                     vertical: 2,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.red,
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: const Text(
//                                     'Past',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             '${DateFormat.yMMMd().format(startDate)} - ${DateFormat.yMMMd().format(endDate)}',
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit),
//                           color: AppColors.primaryColor,
//                           onPressed: () => _editSeasonalHours(season),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete),
//                           color: Colors.red,
//                           onPressed: () => _deleteSeasonalHours(season['uuid']),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//       ],
//     );
//   }
// }


//edit










// // lib\content\availability&calender\schedulesTab\recurring_section\seasonal_hours_section.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'package:intl/intl.dart';

// class SeasonalHoursSection extends StatelessWidget {
//   final Map<DateTimeRange, Map<String, dynamic>> seasonalHours;
//   final Function(DateTimeRange) onEdit;
//   final Function(DateTimeRange) onDelete;
//   final Function() onAdd;

//   const SeasonalHoursSection({
//     Key? key,
//     required this.seasonalHours,
//     required this.onEdit,
//     required this.onDelete,
//     required this.onAdd,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'SEASONAL HOURS',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textColorSecond,
//               ),
//             ),
//             TextButton(
//               onPressed: onAdd,
//               child: const Text(
//                 'Add Seasonal Hours',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         if (seasonalHours.isEmpty)
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Center(
//               child: Text(
//                 'No seasonal hours added yet',
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//           )
//         else
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: seasonalHours.length,
//             separatorBuilder: (context, index) => const SizedBox(height: 8),
//             itemBuilder: (context, index) {
//               final entry = seasonalHours.entries.elementAt(index);
//               final dateRange = entry.key;
//               final data = entry.value;
//               final nickname = data['nickname'] as String? ?? 'Seasonal Hours';
//               final isPast = dateRange.end.isBefore(DateTime.now());
              
//               return Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 nickname,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               if (isPast)
//                                 Container(
//                                   margin: const EdgeInsets.only(left: 8),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 8,
//                                     vertical: 2,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.red,
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: const Text(
//                                     'Past',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             '${DateFormat.yMMMd().format(dateRange.start)} - ${DateFormat.yMMMd().format(dateRange.end)}',
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit),
//                           color: AppColors.primaryColor,
//                           onPressed: () => onEdit(dateRange),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete),
//                           color: Colors.red,
//                           onPressed: () => onDelete(dateRange),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//       ],
//     );
//   }
// }