// lib/content/availability&calender/schedulesTab/recurring_section/edit_hours_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/config/config.dart';
import 'package:tabourak/config/globals.dart';
import 'package:tabourak/models/time_range.dart';
import 'availability_editor.dart';
import 'package:tabourak/config/snackbar_helper.dart';

class EditHoursPage extends StatefulWidget {
  final Map<String, List<TimeRange>> initialAvailability;
  final String scheduleId;

  const EditHoursPage({
    Key? key,
    required this.initialAvailability,
    required this.scheduleId,
  }) : super(key: key);

  @override
  _EditHoursPageState createState() => _EditHoursPageState();
}

class _EditHoursPageState extends State<EditHoursPage> {
  late Map<String, List<TimeRange>> availability;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    availability = Map.from(widget.initialAvailability);
  }

  Future<void> _saveAvailability() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/availability'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'scheduleId': widget.scheduleId,
          'availability': _convertToApiFormat(availability),
        }),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(availability);
      } else {
        final error = json.decode(response.body)['error'] ?? 'Failed to save availability';
        throw Exception(error);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to save availability: ${e.toString()}')),
      // );
      SnackbarHelper.showError(context, 'Failed to save availability: ${e.toString()}');
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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(72),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 16),
            child: Row(
              children: [
                Icon(
                  Icons.edit,
                  size: 24,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Edit Recurring Weekly Hours',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: AvailabilityEditor(
                initialAvailability: availability,
                onSave: (updatedAvailability) {
                  setState(() {
                    availability = updatedAvailability;
                  });
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAvailability,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}






// edit




// // lib\content\availability&calender\schedulesTab\recurring_section\edit_hours_page.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'availability_editor.dart';
// import 'package:tabourak/models/time_range.dart';

// class EditHoursPage extends StatefulWidget {
//   final Map<String, List<TimeRange>> initialAvailability;

//   const EditHoursPage({Key? key, required this.initialAvailability}) : super(key: key);

//   @override
//   _EditHoursPageState createState() => _EditHoursPageState();
// }

// class _EditHoursPageState extends State<EditHoursPage> {
//   late Map<String, List<TimeRange>> availability;

//   @override
//   void initState() {
//     super.initState();
//     availability = Map.from(widget.initialAvailability);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(72),
//         child: Container(
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: Colors.grey.shade300,
//                 width: 1,
//               ),
//             ),
//           ),
//           child: Padding(
//           padding: const EdgeInsets.fromLTRB(24, 50, 24, 16),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.edit,
//                   size: 24,
//                   color: AppColors.primaryColor,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Edit Recurring Weekly Hours',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textColor,
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   icon: Icon(Icons.close),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(24),
//               child: AvailabilityEditor(
//                 initialAvailability: availability,
//                 onSave: (updatedAvailability) {
//                   setState(() {
//                     availability = updatedAvailability;
//                   });
//                 },
//               ),
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             decoration: BoxDecoration(
//               border: Border(
//                 top: BorderSide(
//                   color: Colors.grey.shade300,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context, availability);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryColor,
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//                 child: Text(
//                   'Save Changes',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }









// lib\content\availability&calender\schedulesTab\recurring_section\edit_hours_page.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'availability_editor.dart';
// import 'package:tabourak/models/time_range.dart';

// class EditHoursPage extends StatefulWidget {
//   final Map<String, List<TimeRange>> initialAvailability;

//   const EditHoursPage({Key? key, required this.initialAvailability}) : super(key: key);

//   @override
//   _EditHoursPageState createState() => _EditHoursPageState();
// }

// class _EditHoursPageState extends State<EditHoursPage> {
//   late Map<String, List<TimeRange>> availability;

//   @override
//   void initState() {
//     super.initState();
//     availability = Map.from(widget.initialAvailability);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(72),
//         child: Container(
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: Colors.grey.shade300,
//                 width: 1,
//               ),
//             ),
//           ),
//           child: Padding(
//           padding: const EdgeInsets.fromLTRB(24, 50, 24, 16),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.edit,
//                   size: 24,
//                   color: AppColors.primaryColor,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Edit Recurring Weekly Hours',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textColor,
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   icon: Icon(Icons.close),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(24),
//               child: AvailabilityEditor(
//                 initialAvailability: availability,
//                 onSave: (updatedAvailability) {
//                   setState(() {
//                     availability = updatedAvailability;
//                   });
//                 },
//               ),
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             decoration: BoxDecoration(
//               border: Border(
//                 top: BorderSide(
//                   color: Colors.grey.shade300,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context, availability);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryColor,
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//                 child: Text(
//                   'Save Changes',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }








// // lib/content/availability/edit_hours_page.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'widgets/availability_editor.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:tabourak/config/config.dart';

// class EditHoursPage extends StatefulWidget {
//   final Map<String, List<TimeRange>> initialAvailability;
//   final String authToken;

//   const EditHoursPage({
//     Key? key, 
//     required this.initialAvailability,
//     required this.authToken,
//   }) : super(key: key);

//   @override
//   _EditHoursPageState createState() => _EditHoursPageState();
// }

// class _EditHoursPageState extends State<EditHoursPage> {
//   late Map<String, List<TimeRange>> availability;
//   bool _isSaving = false;

//   @override
//   void initState() {
//     super.initState();
//     availability = Map.from(widget.initialAvailability);
//   }

//   Future<void> _saveChanges() async {
//     setState(() => _isSaving = true);
    
//     try {
//       // Convert our availability to API format
//       final apiAvailability = {};
//       availability.forEach((day, ranges) {
//         apiAvailability[day] = ranges.map((range) {
//           return {
//             'start': {
//               'hour': range.start.hour,
//               'minute': range.start.minute,
//             },
//             'end': {
//               'hour': range.end.hour,
//               'minute': range.end.minute,
//             },
//           };
//         }).toList();
//       });

//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/availability'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${widget.authToken}',
//         },
//         body: json.encode({
//           'availability': apiAvailability,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Availability ${responseData['action']} successfully')),
//         );
//         Navigator.pop(context, availability);
//       } else {
//         final error = json.decode(response.body)['error'] ?? 'Failed to save availability';
//         throw Exception(error);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     } finally {
//       setState(() => _isSaving = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(72),
//         child: Container(
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: Colors.grey.shade300,
//                 width: 1,
//               ),
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(24, 50, 24, 16),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.edit,
//                   size: 24,
//                   color: AppColors.primaryColor,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Edit Recurring Weekly Hours',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textColor,
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   icon: Icon(Icons.close),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(24),
//               child: AvailabilityEditor(
//                 initialAvailability: availability,
//                 authToken: widget.authToken,
//                 onSave: (updatedAvailability) {
//                   setState(() {
//                     availability = updatedAvailability;
//                   });
//                 },
//               ),
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             decoration: BoxDecoration(
//               border: Border(
//                 top: BorderSide(
//                   color: Colors.grey.shade300,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isSaving ? null : _saveChanges,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryColor,
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//                 child: _isSaving
//                     ? CircularProgressIndicator(color: Colors.white)
//                     : Text(
//                         'Save Changes',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }