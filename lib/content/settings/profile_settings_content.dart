// lib\content\settings\profile_settings_content.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tabourak/colors/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tabourak/config/config.dart';
import 'package:tabourak/config/globals.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:tabourak/config/snackbar_helper.dart';


class ProfileContent extends StatefulWidget {
  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  String _selectedLanguage = "English";
  String _selectedTimezone = 'Asia/Hebron';
  String? _profileImageUrl;
  File? _selectedImageFile;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploading = false;
  List<Map<String, dynamic>> _timezones = [];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _fetchProfileData();
    _fetchTimezones();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/profile'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _selectedLanguage = data['language'] ?? 'English';
          _selectedTimezone = data['timezone'] ?? 'Asia/Hebron';
          _profileImageUrl = data['profileImageUrl'];
          _isLoading = false;
        });
      } else {
        print('Failed to load profile: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchTimezones() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/profile/timezones'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> timezoneCodes = json.decode(response.body);
        setState(() {
          _timezones = timezoneCodes.map((tzCode) {
            return {
              'id': tzCode.toString(),
              'name': tzCode.toString().replaceAll('_', ' / '),
              'currentTime': _getCurrentTime(tzCode.toString()),
            };
          }).toList();
        });
      } else {
        setState(() {
          _timezones = [
            {'id': 'Asia/Hebron', 'name': 'Asia / Hebron'},
            {'id': 'America/New_York', 'name': 'America / New York'},
            {'id': 'Europe/London', 'name': 'Europe / London'},
            {'id': 'Asia/Tokyo', 'name': 'Asia / Tokyo'},
            {'id': 'Australia/Sydney', 'name': 'Australia / Sydney'},
          ].map((tz) => {...tz, 'currentTime': _getCurrentTime(tz['id']!)}).toList();
        });
      }
    } catch (e) {
      print('Error fetching timezones: $e');
      setState(() {
        _timezones = [
          {'id': 'Asia/Hebron', 'name': 'Asia / Hebron'},
          {'id': 'America/New_York', 'name': 'America / New York'},
          {'id': 'Europe/London', 'name': 'Europe / London'},
          {'id': 'Asia/Tokyo', 'name': 'Asia / Tokyo'},
          {'id': 'Australia/Sydney', 'name': 'Australia / Sydney'},
        ].map((tz) => {...tz, 'currentTime': _getCurrentTime(tz['id']!)}).toList();
      });
    }
  }

  String _getCurrentTime(String timezone) {
    try {
      final location = tz.getLocation(timezone);
      final now = tz.TZDateTime.now(location);
      return DateFormat.jm().format(now);
    } catch (e) {
      return '--:-- --';
    }
  }

  Future<void> _pickImage() async {
    if (_isUploading) return;
    
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final bytes = await imageFile.readAsBytes();
        if (bytes.isEmpty) throw 'Image file is empty';

        setState(() {
          _selectedImageFile = imageFile;
        });
      }
    } catch (e) {
      debugPrint('Image picking error: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Failed to load image: ${e.toString()}'),
      //     duration: Duration(seconds: 3),
      //   ),
      // );
      SnackbarHelper.showError(context, 'Failed to load image: ${e.toString()}');

    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      String? imageUrl;
      if (_selectedImageFile != null) {
        setState(() => _isUploading = true);
        imageUrl = await _uploadImage(_selectedImageFile!);
        setState(() => _isUploading = false);
      }

      // Update profile information
      final updateResponse = await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/profile'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'language': _selectedLanguage,
          'timezone': _selectedTimezone,
        }),
      );

      if (updateResponse.statusCode == 200) {
        setState(() {
          _profileImageUrl = imageUrl ?? _profileImageUrl;
          _selectedImageFile = null;
        });
        
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Profile updated successfully')),
        // );
        SnackbarHelper.showSuccess(context, 'Profile updated successfully');

      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to update profile')),
        // );
        SnackbarHelper.showError(context, 'Failed to update profile');

      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Error updating profile: ${e.toString()}'),
      //     duration: Duration(seconds: 4),
      //   ),
      // );
        SnackbarHelper.showError(context, 'Error updating profile: ${e.toString()}');

    } finally {
      setState(() {
        _isSaving = false;
        _isUploading = false;
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      if (!await imageFile.exists()) throw 'Image file not found';
      if (await imageFile.length() <= 0) throw 'Image file is empty';

      final extension = path.extension(imageFile.path).toLowerCase().replaceFirst('.', '');
      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        throw 'Only JPG/PNG images are allowed';
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/api/profile/image'),
      );
      request.headers['Authorization'] = 'Bearer $globalAuthToken';

      var multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', extension),
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return jsonResponse['imageUrl'];
      } else {
        throw jsonResponse['error'] ?? 'Upload failed with status ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Image upload error: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Image upload failed: ${e.toString()}'),
      //     duration: Duration(seconds: 4),
      //   ),
      // );
        SnackbarHelper.showError(context, 'Image upload failed: ${e.toString()}');

      return null;
    }
  }

  Future<void> _removeImage() async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/profile/image'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _profileImageUrl = null;
          _selectedImageFile = null;
        });
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Profile image removed')),
        // );
        SnackbarHelper.showSuccess(context, 'Profile image removed');

      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to remove profile image')),
        // );
        SnackbarHelper.showError(context, 'Failed to remove profile image');

      }
    } catch (e) {
      print('Error removing image: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error removing image')),
      // );
      SnackbarHelper.showError(context, 'Error removing image');

    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "User Profile",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Your profile information is shared across all organizations you are a member of.",
              style: TextStyle(
                color: AppColors.textColorSecond,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Divider(
          color: AppColors.mediumColor,
          thickness: 1,
          height: 24,
        ),

        // Form Section
        Column(
          children: [
            // Name and Timezone Row
            Column(
              children: [
                // First Name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "First Name",
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.mediumColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        hintText: "Enter First Name",
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                      ),
                      controller: _firstNameController,
                      style: TextStyle(color: AppColors.textColor),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Last Name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Last Name",
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.mediumColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        hintText: "Enter Last Name",
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                      ),
                      controller: _lastNameController,
                      style: TextStyle(color: AppColors.textColor),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Timezone
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Timezone",
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _showTimezonePicker(context),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.mediumColor),
                          borderRadius: BorderRadius.circular(4),
                          color: AppColors.backgroundColor,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        height: 48,
                        child: Row(
                          children: [
                            Icon(Icons.public, color: AppColors.primaryColor),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedTimezone.replaceAll('_', ' / '),
                                style: TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              _getCurrentTime(_selectedTimezone),
                              style: TextStyle(
                                color: AppColors.textColorSecond,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Language
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Language",
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.help_outline,
                            size: 18, color: AppColors.textColorSecond),
                      ],
                    ),
                    SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      items: ["English", "Arabic"]
                          .map(
                            (lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(
                                lang,
                                style: TextStyle(
                                    color: AppColors.textColor, fontSize: 16),
                              )),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedLanguage = value);
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.mediumColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                      ),
                      icon: Icon(Icons.keyboard_arrow_down,
                          color: AppColors.textColorSecond),
                      style: TextStyle(color: AppColors.textColor),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Picture
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Picture",
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.textColorSecond),
                                ),
                                child: _selectedImageFile != null
                                    ? ClipOval(
                                        child: Image.file(
                                          _selectedImageFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : _profileImageUrl != null
                                        ? ClipOval(
                                            child: Image.network(
                                              _profileImageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: AppColors.textColorSecond,
                                                );
                                              },
                                            ),
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 40,
                                            color: AppColors.textColorSecond,
                                          ),
                              ),
                              if (_isUploading && _selectedImageFile != null)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              if ((_selectedImageFile != null || _profileImageUrl != null) && !_isUploading)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _removeImage,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundColor,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.close,
                                        size: 20,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                onPressed: _isUploading ? null : _pickImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: AppColors.primaryColor,
                                  elevation: 0,
                                  side: BorderSide(color: AppColors.primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  minimumSize: Size(double.infinity, 40),
                                ),
                                child: _isUploading && _selectedImageFile != null
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                                          ),
                                          SizedBox(width: 8),
                                          Text("Uploading..."),
                                        ],
                                      )
                                    : Text("Change Picture"),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "JPG or PNG. For best presentation, should be square.",
                                style: TextStyle(
                                  color: AppColors.textColorSecond,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 24),

        // Save Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving || _isUploading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
            ),
            child: _isSaving
                ? CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.backgroundColor,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _showTimezonePicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
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
                            tz['currentTime'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context, tz['id']);
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

    if (selected != null) {
      setState(() => _selectedTimezone = selected);
    }
  }
}














// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:tabourak/colors/app_colors.dart';

// class ProfileContent extends StatefulWidget {
//   @override
//   _ProfileContentState createState() => _ProfileContentState();
// }

// class _ProfileContentState extends State<ProfileContent> {
//   String firstName = "Shahd";
//   String lastName = "Yaseen";
//   String selectedLanguage = "English";
//   String selectedTimezone = "Asia / Jerusalem";
//   String profileImageUrl = "assets/images/img.JPG";
//   XFile? selectedImage;

//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(
//       source: ImageSource.gallery,
//     );
//     if (image != null) {
//       setState(() {
//         selectedImage = image;
//       });
//     }
//   }

//   void _removeImage() {
//     setState(() {
//       selectedImage = null;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header Section
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "User Profile",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textColor,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               "Your profile information is shared across all organizations you are a member of.",
//               style: TextStyle(
//                 color: AppColors.textColorSecond,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//         Divider(
//           color: AppColors.mediumColor,
//           thickness: 1,
//           height: 24,
//         ),

//         // Form Section
//         Column(
//           children: [
//             // Name and Timezone Row
//             Column(
//               children: [
//                 // First Name
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "First Name",
//                       style: TextStyle(
//                         color: AppColors.textColor,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     TextField(
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderSide: BorderSide(color: AppColors.mediumColor),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         contentPadding: EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 10),
//                         hintText: "Enter First Name",
//                         filled: true,
//                         fillColor: AppColors.backgroundColor,
//                       ),
//                       controller: TextEditingController(text: firstName),
//                       style: TextStyle(color: AppColors.textColor),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),

