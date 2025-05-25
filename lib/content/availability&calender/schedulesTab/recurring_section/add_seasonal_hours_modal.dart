// lib\content\availability&calender\schedulesTab\recurring_section\add_seasonal_hours_modal.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/models/time_range.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tabourak/config/config.dart';
import 'package:tabourak/config/globals.dart';
import 'availability_editor.dart';
import 'package:intl/intl.dart';

class AddSeasonalHoursModal extends StatefulWidget {
  final Map<String, List<TimeRange>> initialAvailability;
  final String? initialNickname;
  final DateTimeRange? initialDateRange;
  final Map<String, List<TimeRange>>? initialSeasonalAvailability;
  final bool isEditing;
  final String? scheduleId;
  final String? initialSeasonId;

  const AddSeasonalHoursModal({
    Key? key,
    required this.initialAvailability,
    this.initialNickname,
    this.initialDateRange,
    this.initialSeasonalAvailability,
    this.isEditing = false,
    this.scheduleId,
    this.initialSeasonId,
  }) : super(key: key);

  @override
  _AddSeasonalHoursModalState createState() => _AddSeasonalHoursModalState();
}

class _AddSeasonalHoursModalState extends State<AddSeasonalHoursModal> {
  late Map<String, List<TimeRange>> availability;
  late TextEditingController _nicknameController;
  DateTimeRange? _dateRange;
  bool _isNicknameEmpty = false;
  String? _overlapError;
  bool _isCheckingOverlap = false;
  bool _isSubmitting = false;
  bool _hasOverlap = false;

