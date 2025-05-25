// lib\widgets\user_profile.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/config/config.dart';
import 'package:tabourak/config/globals.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/user-profile/user-profile'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userProfile = json.decode(response.body);
          isLoading = false;
        });
      } else {
        // Log error but don't show to user
        print('Failed to load profile: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Log error but don't show to user
      print('Connection error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      );
    }

    // Default user data
    final name = userProfile?['name'] ?? 'Haneen Alhajali';
    final email = userProfile?['email'] ?? 'haneen@example.com';
    final initials = userProfile?['initials'] ?? 'HA';
    final color = userProfile?['color'] ?? '#6200EE';

    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // User Image or Initials Avatar
          userProfile?['profileImage'] != null
              ? CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(userProfile!['profileImage']),
                )
              : Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _colorFromString(color),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
          SizedBox(width: 8),
          // User Name and Email
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: AppColors.backgroundColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                email,
                style: TextStyle(
                  color: AppColors.backgroundColor.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorFromString(String colorString) {
    try {
      if (colorString.startsWith('hsl')) {
        // Parse HSL color
        final values = colorString.substring(4, colorString.length - 1)
          .split(',')
          .map((s) => s.trim())
          .toList();
        
        final h = double.parse(values[0]);
        final s = double.parse(values[1].replaceAll('%', ''));
        final l = double.parse(values[2].replaceAll('%', ''));
        
        return HSLColor.fromAHSL(1.0, h, s/100, l/100).toColor();
      }
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primaryColor; // fallback color
    }
  }
}






// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/config/config.dart';
// import 'package:tabourak/config/globals.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class UserProfile extends StatefulWidget {
//   @override
//   _UserProfileState createState() => _UserProfileState();
// }

// class _UserProfileState extends State<UserProfile> {
//   Map<String, dynamic>? userProfile;
//   bool isLoading = true;
//   String? error;

//   @override
//   void initState() {
//     super.initState();
//     fetchUserProfile();
//   }

//   Future<void> fetchUserProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/profile/profile'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           userProfile = json.decode(response.body);
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           error = 'Failed to load profile';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         error = 'Connection error';
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Container(
//         padding: EdgeInsets.all(16),
//         child: CircularProgressIndicator(),
//       );
//     }

//     if (error != null) {
//       return Container(
//         padding: EdgeInsets.all(16),
//         child: Text(error!, style: TextStyle(color: Colors.red)),
//       );
//     }

//     return Container(
//       padding: EdgeInsets.all(16),
//       child: Row(
//         children: [
//           // User Image or Initials Avatar
//           userProfile?['profileImage'] != null
//               ? CircleAvatar(
//                   radius: 20,
//                   backgroundImage: NetworkImage(userProfile!['profileImage']),
//                 )
//               : Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: _colorFromString(userProfile?['color'] ?? '#6200EE'),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Center(
//                     child: Text(
//                       userProfile?['initials'] ?? '??',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//           SizedBox(width: 8),
//           // User Name and Email
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 userProfile?['name'] ?? 'Unknown User',
//                 style: TextStyle(
//                   color: AppColors.backgroundColor,
//                   fontSize: 15,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 userProfile?['email'] ?? 'no-email@example.com',
//                 style: TextStyle(
//                   color: AppColors.backgroundColor.withOpacity(0.8),
//                   fontSize: 13,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Color _colorFromString(String colorString) {
//     try {
//       if (colorString.startsWith('hsl')) {
//         // Parse HSL color
//         final values = colorString.substring(4, colorString.length - 1)
//           .split(',')
//           .map((s) => s.trim())
//           .toList();
        
//         final h = double.parse(values[0]);
//         final s = double.parse(values[1].replaceAll('%', ''));
//         final l = double.parse(values[2].replaceAll('%', ''));
        
//         return HSLColor.fromAHSL(1.0, h, s/100, l/100).toColor();
//       }
//       return Color(int.parse(colorString.replaceAll('#', '0xFF')));
//     } catch (e) {
//       return AppColors.primaryColor; // fallback color
//     }
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';

// class UserProfile extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       child: Row(
//         children: [
//           // User Image
//           CircleAvatar(
//             radius: 20,
//             backgroundImage: NetworkImage(
//                 'https://via.placeholder.com/150'), // Dummy image
//           ),
//           SizedBox(width: 8),
//           // User Name and Email
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Haneen Alhajali', // User name
//                 style: TextStyle(
//                   color: AppColors.backgroundColor,
//                   fontSize: 15,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 'haneen@example.com', // Dummy email
//                 style: TextStyle(
//                   color:  AppColors.backgroundColor.withOpacity(0.8),
//                   fontSize: 13,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }