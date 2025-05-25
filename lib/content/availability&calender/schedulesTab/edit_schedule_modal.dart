// lib\content\availability&calender\schedulesTab\edit_schedule_modal.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/config/config.dart';
import 'package:tabourak/config/globals.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

class EditScheduleModal extends StatefulWidget {
  final String scheduleId;
  final String initialName;
  final String initialTimezone;
  final dynamic isDefault; // Changed to dynamic to handle both bool and int
  final Future<void> Function(String id, Map<String, dynamic> data) onUpdate;
  final Future<void> Function(String id) onDelete;

  const EditScheduleModal({
    Key? key,
    required this.scheduleId,
    required this.initialName,
    required this.initialTimezone,
    required this.isDefault,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<EditScheduleModal> createState() => _EditScheduleModalState();
}

class _EditScheduleModalState extends State<EditScheduleModal> {
  late TextEditingController _nameController;
  late bool _isDefault;
  late String _selectedTimezone;
  bool _showNicknameError = false;
  List<Map<String, dynamic>> _timezones = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _nameController = TextEditingController(text: widget.initialName);
    
    // Handle both bool and int types for isDefault
    _isDefault = widget.isDefault is bool 
        ? widget.isDefault 
        : (widget.isDefault == 1 || widget.isDefault == true);
        
    _selectedTimezone = widget.initialTimezone;
    _fetchTimezones();
  }

  Future<void> _fetchTimezones() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/schedules/timezones'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _timezones = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        debugPrint('Failed to load timezones. Status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        _fallbackToDefaultTimezones();
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching timezones: $e');
      debugPrint('Stack trace: $stackTrace');
      _fallbackToDefaultTimezones();
    }
  }

  void _fallbackToDefaultTimezones() {
    setState(() {
      _timezones = [
        {'id': 'Asia/Hebron', 'name': 'Asia / Hebron'},
        {'id': 'America/New_York', 'name': 'America / New York'},
        {'id': 'Europe/London', 'name': 'Europe / London'},
        {'id': 'Asia/Tokyo', 'name': 'Asia / Tokyo'},
        {'id': 'Australia/Sydney', 'name': 'Australia / Sydney'},
      ].map((tz) => {...tz, 'currentTime': '--:-- --'}).toList();
    });
  }

  String _getCurrentTime(String timezone) {
    try {
      final location = tz.getLocation(timezone);
      final now = tz.TZDateTime.now(location);
      return DateFormat.jm().format(now);
    } catch (e) {
      debugPrint('Error getting current time for $timezone: $e');
      return '--:-- --';
    }
  }

  Future<void> _handleSave() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _showNicknameError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onUpdate(widget.scheduleId, {
        'name': _nameController.text,
        'timezone': _selectedTimezone,
        'isDefault': _isDefault,
      });

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      debugPrint('Error updating schedule: $e');
      debugPrint('Stack trace: $stackTrace');
      if (!mounted) return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to update schedule. Please try again.')),
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update schedule. Please try again.'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(10),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await widget.onDelete(widget.scheduleId);
        if (!mounted) return;
        Navigator.of(context).pop('delete');
      } catch (e, stackTrace) {
        debugPrint('Error deleting schedule: $e');
        debugPrint('Stack trace: $stackTrace');
        if (!mounted) return;
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to delete schedule. Please try again.')),
        // );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete schedule. Please try again.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(10),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit Schedule',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nickname field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nickname',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _showNicknameError ? Colors.red : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'e.g. My Weekly Availability',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: _showNicknameError 
                                  ? Colors.red 
                                  : Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: _showNicknameError
                                  ? Colors.red
                                  : AppColors.primaryColor,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && _showNicknameError) {
                              setState(() {
                                _showNicknameError = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Timezone field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Timezone',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _isLoading ? null : () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Select Timezone',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _timezones.length,
                                          itemBuilder: (context, index) {
                                            final tz = _timezones[index];
                                            return ListTile(
                                              leading: Icon(
                                                Icons.language,
                                                color: AppColors.primaryColor,
                                              ),
                                              title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(tz['name']),
                                                  Text(
                                                    tz['currentTime'] ?? _getCurrentTime(tz['id']),
                                                    style: TextStyle(
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  _selectedTimezone = tz['id'];
                                                });
                                                Navigator.pop(context);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.language,
                                  color: AppColors.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_timezones.firstWhere(
                                        (tz) => tz['id'] == _selectedTimezone,
                                        orElse: () => {'name': 'Asia / Hebron'},
                                      )['name']),
                                      Text(
                                        _getCurrentTime(_selectedTimezone),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Default toggle
                    // Row(
                    //   children: [
                    //     SizedBox(
                    //       width: 36,
                    //       height: 20,
                    //       child: Switch(
                    //         value: _isDefault,
                    //         onChanged: (_isLoading || (widget.isDefault is bool ? widget.isDefault : widget.isDefault == 1 || widget.isDefault == true))
                    //             ? null 
                    //             : (value) {
                    //                 setState(() {
                    //                   _isDefault = value;
                    //                 });
                    //               },
                    //         activeColor: AppColors.primaryColor,
                    //         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    //       ),
                    //     ),
                    //     const SizedBox(width: 12),
                    //     const Text('Use this schedule for new meeting types'),
                    //   ],
                    // ),
// Default toggle
Row(
  children: [
    SizedBox(
      width: 36,
      height: 20,
      child: Theme(
        data: Theme.of(context).copyWith(
          disabledColor: AppColors.primaryColor.withOpacity(0.5),
        ),
        child: AbsorbPointer(
          absorbing: _isLoading || (widget.isDefault is bool ? widget.isDefault : widget.isDefault == 1 || widget.isDefault == true),
          child: Switch(
            value: _isDefault,
            onChanged: (value) {
              setState(() {
                _isDefault = value;
              });
            },
            activeColor: AppColors.primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    ),
    const SizedBox(width: 12),
    const Text('Use this schedule for new meeting types'),
  ],
),
                  ],
                ),
              ),
            ),

            // Footer with buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : _handleDelete,
                    child: const Text(
                      'Delete Schedule',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}









// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/config/config.dart';
// import 'package:tabourak/config/globals.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:intl/intl.dart';

// class EditScheduleModal extends StatefulWidget {
//   final String scheduleId;
//   final String initialName;
//   final String initialTimezone;
//   final dynamic isDefault; // Changed to dynamic to handle both bool and int
//   final Future<void> Function(String id, Map<String, dynamic> data) onUpdate;
//   final Future<void> Function(String id) onDelete;

//   const EditScheduleModal({
//     Key? key,
//     required this.scheduleId,
//     required this.initialName,
//     required this.initialTimezone,
//     required this.isDefault,
//     required this.onUpdate,
//     required this.onDelete,
//   }) : super(key: key);

//   @override
//   State<EditScheduleModal> createState() => _EditScheduleModalState();
// }

// class _EditScheduleModalState extends State<EditScheduleModal> {
//   late TextEditingController _nameController;
//   late bool _isDefault;
//   late String _selectedTimezone;
//   bool _showNicknameError = false;
//   List<Map<String, dynamic>> _timezones = [];
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     tz.initializeTimeZones();
//     _nameController = TextEditingController(text: widget.initialName);
    
//     // Handle both bool and int types for isDefault
//     _isDefault = widget.isDefault is bool 
//         ? widget.isDefault 
//         : (widget.isDefault == 1 || widget.isDefault == true);
        
//     _selectedTimezone = widget.initialTimezone;
//     _fetchTimezones();
//   }

//   Future<void> _fetchTimezones() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/schedules/timezones'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _timezones = List<Map<String, dynamic>>.from(json.decode(response.body));
//         });
//       } else {
//         debugPrint('Failed to load timezones. Status: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         _fallbackToDefaultTimezones();
//       }
//     } catch (e, stackTrace) {
//       debugPrint('Error fetching timezones: $e');
//       debugPrint('Stack trace: $stackTrace');
//       _fallbackToDefaultTimezones();
//     }
//   }

//   void _fallbackToDefaultTimezones() {
//     setState(() {
//       _timezones = [
//         {'id': 'Asia/Hebron', 'name': 'Asia / Hebron'},
//         {'id': 'America/New_York', 'name': 'America / New York'},
//         {'id': 'Europe/London', 'name': 'Europe / London'},
//         {'id': 'Asia/Tokyo', 'name': 'Asia / Tokyo'},
//         {'id': 'Australia/Sydney', 'name': 'Australia / Sydney'},
//       ].map((tz) => {...tz, 'currentTime': '--:-- --'}).toList();
//     });
//   }

//   String _getCurrentTime(String timezone) {
//     try {
//       final location = tz.getLocation(timezone);
//       final now = tz.TZDateTime.now(location);
//       return DateFormat.jm().format(now);
//     } catch (e) {
//       debugPrint('Error getting current time for $timezone: $e');
//       return '--:-- --';
//     }
//   }

//   Future<void> _handleSave() async {
//     if (_nameController.text.isEmpty) {
//       setState(() {
//         _showNicknameError = true;
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await widget.onUpdate(widget.scheduleId, {
//         'name': _nameController.text,
//         'timezone': _selectedTimezone,
//         'isDefault': _isDefault,
//       });

//       if (!mounted) return;
//       Navigator.of(context).pop();
//     } catch (e, stackTrace) {
//       debugPrint('Error updating schedule: $e');
//       debugPrint('Stack trace: $stackTrace');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update schedule. Please try again.')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _handleDelete() async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Schedule'),
//         content: const Text('Are you sure you want to delete this schedule?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         await widget.onDelete(widget.scheduleId);
//         if (!mounted) return;
//         Navigator.of(context).pop('delete');
//       } catch (e, stackTrace) {
//         debugPrint('Error deleting schedule: $e');
//         debugPrint('Stack trace: $stackTrace');
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete schedule. Please try again.')),
//         );
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding: const EdgeInsets.all(16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 500),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     color: Colors.grey.shade300,
//                     width: 1,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.edit_outlined,
//                     color: AppColors.primaryColor,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Edit Schedule',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
//                   ),
//                 ],
//               ),
//             ),

//             // Form content
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Nickname field
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Nickname',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: _showNicknameError ? Colors.red : null,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _nameController,
//                           decoration: InputDecoration(
//                             hintText: 'e.g. My Weekly Availability',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(4),
//                               borderSide: BorderSide(
//                                 color: _showNicknameError 
//                                   ? Colors.red 
//                                   : Colors.grey.shade300,
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(4),
//                               borderSide: BorderSide(
//                                 color: _showNicknameError
//                                   ? Colors.red
//                                   : AppColors.primaryColor,
//                               ),
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                           ),
//                           onChanged: (value) {
//                             if (value.isNotEmpty && _showNicknameError) {
//                               setState(() {
//                                 _showNicknameError = false;
//                               });
//                             }
//                           },
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 24),

//                     // Timezone field
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Timezone',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         GestureDetector(
//                           onTap: _isLoading ? null : () {
//                             showModalBottomSheet(
//                               context: context,
//                               builder: (context) {
//                                 return Container(
//                                   padding: const EdgeInsets.all(16),
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       const Text(
//                                         'Select Timezone',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 16),
//                                       Expanded(
//                                         child: ListView.builder(
//                                           shrinkWrap: true,
//                                           itemCount: _timezones.length,
//                                           itemBuilder: (context, index) {
//                                             final tz = _timezones[index];
//                                             return ListTile(
//                                               leading: Icon(
//                                                 Icons.language,
//                                                 color: AppColors.primaryColor,
//                                               ),
//                                               title: Row(
//                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                 children: [
//                                                   Text(tz['name']),
//                                                   Text(
//                                                     tz['currentTime'] ?? _getCurrentTime(tz['id']),
//                                                     style: TextStyle(
//                                                       color: Colors.grey.shade600,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               onTap: () {
//                                                 setState(() {
//                                                   _selectedTimezone = tz['id'];
//                                                 });
//                                                 Navigator.pop(context);
//                                               },
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: Colors.grey.shade300,
//                               ),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.language,
//                                   color: AppColors.primaryColor,
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(_timezones.firstWhere(
//                                         (tz) => tz['id'] == _selectedTimezone,
//                                         orElse: () => {'name': 'Asia / Hebron'},
//                                       )['name']),
//                                       Text(
//                                         _getCurrentTime(_selectedTimezone),
//                                         style: TextStyle(
//                                           color: Colors.grey.shade600,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.arrow_drop_down,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 24),

//                     // Default toggle
//                     Row(
//                       children: [
//                         SizedBox(
//                           width: 36,
//                           height: 20,
//                           child: Switch(
//                             value: _isDefault,
//                             onChanged: _isLoading ? null : (value) {
//                               setState(() {
//                                 _isDefault = value;
//                               });
//                             },
//                             activeColor: AppColors.primaryColor,
//                             materialTapTargetSize:
//                                 MaterialTapTargetSize.shrinkWrap,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         const Text('Use this schedule for new meeting types'),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Footer with buttons
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   top: BorderSide(
//                     color: Colors.grey.shade300,
//                     width: 1,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   TextButton(
//                     onPressed: _isLoading ? null : _handleDelete,
//                     child: const Text(
//                       'Delete Schedule',
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                   const Spacer(),
//                   ElevatedButton(
//                     onPressed: _isLoading ? null : _handleSave,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.secondaryColor,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : const Text(
//                             'Save Changes',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }













// lib\content\availability&calender\schedulesTab\edit_schedule_modal.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:intl/intl.dart';

// class EditScheduleModal extends StatefulWidget {
//   final String initialName;
//   final String initialTimezone;
//   final bool isDefault;

//   const EditScheduleModal({
//     Key? key,
//     required this.initialName,
//     required this.initialTimezone,
//     required this.isDefault,
//   }) : super(key: key);

//   @override
//   State<EditScheduleModal> createState() => _EditScheduleModalState();
// }

// class _EditScheduleModalState extends State<EditScheduleModal> {
//   late TextEditingController _nameController;
//   late bool _isDefault;
//   late String _selectedTimezone;
//   bool _showNicknameError = false;
  
//   final Map<String, String> _timezoneDisplayNames = {
//     'Asia/Hebron': 'Asia / Hebron',
//     'America/New_York': 'America / New York',
//     'Europe/London': 'Europe / London',
//     'Asia/Tokyo': 'Asia / Tokyo',
//     'Australia/Sydney': 'Australia / Sydney',
//     'Africa/Cairo': 'Africa / Cairo',
//     'Asia/Dubai': 'Asia / Dubai',
//     'Europe/Paris': 'Europe / Paris',
//     'America/Los_Angeles': 'America / Los Angeles',
//     'America/Chicago': 'America / Chicago',
//   };

//   @override
//   void initState() {
//     super.initState();
//     tz.initializeTimeZones();
//     _nameController = TextEditingController(text: widget.initialName);
//     _isDefault = widget.isDefault;
//     _selectedTimezone = widget.initialTimezone;
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }

//   String _getCurrentTime(String timezone) {
//     try {
//       final location = tz.getLocation(timezone);
//       final now = tz.TZDateTime.now(location);
//       return DateFormat.jm().format(now);
//     } catch (e) {
//       return '--:-- --';
//     }
//   }

//   void _handleSave() {
//     if (_nameController.text.isEmpty) {
//       setState(() {
//         _showNicknameError = true;
//       });
//       return;
//     }
//     Navigator.of(context).pop({
//       'name': _nameController.text,
//       'timezone': _selectedTimezone,
//       'isDefault': _isDefault,
//     });
//   }

//   void _handleDelete() {
//     Navigator.of(context).pop('delete');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding: const EdgeInsets.all(16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 500),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     color: Colors.grey.shade300,
//                     width: 1,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.edit_outlined,
//                     color: AppColors.primaryColor,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Edit Schedule',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ],
//               ),
//             ),

//             // Form content
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Nickname field
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Nickname',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: _showNicknameError ? Colors.red : null,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _nameController,
//                           decoration: InputDecoration(
//                             hintText: 'e.g. My Weekly Availability',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(4),
//                               borderSide: BorderSide(
//                                 color: _showNicknameError 
//                                   ? Colors.red 
//                                   : Colors.grey.shade300,
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(4),
//                               borderSide: BorderSide(
//                                 color: _showNicknameError
//                                   ? Colors.red
//                                   : AppColors.primaryColor,
//                               ),
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                           ),
//                           onChanged: (value) {
//                             if (value.isNotEmpty && _showNicknameError) {
//                               setState(() {
//                                 _showNicknameError = false;
//                               });
//                             }
//                           },
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 24),

//                     // Timezone field
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Timezone',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         GestureDetector(
//                           onTap: () {
//                             showModalBottomSheet(
//                               context: context,
//                               builder: (context) {
//                                 return Container(
//                                   padding: const EdgeInsets.all(16),
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       const Text(
//                                         'Select Timezone',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 16),
//                                       Expanded(
//                                         child: ListView.builder(
//                                           shrinkWrap: true,
//                                           itemCount: _timezoneDisplayNames.length,
//                                           itemBuilder: (context, index) {
//                                             final tzName = _timezoneDisplayNames.keys.elementAt(index);
//                                             return ListTile(
//                                               leading: Icon(
//                                                 Icons.language,
//                                                 color: AppColors.primaryColor,
//                                               ),
//                                               title: Row(
//                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                 children: [
//                                                   Text(_timezoneDisplayNames[tzName]!),
//                                                   Text(
//                                                     _getCurrentTime(tzName),
//                                                     style: TextStyle(
//                                                       color: Colors.grey.shade600,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               onTap: () {
//                                                 setState(() {
//                                                   _selectedTimezone = tzName;
//                                                 });
//                                                 Navigator.pop(context);
//                                               },
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: Colors.grey.shade300,
//                               ),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.language,
//                                   color: AppColors.primaryColor,
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(_timezoneDisplayNames[_selectedTimezone] ?? 'Asia / Hebron'),
//                                       Text(
//                                         _getCurrentTime(_selectedTimezone),
//                                         style: TextStyle(
//                                           color: Colors.grey.shade600,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.arrow_drop_down,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 24),

//                     // Default toggle
//                     Row(
//                       children: [
//                         SizedBox(
//                           width: 36,
//                           height: 20,
//                           child: Switch(
//                             value: _isDefault,
//                             onChanged: (value) {
//                               setState(() {
//                                 _isDefault = value;
//                               });
//                             },
//                             activeColor: AppColors.primaryColor,
//                             materialTapTargetSize:
//                                 MaterialTapTargetSize.shrinkWrap,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         const Text('Use this schedule for new meeting types'),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Footer with buttons
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   top: BorderSide(
//                     color: Colors.grey.shade300,
//                     width: 1,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   TextButton(
//                     onPressed: _handleDelete,
//                     child: const Text(
//                       'Delete Schedule',
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                   const Spacer(),
//                   ElevatedButton(
//                     onPressed: _handleSave,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.secondaryColor,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     child: const Text(
//                       'Save Changes',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }