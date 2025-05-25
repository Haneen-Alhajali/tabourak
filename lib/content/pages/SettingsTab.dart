// lib/content/pages/SettingsTab.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tabourak/colors/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tabourak/config/config.dart';
import 'package:tabourak/config/globals.dart';

class SettingsTab extends StatefulWidget {
  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  File? _selectedImage;
  String? _logoUrl; // Store the network image URL
  Map<String, String> settings = {
    'Page Title': 'Loading...',
    'Page URL': 'Loading...',
    'Welcome Message': 'Loading...',
    'Language': 'Loading...',
  };
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/settings'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          settings = {
            'Page Title': data['Page Title'] ?? 'Meet with User',
            'Page URL': data['Page URL'] ?? 'https://appt.link/meet-with-user',
            'Welcome Message': data['Welcome Message'] ?? 'No welcome message provided.',
            'Language': data['Language'] ?? 'English',
          };
          _logoUrl = data['Logo URL']; // Store the network URL
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load settings');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading settings: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isUploading = true;
        });
        
        // Upload the image to server
        await _uploadImage(_selectedImage!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  Future<void> _uploadImage(File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/api/upload/image'),
      );
      request.headers['Authorization'] = 'Bearer $globalAuthToken';

      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        image.path,
      );
      request.files.add(multipartFile);

      var response = await request.send();
      if (response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        
        setState(() {
          _logoUrl = jsonResponse['url'];
          _isUploading = false;
        });
        
        // Update the settings with new logo URL
        await _updateLogoUrl(_logoUrl!);
      } else {
        throw Exception('Upload failed with status ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateLogoUrl(String logoUrl) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/booking-pages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $globalAuthToken',
        },
        body: jsonEncode({
          'logo_url': logoUrl,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update logo URL');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update settings: ${e.toString()}')),
      );
    }
  }

  Future<void> _editSetting(String key) async {
    TextEditingController controller = TextEditingController(text: settings[key]);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $key'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new value'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppColors.textColorSecond)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  settings[key] = controller.text;
                });
                Navigator.pop(context);
                // _updateSetting(key, controller.text);
              },
              child: Text('Save', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColor)),
            ),
          ],
        );
      },
    );
  }

  // Future<void> _updateSetting(String key, String value) async {
  //   try {
  //     final Map<String, String> fieldMap = {
  //       'Page Title': 'title',
  //       'Welcome Message': 'welcome_message',
  //     };

  //     if (!fieldMap.containsKey(key)) return;

  //     final response = await http.put(
  //       Uri.parse('${AppConfig.baseUrl}/api/booking-pages'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $globalAuthToken',
  //       },
  //       body: jsonEncode({
  //         fieldMap[key]!: value,
  //       }),
  //     );

  //     if (response.statusCode != 200) {
  //       throw Exception('Failed to update setting');
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to update setting: ${e.toString()}')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView(
            padding: EdgeInsets.all(16),
            children: [
              for (var entry in settings.entries) ...[
                _buildSettingItem(title: entry.key, value: entry.value),
                Divider(),
              ],
              _buildImageUploadSection(),
            ],
          );
  }

  Widget _buildSettingItem({required String title, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColor)),
              SizedBox(height: 4),
              Text(value, softWrap: true, overflow: TextOverflow.visible),
            ],
          ),
        ),
        if (title != 'Page URL' && title != 'Language')
          TextButton(
            onPressed: () => _editSetting(title),
            child: Text('Edit', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColorSecond)),
          ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Picture or Logo', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _getImageProvider(),
                ),
                if (_isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: _isUploading ? null : _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mediumColor,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isUploading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Uploading...'),
                            ],
                          )
                        : Text('Upload Picture', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColor)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'JPG or PNG. For best presentation, should be square and at least 128px by 128px.',
                    style: TextStyle(color: AppColors.textColorSecond),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  ImageProvider _getImageProvider() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (_logoUrl != null && _logoUrl!.isNotEmpty) {
      return NetworkImage(_logoUrl!);
    }
    return NetworkImage('https://lh3.googleusercontent.com/a/ACg8ocJAQC0fAmGjJI69Gu6m5-EuRhxJDIlgOj6E0lZxiH24QDKTKA=s96-c');
  }
}



// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:tabourak/colors/app_colors.dart';

// class SettingsTab extends StatefulWidget {
//   @override
//   _SettingsTabState createState() => _SettingsTabState();
// }

// class _SettingsTabState extends State<SettingsTab> {
//   File? _selectedImage;
//   Map<String, String> settings = {
//     'Page Title': 'Meet with Yasmine Ro',
//     'Page URL': 'https://appt.link/meet-with-yasmine-ro-yUnB9Oqn',
//     'Welcome Message': 'No welcome message provided.',
//     'Language': 'English',
//   };

//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _editSetting(String key) async {
//     TextEditingController controller = TextEditingController(text: settings[key]);
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Edit $key'),
//           content: TextField(
//             controller: controller,
//             decoration: InputDecoration(hintText: 'Enter new value'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancel', style: TextStyle(color: AppColors.textColorSecond)),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   settings[key] = controller.text;
//                 });
//                 Navigator.pop(context);
//               },
//               child: Text('Save', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColor)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: EdgeInsets.all(16),
//       children: [
//         for (var entry in settings.entries) ...[
//           _buildSettingItem(title: entry.key, value: entry.value),
//           Divider(),
//         ],
//         _buildImageUploadSection(),
//       ],
//     );
//   }

//   Widget _buildSettingItem({required String title, required String value}) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColor)),
//               SizedBox(height: 4),
//               Text(value, softWrap: true, overflow: TextOverflow.visible),
//             ],
//           ),
//         ),
//         TextButton(
//           onPressed: () => _editSetting(title),
//           child: Text('Edit', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColorSecond)),
//         ),
//       ],
//     );
//   }

//   Widget _buildImageUploadSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Picture or Logo', style: TextStyle(fontWeight: FontWeight.bold)),
//         SizedBox(height: 8),
//         Row(
//           children: [
//             CircleAvatar(
//               radius: 40,
//               backgroundImage: _selectedImage != null
//                   ? FileImage(_selectedImage!)
//                   : NetworkImage('https://lh3.googleusercontent.com/a/ACg8ocJAQC0fAmGjJI69Gu6m5-EuRhxJDIlgOj6E0lZxiH24QDKTKA=s96-c') as ImageProvider,
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ElevatedButton(
//                     onPressed: _pickImage,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.mediumColor,
//                       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                     ),
//                     child: Text('Upload Picture', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColor)),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     'JPG or PNG. For best presentation, should be square and at least 128px by 128px.',
//                     style: TextStyle(color: AppColors.textColorSecond),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }