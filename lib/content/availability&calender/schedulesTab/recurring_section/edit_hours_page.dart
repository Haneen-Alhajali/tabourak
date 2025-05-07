// lib/content/availability/edit_hours_page.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'availability_editor.dart';
import 'package:tabourak/models/time_range.dart';

class EditHoursPage extends StatefulWidget {
  final Map<String, List<TimeRange>> initialAvailability;

  const EditHoursPage({Key? key, required this.initialAvailability}) : super(key: key);

  @override
  _EditHoursPageState createState() => _EditHoursPageState();
}

class _EditHoursPageState extends State<EditHoursPage> {
  late Map<String, List<TimeRange>> availability;

  @override
  void initState() {
    super.initState();
    availability = Map.from(widget.initialAvailability);
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
                onPressed: () {
                  Navigator.pop(context, availability);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
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