  @override
  void initState() {
    super.initState();
    availability = Map.from(widget.initialSeasonalAvailability ?? widget.initialAvailability);
    _nicknameController = TextEditingController(text: widget.initialNickname);
    _dateRange = widget.initialDateRange ?? DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 7)),
    );
    
    // Check for overlaps on initial load for both adding and editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForOverlaps();
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _checkForOverlaps() async {
    if (_dateRange == null) {
      setState(() {
        _hasOverlap = false;
        _overlapError = null;
      });
      return;
    }

    setState(() {
      _isCheckingOverlap = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/seasonal-availability/check-overlap'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'scheduleId': widget.scheduleId,
          'startDate': _dateRange!.start.toIso8601String(),
          'endDate': _dateRange!.end.toIso8601String(),
          'excludeSeasonId': widget.isEditing ? widget.initialSeasonId : null,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _hasOverlap = false;
          _overlapError = null;
        });
      } else if (response.statusCode == 409) {
        final responseBody = json.decode(response.body);
        final conflicts = (responseBody['conflicts'] as List).map((c) => 
          '${c['nickname']} (${DateFormat.yMd().format(DateTime.parse(c['startDate']))} - '
          '${DateFormat.yMd().format(DateTime.parse(c['endDate']))}'
        ).join('\n');
        
        setState(() {
          _hasOverlap = true;
          _overlapError = 'This date range overlaps with:\n$conflicts\n\nPlease adjust your dates.';
        });
      }
    } catch (e) {
      debugPrint('Error checking overlaps: $e');
      setState(() {
        _hasOverlap = false;
        _overlapError = null;
      });
    } finally {
      setState(() {
        _isCheckingOverlap = false;
      });
    }
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final initialDateRange = _dateRange ?? DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 7)),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _overlapError = null;
        _hasOverlap = false;
      });
      
      await _checkForOverlaps();
    }
  }

  Future<void> _validateAndSubmit() async {
    setState(() {
      _isNicknameEmpty = false;
    });

    if (_nicknameController.text.isEmpty) {
      setState(() {
        _isNicknameEmpty = true;
      });
      return;
    }

    if (_dateRange == null) {
      setState(() {
        _overlapError = 'Please select a date range';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Final overlap check before submission
      await _checkForOverlaps();
      if (_hasOverlap) {
        return;
      }

      final result = {
        'nickname': _nicknameController.text,
        'dateRange': _dateRange!,
        'availability': availability,
      };

      Navigator.of(context).pop(result);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isEditing ? 'Edit Seasonal Hours' : 'Add Seasonal Hours',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: AppColors.textColorSecond,
                  ),
                ],
              ),
            ),
            
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nickname',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nicknameController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Summer Hours or Holiday Hours',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: _isNicknameEmpty ? Colors.red : Colors.grey,
                              ),
                            ),
                            errorText: _isNicknameEmpty ? 'Please enter a nickname' : null,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: _isNicknameEmpty ? Colors.red : AppColors.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && _isNicknameEmpty) {
                              setState(() {
                                _isNicknameEmpty = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Date Range',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                        
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _overlapError != null 
                                ? Colors.red 
                                : Colors.grey.shade400,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isCheckingOverlap ? null : () => _pickDateRange(context),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (_isCheckingOverlap)
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        else
                                          Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: _overlapError != null 
                                              ? Colors.red 
                                              : AppColors.textColor,
                                          ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _dateRange != null
                                            ? '${DateFormat.MMMd().format(_dateRange!.start)}, ${_dateRange!.start.year} - ${DateFormat.MMMd().format(_dateRange!.end)}, ${_dateRange!.end.year}'
                                            : 'Select Date Range',
                                          style: TextStyle(
                                            color: _overlapError != null 
                                              ? Colors.red 
                                              : AppColors.textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      size: 20,
                                      color: _overlapError != null 
                                        ? Colors.red 
                                        : AppColors.textColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        if (_overlapError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                border: Border.all(color: Colors.red.shade200),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _overlapError!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recurring Weekly Hours',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AvailabilityEditor(
                            initialAvailability: availability,
                            onSave: (updatedAvailability) {
                              setState(() {
                                availability = updatedAvailability;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || _isCheckingOverlap || _hasOverlap) 
                      ? null 
                      : _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_isSubmitting || _isCheckingOverlap || _hasOverlap)
                        ? Colors.grey
                        : AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: _isSubmitting || _isCheckingOverlap
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          widget.isEditing ? 'Save Changes' : 'Add Seasonal Hours',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//edit for overlap2

// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:tabourak/config/config.dart';
// import 'package:tabourak/config/globals.dart';
// import 'availability_editor.dart';
// import 'package:intl/intl.dart';

// class AddSeasonalHoursModal extends StatefulWidget {
//   final Map<String, List<TimeRange>> initialAvailability;
//   final String? initialNickname;
//   final DateTimeRange? initialDateRange;
//   final Map<String, List<TimeRange>>? initialSeasonalAvailability;
//   final bool isEditing;
//   final String? scheduleId;
//   final String? initialSeasonId;

//   const AddSeasonalHoursModal({
//     Key? key,
//     required this.initialAvailability,
//     this.initialNickname,
//     this.initialDateRange,
//     this.initialSeasonalAvailability,
//     this.isEditing = false,
//     this.scheduleId,
//     this.initialSeasonId,
//   }) : super(key: key);

//   @override
//   _AddSeasonalHoursModalState createState() => _AddSeasonalHoursModalState();
// }

// class _AddSeasonalHoursModalState extends State<AddSeasonalHoursModal> {
//   late Map<String, List<TimeRange>> availability;
//   late TextEditingController _nicknameController;
//   DateTimeRange? _dateRange;
//   bool _isNicknameEmpty = false;
//   String? _overlapError;
//   bool _isCheckingOverlap = false;

//   @override
//   void initState() {
//     super.initState();
//     availability = Map.from(widget.initialSeasonalAvailability ?? widget.initialAvailability);
//     _nicknameController = TextEditingController(text: widget.initialNickname);
//     _dateRange = widget.initialDateRange ?? DateTimeRange(
//       start: DateTime.now(),
//       end: DateTime.now().add(const Duration(days: 7)),
//     );
//   }

//   @override
//   void dispose() {
//     _nicknameController.dispose();
//     super.dispose();
//   }

//   Future<bool> _checkForOverlaps() async {
//     if (_dateRange == null) return false;

//     setState(() {
//       _isCheckingOverlap = true;
//       _overlapError = null;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/seasonal-availability/check-overlap'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'scheduleId': widget.scheduleId,
//           'startDate': _dateRange!.start.toIso8601String(),
//           'endDate': _dateRange!.end.toIso8601String(),
//           'excludeSeasonId': widget.isEditing ? widget.initialSeasonId : null,
//         }),
//       );

//       if (response.statusCode == 200) {
//         return false; // No overlaps
//       } else if (response.statusCode == 409) {
//         final responseBody = json.decode(response.body);
//         final conflicts = (responseBody['conflicts'] as List).map((c) => 
//           '${c['nickname']} (${DateFormat.yMd().format(DateTime.parse(c['startDate']))} - '
//           '${DateFormat.yMd().format(DateTime.parse(c['endDate']))})'
//         ).join(', ');
        
//         setState(() {
//           _overlapError = 'Date range overlaps with: $conflicts';
//         });
//         return true;
//       }
//       return false;
//     } catch (e) {
//       // If there's an error, we'll let the server handle the final validation
//       return false;
//     } finally {
//       setState(() {
//         _isCheckingOverlap = false;
//       });
//     }
//   }

//   Future<void> _pickDateRange(BuildContext context) async {
//     final initialDateRange = _dateRange ?? DateTimeRange(
//       start: DateTime.now(),
//       end: DateTime.now().add(const Duration(days: 7)),
//     );

//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(DateTime.now().year + 5),
//       initialDateRange: initialDateRange,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.primaryColor,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: AppColors.textColor,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         _dateRange = picked;
//         _overlapError = null;
//       });
      
//       // Check for overlaps immediately after selecting dates
//       await _checkForOverlaps();
//     }
//   }

//   void _validateAndSubmit() async {
//     if (_nicknameController.text.isEmpty) {
//       setState(() {
//         _isNicknameEmpty = true;
//       });
//       return;
//     }

//     if (_dateRange == null) {
//       setState(() {
//         _overlapError = 'Please select a date range';
//       });
//       return;
//     }

//     // Check for overlaps first
//     final hasOverlaps = await _checkForOverlaps();
//     if (hasOverlaps) {
//       return; // Error message already set by _checkForOverlaps
//     }

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(child: CircularProgressIndicator()),
//     );

//     try {
//       final result = {
//         'nickname': _nicknameController.text,
//         'dateRange': _dateRange!,
//         'availability': availability,
//       };

//       Navigator.of(context).pop();
//       Navigator.of(context).pop(result);
//     } catch (e) {
//       Navigator.of(context).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save: ${e.toString()}')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: AppColors.backgroundColor,
//       insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 600),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.edit,
//                     color: AppColors.primaryColor,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     widget.isEditing ? 'Edit Seasonal Hours' : 'Add Seasonal Hours',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textColor,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.of(context).pop(),
//                     color: AppColors.textColorSecond,
//                   ),
//                 ],
//               ),
//             ),
            
//             // Form
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Nickname Field
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Nickname',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _nicknameController,
//                           decoration: InputDecoration(
//                             hintText: 'e.g. Summer Hours or Holiday Hours',
//                             border: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: _isNicknameEmpty ? Colors.red : Colors.grey,
//                               ),
//                             ),
//                             errorText: _isNicknameEmpty ? 'Please enter a nickname' : null,
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 10,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: _isNicknameEmpty ? Colors.red : AppColors.primaryColor,
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                           onChanged: (value) {
//                             if (value.isNotEmpty && _isNicknameEmpty) {
//                               setState(() {
//                                 _isNicknameEmpty = false;
//                               });
//                             }
//                           },
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Date Range Section
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           margin: const EdgeInsets.only(bottom: 4),
//                           child: Text(
//                             'Date Range',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.textColor,
//                             ),
//                           ),
//                         ),
                        
//                         // Date Range Picker Button
//                         Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               color: _overlapError != null 
//                                 ? Colors.red 
//                                 : Colors.grey.shade400,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               onTap: _isCheckingOverlap ? null : () => _pickDateRange(context),
//                               borderRadius: BorderRadius.circular(6),
//                               child: Container(
//                                 height: 40,
//                                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         if (_isCheckingOverlap)
//                                           const SizedBox(
//                                             width: 16,
//                                             height: 16,
//                                             child: CircularProgressIndicator(strokeWidth: 2),
//                                           )
//                                         else
//                                           Icon(
//                                             Icons.calendar_today,
//                                             size: 16,
//                                             color: _overlapError != null 
//                                               ? Colors.red 
//                                               : AppColors.textColor,
//                                           ),
//                                         const SizedBox(width: 8),
//                                         Text(
//                                           _dateRange != null
//                                             ? '${DateFormat.MMMd().format(_dateRange!.start)}, ${_dateRange!.start.year} - ${DateFormat.MMMd().format(_dateRange!.end)}, ${_dateRange!.end.year}'
//                                             : 'Select Date Range',
//                                           style: TextStyle(
//                                             color: _overlapError != null 
//                                               ? Colors.red 
//                                               : AppColors.textColor,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Icon(
//                                       Icons.arrow_drop_down,
//                                       size: 20,
//                                       color: _overlapError != null 
//                                         ? Colors.red 
//                                         : AppColors.textColor,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
                        
//                         // Overlap Error Message
//                         if (_overlapError != null)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 8),
//                             child: Text(
//                               _overlapError!,
//                               style: const TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Weekly Hours Section
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Recurring Weekly Hours',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
                        
//                         Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: AvailabilityEditor(
//                             initialAvailability: availability,
//                             onSave: (updatedAvailability) {
//                               setState(() {
//                                 availability = updatedAvailability;
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             // Footer
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   top: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isCheckingOverlap ? null : _validateAndSubmit,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryColor,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   child: Text(
//                     widget.isEditing ? 'Save Changes' : 'Add Seasonal Hours',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }











// edit for overlap

// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'availability_editor.dart';

// class AddSeasonalHoursModal extends StatefulWidget {
//   final Map<String, List<TimeRange>> initialAvailability;
//   final String? initialNickname;
//   final DateTimeRange? initialDateRange;
//   final Map<String, List<TimeRange>>? initialSeasonalAvailability;
//   final bool isEditing;

//   const AddSeasonalHoursModal({
//     Key? key,
//     required this.initialAvailability,
//     this.initialNickname,
//     this.initialDateRange,
//     this.initialSeasonalAvailability,
//     this.isEditing = false,
//   }) : super(key: key);

//   @override
//   _AddSeasonalHoursModalState createState() => _AddSeasonalHoursModalState();
// }

// class _AddSeasonalHoursModalState extends State<AddSeasonalHoursModal> {
//   late Map<String, List<TimeRange>> availability;
//   late TextEditingController _nicknameController;
//   DateTimeRange? _dateRange;
//   bool _isNicknameEmpty = false;

//   @override
//   void initState() {
//     super.initState();
//     availability = Map.from(widget.initialSeasonalAvailability ?? widget.initialAvailability);
//     _nicknameController = TextEditingController(text: widget.initialNickname);
//     _dateRange = widget.initialDateRange ?? DateTimeRange(
//       start: DateTime.now(),
//       end: DateTime.now().add(const Duration(days: 7)),
//     );
//   }

//   @override
//   void dispose() {
//     _nicknameController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickDateRange(BuildContext context) async {
//     final initialDateRange = _dateRange ?? DateTimeRange(
//       start: DateTime.now(),
//       end: DateTime.now().add(const Duration(days: 7)),
//     );

//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(DateTime.now().year + 5),
//       initialDateRange: initialDateRange,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.primaryColor,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: AppColors.textColor,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         _dateRange = picked;
//       });
//     }
//   }

// void _validateAndSubmit() async {
//   if (_nicknameController.text.isEmpty) {
//     setState(() {
//       _isNicknameEmpty = true;
//     });
//     return;
//   }

//   if (_dateRange == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Please select a date range')),
//     );
//     return;
//   }

//   // Show loading indicator
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => const Center(child: CircularProgressIndicator()),
//   );

//   try {
//     // Call the parent widget's save function with the new data
//     final result = {
//       'nickname': _nicknameController.text,
//       'dateRange': _dateRange!,
//       'availability': availability,
//     };

//     Navigator.of(context).pop(); // Close loading dialog
//     Navigator.of(context).pop(result); // Return result to parent
//   } catch (e) {
//     Navigator.of(context).pop(); // Close loading dialog
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Failed to save: ${e.toString()}')),
//     );
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: AppColors.backgroundColor,
//       insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 600),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.edit,
//                     color: AppColors.primaryColor,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     widget.isEditing ? 'Edit Seasonal Hours' : 'Add Seasonal Hours',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textColor,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.of(context).pop(),
//                     color: AppColors.textColorSecond,
//                   ),
//                 ],
//               ),
//             ),
            
//             // Form
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Nickname Field
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Nickname',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _nicknameController,
//                           decoration: InputDecoration(
//                             hintText: 'e.g. Summer Hours or Holiday Hours',
//                             border: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: _isNicknameEmpty ? Colors.red : Colors.grey,
//                               ),
//                             ),
//                             errorText: _isNicknameEmpty ? 'Please enter a nickname' : null,
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 10,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: _isNicknameEmpty ? Colors.red : AppColors.primaryColor,
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                           onChanged: (value) {
//                             if (value.isNotEmpty && _isNicknameEmpty) {
//                               setState(() {
//                                 _isNicknameEmpty = false;
//                               });
//                             }
//                           },
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Date Range Picker
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Date Range',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         OutlinedButton(
//                           onPressed: () => _pickDateRange(context),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                             side: BorderSide(
//                               color: _dateRange == null ? Colors.red : Colors.grey.shade400,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.calendar_today,
//                                 size: 16,
//                                 color: _dateRange == null ? Colors.red : AppColors.textColor,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 _dateRange != null
//                                     ? '${_dateRange!.start.year}-${_dateRange!.start.month}-${_dateRange!.start.day} - '
//                                         '${_dateRange!.end.year}-${_dateRange!.end.month}-${_dateRange!.end.day}'
//                                     : 'Select Date Range',
//                                 style: TextStyle(
//                                   color: _dateRange == null ? Colors.red : AppColors.textColor,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Icon(
//                                 Icons.arrow_drop_down,
//                                 size: 16,
//                                 color: _dateRange == null ? Colors.red : AppColors.textColor,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Weekly Hours Section
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Recurring Weekly Hours',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
                        
//                         Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: AvailabilityEditor(
//                             initialAvailability: availability,
//                             onSave: (updatedAvailability) {
//                               setState(() {
//                                 availability = updatedAvailability;
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             // Footer
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   top: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _validateAndSubmit,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryColor,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   child: Text(
//                     widget.isEditing ? 'Save Changes' : 'Add Seasonal Hours',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

















//edit 

// // lib\content\availability&calender\schedulesTab\recurring_section\add_seasonal_hours_modal.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'availability_editor.dart';

// class AddSeasonalHoursModal extends StatefulWidget {
//   final Map<String, List<TimeRange>> initialAvailability;
//   final String? initialNickname;
//   final DateTimeRange? initialDateRange;
//   final Map<String, List<TimeRange>>? initialSeasonalAvailability;
//   final bool isEditing;

//   const AddSeasonalHoursModal({
//     Key? key,
//     required this.initialAvailability,
//     this.initialNickname,
//     this.initialDateRange,
//     this.initialSeasonalAvailability,
//     this.isEditing = false,
//   }) : super(key: key);

//   @override
//   _AddSeasonalHoursModalState createState() => _AddSeasonalHoursModalState();
// }

// class _AddSeasonalHoursModalState extends State<AddSeasonalHoursModal> {
//   late Map<String, List<TimeRange>> availability;
//   late TextEditingController _nicknameController;
//   DateTimeRange? _dateRange;
//   bool _isNicknameEmpty = false;

//   @override
//   void initState() {
//     super.initState();
//     availability = Map.from(widget.initialSeasonalAvailability ?? widget.initialAvailability);
//     _nicknameController = TextEditingController(text: widget.initialNickname);
//     _dateRange = widget.initialDateRange ?? DateTimeRange(
//       start: DateTime.now(),
//       end: DateTime.now().add(const Duration(days: 7)),
//     );
//   }

//   @override
//   void dispose() {
//     _nicknameController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickDateRange(BuildContext context) async {
//     final initialDateRange = _dateRange ?? DateTimeRange(
//       start: DateTime.now(),
//       end: DateTime.now().add(const Duration(days: 7)),
//     );

//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(DateTime.now().year + 5),
//       initialDateRange: initialDateRange,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.primaryColor,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: AppColors.textColor,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         _dateRange = picked;
//       });
//     }
//   }

//   void _validateAndSubmit() {
//     if (_nicknameController.text.isEmpty) {
//       setState(() {
//         _isNicknameEmpty = true;
//       });
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   const SnackBar(content: Text('Please enter a nickname')),
//       // );
//       return;
//     }

//     if (_dateRange == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a date range')),
//       );
//       return;
//     }

//     Navigator.of(context).pop({
//       'nickname': _nicknameController.text,
//       'dateRange': _dateRange!,
//       'availability': availability,
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: AppColors.backgroundColor,
//       insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 600),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.edit,
//                     color: AppColors.primaryColor,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     widget.isEditing ? 'Edit Seasonal Hours' : 'Add Seasonal Hours',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textColor,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.of(context).pop(),
//                     color: AppColors.textColorSecond,
//                   ),
//                 ],
//               ),
//             ),
            
//             // Form
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Nickname Field
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Nickname',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _nicknameController,
//                           decoration: InputDecoration(
//                             hintText: 'e.g. Summer Hours or Holiday Hours',
//                             border: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: _isNicknameEmpty ? Colors.red : Colors.grey,
//                               ),
//                             ),
//                             errorText: _isNicknameEmpty ? 'Please enter a nickname' : null,
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 10,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: _isNicknameEmpty ? Colors.red : AppColors.primaryColor,
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                           onChanged: (value) {
//                             if (value.isNotEmpty && _isNicknameEmpty) {
//                               setState(() {
//                                 _isNicknameEmpty = false;
//                               });
//                             }
//                           },
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Date Range Picker
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Date Range',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         OutlinedButton(
//                           onPressed: () => _pickDateRange(context),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                             side: BorderSide(
//                               color: _dateRange == null ? Colors.red : Colors.grey.shade400,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.calendar_today,
//                                 size: 16,
//                                 color: _dateRange == null ? Colors.red : AppColors.textColor,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 _dateRange != null
//                                     ? '${_dateRange!.start.year}-${_dateRange!.start.month}-${_dateRange!.start.day} - '
//                                         '${_dateRange!.end.year}-${_dateRange!.end.month}-${_dateRange!.end.day}'
//                                     : 'Select Date Range',
//                                 style: TextStyle(
//                                   color: _dateRange == null ? Colors.red : AppColors.textColor,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Icon(
//                                 Icons.arrow_drop_down,
//                                 size: 16,
//                                 color: _dateRange == null ? Colors.red : AppColors.textColor,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Weekly Hours Section
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Recurring Weekly Hours',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
                        
//                         Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: AvailabilityEditor(
//                             initialAvailability: availability,
//                             onSave: (updatedAvailability) {
//                               setState(() {
//                                 availability = updatedAvailability;
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             // Footer
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   top: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _validateAndSubmit,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryColor,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   child: Text(
//                     widget.isEditing ? 'Save Changes' : 'Add Seasonal Hours',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






// // lib\content\availability&calender\schedulesTab\recurring_section\add_seasonal_hours_modal.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'availability_editor.dart';

// class AddSeasonalHoursModal extends StatefulWidget {
//   final Map<String, List<TimeRange>> initialAvailability;
//   final String? initialNickname;
//   final DateTimeRange? initialDateRange;
//   final Map<String, List<TimeRange>>? initialSeasonalAvailability;
//   final bool isEditing;

//   const AddSeasonalHoursModal({
//     Key? key,
//     required this.initialAvailability,
//     this.initialNickname,
//     this.initialDateRange,
//     this.initialSeasonalAvailability,
//     this.isEditing = false,
//   }) : super(key: key);

//   @override
//   _AddSeasonalHoursModalState createState() => _AddSeasonalHoursModalState();
// }

// class _AddSeasonalHoursModalState extends State<AddSeasonalHoursModal> {
//   late Map<String, List<TimeRange>> availability;
//   late TextEditingController _nicknameController;
//   DateTimeRange? _dateRange;
//   bool _isNicknameEmpty = false;

//   @override
//   void initState() {
//     super.initState();
//     availability = Map.from(widget.initialSeasonalAvailability ?? widget.initialAvailability);
//     _nicknameController = TextEditingController(text: widget.initialNickname);
//     _dateRange = widget.initialDateRange ?? DateTimeRange(
//       start: DateTime.now(),
//       end: DateTime.now().add(const Duration(days: 7)),
//     );
//   }

//   @override
//   void dispose() {
//     _nicknameController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickDateRange(BuildContext context) async {
//     final initialDateRange = _dateRange ?? DateTimeRange(
//       start: DateTime.now(),
//       end: DateTime.now().add(const Duration(days: 7)),
//     );

//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(DateTime.now().year + 5),
//       initialDateRange: initialDateRange,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.primaryColor,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: AppColors.textColor,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         _dateRange = picked;
//       });
//     }
//   }

//   void _validateAndSubmit() {
//     if (_nicknameController.text.isEmpty) {
//       setState(() {
//         _isNicknameEmpty = true;
//       });
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   const SnackBar(content: Text('Please enter a nickname')),
//       // );
//       return;
//     }

//     if (_dateRange == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a date range')),
//       );
//       return;
//     }

//     Navigator.of(context).pop({
//       'nickname': _nicknameController.text,
//       'dateRange': _dateRange!,
//       'availability': availability,
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: AppColors.backgroundColor,
//       insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 600),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.edit,
//                     color: AppColors.primaryColor,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     widget.isEditing ? 'Edit Seasonal Hours' : 'Add Seasonal Hours',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textColor,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.of(context).pop(),
//                     color: AppColors.textColorSecond,
//                   ),
//                 ],
//               ),
//             ),
            
//             // Form
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Nickname Field
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Nickname',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _nicknameController,
//                           decoration: InputDecoration(
//                             hintText: 'e.g. Summer Hours or Holiday Hours',
//                             border: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: _isNicknameEmpty ? Colors.red : Colors.grey,
//                               ),
//                             ),
//                             errorText: _isNicknameEmpty ? 'Please enter a nickname' : null,
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 10,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: _isNicknameEmpty ? Colors.red : AppColors.primaryColor,
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                           onChanged: (value) {
//                             if (value.isNotEmpty && _isNicknameEmpty) {
//                               setState(() {
//                                 _isNicknameEmpty = false;
//                               });
//                             }
//                           },
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Date Range Picker
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Date Range',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         OutlinedButton(
//                           onPressed: () => _pickDateRange(context),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                             side: BorderSide(
//                               color: _dateRange == null ? Colors.red : Colors.grey.shade400,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.calendar_today,
//                                 size: 16,
//                                 color: _dateRange == null ? Colors.red : AppColors.textColor,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 _dateRange != null
//                                     ? '${_dateRange!.start.year}-${_dateRange!.start.month}-${_dateRange!.start.day} - '
//                                         '${_dateRange!.end.year}-${_dateRange!.end.month}-${_dateRange!.end.day}'
//                                     : 'Select Date Range',
//                                 style: TextStyle(
//                                   color: _dateRange == null ? Colors.red : AppColors.textColor,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Icon(
//                                 Icons.arrow_drop_down,
//                                 size: 16,
//                                 color: _dateRange == null ? Colors.red : AppColors.textColor,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Weekly Hours Section
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Recurring Weekly Hours',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
                        
//                         Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: AvailabilityEditor(
//                             initialAvailability: availability,
//                             onSave: (updatedAvailability) {
//                               setState(() {
//                                 availability = updatedAvailability;
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             // Footer
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   top: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _validateAndSubmit,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryColor,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   child: Text(
//                     widget.isEditing ? 'Save Changes' : 'Add Seasonal Hours',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// lib\content\availability&calender\schedulesTab\recurring_section\add_seasonal_hours_modal.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'availability_editor.dart';

// class AddSeasonalHoursModal extends StatefulWidget {
//   final Map<String, List<TimeRange>> initialAvailability;

//   const AddSeasonalHoursModal({
//     Key? key,
//     required this.initialAvailability,
//   }) : super(key: key);

//   @override
//   _AddSeasonalHoursModalState createState() => _AddSeasonalHoursModalState();
// }

// class _AddSeasonalHoursModalState extends State<AddSeasonalHoursModal> {
//   late Map<String, List<TimeRange>> availability;
//   late TextEditingController _nicknameController;
//   DateTimeRange? _dateRange;

//   @override
//   void initState() {
//     super.initState();
//     availability = Map.from(widget.initialAvailability);
//     _nicknameController = TextEditingController();
//     _dateRange = DateTimeRange(
//       start: DateTime.now(),
//       end: DateTime.now().add(const Duration(days: 7)),
//     );
//   }

//   @override
//   void dispose() {
//     _nicknameController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickDateRange(BuildContext context) async {
//     final initialDateRange = _dateRange ?? DateTimeRange(
//       start: DateTime.now(),
//       end: DateTime.now().add(const Duration(days: 7)),
//     );

//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(DateTime.now().year + 5),
//       initialDateRange: initialDateRange,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.primaryColor,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: AppColors.textColor,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         _dateRange = picked;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//             backgroundColor: AppColors.backgroundColor,
//       insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 600),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.edit,
//                     color: AppColors.primaryColor,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Add Seasonal Hours',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textColor,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.of(context).pop(),
//                     color: AppColors.textColorSecond,
//                   ),
//                 ],
//               ),
//             ),
            
//             // Form
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Nickname Field
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Nickname',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _nicknameController,
//                           decoration: InputDecoration(
//                             hintText: 'e.g. Summer Hours or Holiday Hours',
//                             border: const OutlineInputBorder(),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 10,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: AppColors.primaryColor,
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Date Range Picker
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Date Range',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         OutlinedButton(
//                           onPressed: () => _pickDateRange(context),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                             side: BorderSide(color: Colors.grey.shade400),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.calendar_today,
//                                 size: 16,
//                                 color: AppColors.textColor,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 _dateRange != null
//                                     ? '${_dateRange!.start.year}-${_dateRange!.start.month}-${_dateRange!.start.day} - '
//                                         '${_dateRange!.end.year}-${_dateRange!.end.month}-${_dateRange!.end.day}'
//                                     : 'Select Date Range',
//                                 style: TextStyle(color: AppColors.textColor),
//                               ),
//                               const SizedBox(width: 8),
//                               Icon(
//                                 Icons.arrow_drop_down,
//                                 size: 16,
//                                 color: AppColors.textColor,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Weekly Hours Section
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Recurring Weekly Hours',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
                        
//                         // Reuse the AvailabilityEditor widget
//                         Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: AvailabilityEditor(
//                             initialAvailability: availability,
//                             onSave: (updatedAvailability) {
//                               setState(() {
//                                 availability = updatedAvailability;
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             // Footer
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   top: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: SizedBox(
//                 width: double.infinity,
//                 // child: ElevatedButton(
//                 //   onPressed: () {
//                 //     // Handle save logic here
//                 //     Navigator.of(context).pop();
//                 //   },
//                 //   style: ElevatedButton.styleFrom(
//                 //     backgroundColor: AppColors.primaryColor,
//                 //     padding: const EdgeInsets.symmetric(vertical: 12),
//                 //     shape: RoundedRectangleBorder(
//                 //       borderRadius: BorderRadius.circular(4),
//                 //     ),
//                 //   ),
//                 //   child: const Text(
//                 //     'Add Seasonal Hours',
//                 //     style: TextStyle(
//                 //       color: Colors.white,
//                 //       fontWeight: FontWeight.bold,
//                 //     ),
//                 //   ),
//                 // ),
// child: ElevatedButton(
//   onPressed: () {
//     if (_nicknameController.text.isEmpty || _dateRange == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all fields')),
//       );
//       return;
//     }
    
//     Navigator.of(context).pop({
//       'nickname': _nicknameController.text,
//       'dateRange': _dateRange!,
//       'availability': availability,
//     });
//   },
//   style: ElevatedButton.styleFrom(
//     backgroundColor: AppColors.primaryColor,
//     padding: const EdgeInsets.symmetric(vertical: 12),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(4),
//     ),
//   ),
//   child: const Text(
//     'Add Seasonal Hours',
//     style: TextStyle(
//       color: Colors.white,
//       fontWeight: FontWeight.bold,
//     ),
//   ),
// ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/content/availability/widgets/add_seasonal_hours_modal.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/models/time_range.dart';

// class AddSeasonalHoursModal extends StatefulWidget {
//   final Map<String, List<TimeRange>> initialAvailability;

//   const AddSeasonalHoursModal({
//     Key? key,
//     required this.initialAvailability,
//   }) : super(key: key);

//   @override
//   _AddSeasonalHoursModalState createState() => _AddSeasonalHoursModalState();
// }

// class _AddSeasonalHoursModalState extends State<AddSeasonalHoursModal> {
//   late Map<String, List<TimeRange>> availability;
//   late TextEditingController _nicknameController;
//   DateTimeRange? _dateRange;

//   @override
//   void initState() {
//     super.initState();
//     availability = Map.from(widget.initialAvailability);
//     _nicknameController = TextEditingController();
//     _dateRange = DateTimeRange(
//       start: DateTime.now(),
//       end: DateTime.now().add(const Duration(days: 7)),
//     );
//   }

//   @override
//   void dispose() {
//     _nicknameController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickDateRange(BuildContext context) async {
//     final initialDateRange = _dateRange ?? DateTimeRange(
//       start: DateTime.now(),
//       end: DateTime.now().add(const Duration(days: 7)),
//     );

//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(DateTime.now().year + 5),
//       initialDateRange: initialDateRange,
//     );

//     if (picked != null) {
//       setState(() {
//         _dateRange = picked;
//       });
//     }
//   }

//   Future<void> _pickTime(BuildContext context, bool isStart, TimeRange range) async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: isStart ? range.start : range.end,
//     );

//     if (picked != null) {
//       setState(() {
//         if (isStart) {
//           range.start = picked;
//         } else {
//           range.end = picked;
//         }
//       });
//     }
//   }

//   void _addTimeSlot(String day) {
//     setState(() {
//       if (availability[day]!.isEmpty) {
//         availability[day]!.add(TimeRange(
//           const TimeOfDay(hour: 9, minute: 0),
//           const TimeOfDay(hour: 17, minute: 0),
//         ));
//       } else {
//         final lastSlot = availability[day]!.last;
//         TimeOfDay newStart = lastSlot.end;
//         TimeOfDay newEnd;
        
//         int newHour = newStart.hour + 1;
//         int newMinute = newStart.minute;
        
//         if (newHour >= 24) {
//           newHour = newHour % 24;
//         }
        
//         newEnd = TimeOfDay(hour: newHour, minute: newMinute);
        
//         availability[day]!.add(TimeRange(newStart, newEnd));
//       }
//     });
//   }

//   void _removeTimeSlot(String day, TimeRange range) {
//     setState(() {
//       availability[day]!.remove(range);
//     });
//   }

//   void _copyToOtherDays(String sourceDay) async {
//     final days = availability.keys.toList();
//     final selectedDays = await showDialog<List<String>>(
//       context: context,
//       builder: (context) {
//         final selected = <String>[];
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: const Text("Copy to other days"),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: days.where((d) => d != sourceDay).map((day) {
//                     return CheckboxListTile(
//                       title: Text(day),
//                       value: selected.contains(day),
//                       onChanged: (checked) {
//                         setState(() {
//                           if (checked == true) {
//                             selected.add(day);
//                           } else {
//                             selected.remove(day);
//                           }
//                         });
//                       },
//                     );
//                   }).toList(),
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text("Cancel"),
//                 ),
//                 ElevatedButton(
//                   onPressed: selected.isEmpty
//                       ? null
//                       : () => Navigator.of(context).pop(selected),
//                   child: const Text("Copy"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryColor,
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );

//     if (selectedDays != null && selectedDays.isNotEmpty) {
//       setState(() {
//         for (final day in selectedDays) {
//           availability[day] = availability[sourceDay]!
//               .map((tr) => TimeRange(tr.start, tr.end))
//               .toList();
//         }
//       });
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Copied to selected day(s)"),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 600),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.edit,
//                     color: AppColors.primaryColor,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Add Seasonal Hours',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textColor,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.of(context).pop(),
//                     color: AppColors.textColorSecond,
//                   ),
//                 ],
//               ),
//             ),
            
//             // Form
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Nickname Field
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Nickname',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _nicknameController,
//                           decoration: InputDecoration(
//                             hintText: 'e.g. Summer Hours or Holiday Hours',
//                             border: const OutlineInputBorder(),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 10,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: AppColors.primaryColor,
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Date Range Picker
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Date Range',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         OutlinedButton(
//                           onPressed: () => _pickDateRange(context),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                             side: BorderSide(color: Colors.grey.shade400),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.calendar_today,
//                                 size: 16,
//                                 color: AppColors.textColor,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 _dateRange != null
//                                     ? '${_dateRange!.start.year}-${_dateRange!.start.month}-${_dateRange!.start.day} - '
//                                         '${_dateRange!.end.year}-${_dateRange!.end.month}-${_dateRange!.end.day}'
//                                     : 'Select Date Range',
//                                 style: TextStyle(color: AppColors.textColor),
//                               ),
//                               const SizedBox(width: 8),
//                               Icon(
//                                 Icons.arrow_drop_down,
//                                 size: 16,
//                                 color: AppColors.textColor,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Weekly Hours Section
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Recurring Weekly Hours',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
                        
//                         // Days List
//                         Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Column(
//                             children: [
//                               // Sunday
//                               _buildDayRow('Sunday', 'Sun'),
//                               // Monday
//                               _buildDayRow('Monday', 'Mon'),
//                               // Tuesday
//                               _buildDayRow('Tuesday', 'Tue'),
//                               // Wednesday
//                               _buildDayRow('Wednesday', 'Wed'),
//                               // Thursday
//                               _buildDayRow('Thursday', 'Thu'),
//                               // Friday
//                               _buildDayRow('Friday', 'Fri'),
//                               // Saturday
//                               _buildDayRow('Saturday', 'Sat'),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             // Footer
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   top: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Handle save logic here
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryColor,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   child: const Text(
//                     'Add Seasonal Hours',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDayRow(String day, String shortDay) {
//     final isMobile = MediaQuery.of(context).size.width < 600;
    
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: Colors.grey.shade300,
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Day label - hidden on mobile when in landscape
//           if (!isMobile)
//             Container(
//               width: 80,
//               padding: const EdgeInsets.only(right: 16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   right: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   shortDay,
//                   style: TextStyle(
//                     color: AppColors.textColor,
//                   ),
//                 ),
//               ),
//             ),
          
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Show day name on mobile
//                 if (isMobile)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8.0),
//                     child: Text(
//                       day,
//                       style: TextStyle(
//                         color: AppColors.textColor,
//                       ),
//                     ),
//                   ),
                
//                 // Time slots or "Unavailable"
//                 if (availability[day]!.isEmpty)
//                   Text(
//                     'Unavailable',
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                     ),
//                   )
//                 else
//                   Column(
//                     children: availability[day]!.map((range) {
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 8.0),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: () => _pickTime(context, true, range),
//                                 style: OutlinedButton.styleFrom(
//                                   padding: const EdgeInsets.symmetric(vertical: 8),
//                                   side: BorderSide(color: Colors.grey.shade400),
//                                 ),
//                                 child: Text(
//                                   range.start.format(context),
//                                   style: TextStyle(color: AppColors.textColor),
//                                 ),
//                               ),
//                             ),
//                             const Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 8.0),
//                               child: Text('-'),
//                             ),
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: () => _pickTime(context, false, range),
//                                 style: OutlinedButton.styleFrom(
//                                   padding: const EdgeInsets.symmetric(vertical: 8),
//                                   side: BorderSide(color: Colors.grey.shade400),
//                                 ),
//                                 child: Text(
//                                   range.end.format(context),
//                                   style: TextStyle(color: AppColors.textColor),
//                                 ),
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.close, size: 20),
//                               onPressed: () => _removeTimeSlot(day, range),
//                               color: Colors.grey.shade600,
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   ),
                
//                 // Add Time button
//                 TextButton(
//                   onPressed: () => _addTimeSlot(day),
//                   style: TextButton.styleFrom(
//                     padding: EdgeInsets.zero,
//                     minimumSize: const Size(50, 30),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.add,
//                         size: 20,
//                         color: AppColors.primaryColor,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         'Add Time',
//                         style: TextStyle(
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // Copy button
//           IconButton(
//             icon: Icon(
//               Icons.copy,
//               size: 20,
//               color: Colors.grey.shade600,
//             ),
//             onPressed: () => _copyToOtherDays(day),
//           ),
//         ],
//       ),
//     );
//   }
// }