//                 // Last Name
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Last Name",
//                       style: TextStyle(
//                         color: AppColors.textColor,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     TextField(
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderSide: BorderSide(color: AppColors.mediumColor),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         contentPadding: EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 10),
//                         hintText: "Enter Last Name",
//                         filled: true,
//                         fillColor: AppColors.backgroundColor,
//                       ),
//                       controller: TextEditingController(text: lastName),
//                       style: TextStyle(color: AppColors.textColor),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),

//                 // Timezone
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Timezone",
//                       style: TextStyle(
//                         color: AppColors.textColor,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: AppColors.mediumColor),
//                         borderRadius: BorderRadius.circular(4),
//                         color: AppColors.backgroundColor,
//                       ),
//                       padding: EdgeInsets.symmetric(horizontal: 12),
//                       height: 48,
//                       child: Row(
//                         children: [
//                           Icon(Icons.public, color: AppColors.primaryColor),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               selectedTimezone,
//                               style: TextStyle(
//                                 color: AppColors.textColor,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             "10:12 PM",
//                             style: TextStyle(
//                               color: AppColors.textColorSecond,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),

//                 // Language
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           "Language",
//                           style: TextStyle(
//                             color: AppColors.textColor,
//                             fontWeight: FontWeight.w500),
//                         ),
//                         SizedBox(width: 4),
//                         Icon(Icons.help_outline,
//                             size: 18, color: AppColors.textColorSecond),
//                       ],
//                     ),
//                     SizedBox(height: 4),
//                     DropdownButtonFormField<String>(
//                       value: selectedLanguage,
//                       items: ["English", "Arabic", "French"]
//                           .map(
//                             (lang) => DropdownMenuItem(
//                               value: lang,
//                               child: Text(
//                                 lang,
//                                 style: TextStyle(
//                                     color: AppColors.textColor, fontSize: 16),
//                               )),
//                           )
//                           .toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           selectedLanguage = value!;
//                         });
//                       },
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: AppColors.mediumColor),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         filled: true,
//                         fillColor: AppColors.backgroundColor,
//                       ),
//                       icon: Icon(Icons.keyboard_arrow_down,
//                           color: AppColors.textColorSecond),
//                       style: TextStyle(color: AppColors.textColor),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),

//                 // Picture
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Picture",
//                       style: TextStyle(
//                         color: AppColors.textColor,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         GestureDetector(
//                           onTap: _pickImage,
//                           child: Stack(
//                             children: [
//                               CircleAvatar(
//                                 radius: 50,
//                                 backgroundImage: selectedImage != null
//                                     ? FileImage(File(selectedImage!.path))
//                                     : AssetImage(profileImageUrl)
//                                         as ImageProvider,
//                               ),
//                               if (selectedImage != null)
//                                 Positioned(
//                                   top: 0,
//                                   right: 0,
//                                   child: GestureDetector(
//                                     onTap: _removeImage,
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         color: AppColors.backgroundColor,
//                                         shape: BoxShape.circle,
//                                       ),
//                                       padding: EdgeInsets.all(2),
//                                       child: Icon(
//                                         Icons.close,
//                                         size: 20,
//                                         color: AppColors.textColor,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               ElevatedButton(
//                                 onPressed: _pickImage,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.mediumColor,
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 24, vertical: 12),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   minimumSize: Size(double.infinity, 48),
//                                 ),
//                                 child: Text(
//                                   "Change Picture",
//                                   style: TextStyle(color: AppColors.textColor),
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 "Click on the image or button to change",
//                                 style: TextStyle(
//                                   color: AppColors.textColorSecond,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//         SizedBox(height: 24),

//         // Save Button
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: () {},
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryColor,
//               padding: EdgeInsets.symmetric(vertical: 14),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//             child: Text(
//               "Save Changes",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }