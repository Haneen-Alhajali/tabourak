import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/config/config.dart';
import 'package:tabourak/config/globals.dart';
import 'dart:io';
import 'dart:convert';
import 'package:tabourak/config/snackbar_helper.dart';

class GeneralSettingsContent extends StatefulWidget {
  @override
  _GeneralSettingsContentState createState() => _GeneralSettingsContentState();
}

class _GeneralSettingsContentState extends State<GeneralSettingsContent> {
  final List<Color> colorOptions = [
    Color(0xFF1C8B97), Color(0xFF2980B9), Color(0xFF0ED70A),
    Color(0xFF009432), Color(0xFFC40404), Color(0xFFED4C67),
    Color(0xFFFA8A1A), Color(0xFF851EFF), Color(0xFFD980FA),
    Color(0xFFF1C40F), Color(0xFF8A9199),
  ];

  Color selectedColor = Color(0xFF1C8B97); // Initialize with default color
  String workspaceName = "My Workspace";
  bool hideBranding = false;
  File? _image;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isUploading = false;
  String? _logoUrl;

  final TextEditingController _workspaceNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  @override
  void dispose() {
    _workspaceNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchSettings() async {
    try {
      setState(() => _isLoading = true);
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/booking-pages'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          workspaceName = data['title'] ?? "My Workspace";
          _workspaceNameController.text = workspaceName;
          
          if (data['color_primary'] != null) {
            final colorString = data['color_primary'].toString().replaceFirst('#', '');
            try {
              // Only update if the color is different to avoid unnecessary rebuilds
              final newColor = Color(int.parse('0xFF$colorString'));
              if (selectedColor.value != newColor.value) {
                selectedColor = newColor;
              }
            } catch (e) {
              debugPrint('Error parsing color: $e');
              // Keep current color if parsing fails
            }
          }
          
          _logoUrl = data['logo_url'];
          hideBranding = data['hide_branding'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching settings: $e');
      // Don't reset the color on error - keep current selection
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _logoUrl = null;
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

  Future<String?> _uploadImage(File image) async {
    try {
      if (!await image.exists()) throw 'Image file not found';
      if (await image.length() <= 0) throw 'Image file is empty';

      final extension = path.extension(image.path).toLowerCase().replaceFirst('.', '');
      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        throw 'Only JPG/PNG images are allowed';
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/api/upload/image'),
      );
      request.headers['Authorization'] = 'Bearer $globalAuthToken';

      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType('image', extension),
      );
      request.files.add(multipartFile);

      setState(() => _isUploading = true);
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return jsonResponse['url'];
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
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_isSubmitting || _isUploading) return;
    
    // Store current state before any changes
    final currentColor = selectedColor;
    final currentImage = _image;
    final currentLogoUrl = _logoUrl;
    
    setState(() => _isSubmitting = true);

    try {
      if (_workspaceNameController.text.isEmpty) {
        throw 'Please enter a workspace name';
      }

      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
        if (imageUrl == null) {
          throw 'Failed to upload image';
        }
      } else if (_logoUrl != null) {
        imageUrl = _logoUrl;
      }

      final colorHex = '#${currentColor.value.toRadixString(16).substring(2)}';
      
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/booking-pages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $globalAuthToken',
        },
        body: jsonEncode({
          'title': _workspaceNameController.text,
          'color_primary': colorHex,
          'logo_url': imageUrl,
          'hide_branding': hideBranding,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Settings saved successfully'),
        //     duration: Duration(seconds: 2),
        //   ),
        // );
        SnackbarHelper.showSuccess(context, 'Settings saved successfully');

        // Update local state without refetching to maintain UI state
        setState(() {
          if (imageUrl != null) {
            _logoUrl = imageUrl;
            _image = null;
          }
        });
      } else {
        // Restore previous state on failure
        setState(() {
          selectedColor = currentColor;
          _image = currentImage;
          _logoUrl = currentLogoUrl;
        });
        throw responseData['error'] ?? 'Failed to update settings: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(e.toString()),
      //     duration: Duration(seconds: 4),
      //   ),
      // );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "General Settings",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Customize your organization and scheduling pages.",
                style: TextStyle(
                  color: AppColors.textColorSecond,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(color: AppColors.mediumColor, height: 1),
          SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Workspace Name",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.mediumColor),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      controller: _workspaceNameController,
                      style: TextStyle(color: AppColors.textColor),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24),
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.mediumColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _image != null
                          ? Image.file(_image!, fit: BoxFit.cover)
                          : (_logoUrl != null
                              ? Image.network(
                                  _logoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _uploadPlaceholder();
                                  },
                                )
                              : _uploadPlaceholder()),
                    ),
                    if (_isUploading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black54,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(color: AppColors.mediumColor, height: 1),
          SizedBox(height: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Brand Color",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.help_outline,
                    size: 18,
                    color: AppColors.textColorSecond,
                  ),
                ],
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colorOptions.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                        border: color.value == selectedColor.value
                            ? Border.all(
                                color: AppColors.primaryColor, 
                                width: 2,
                              )
                            : null,
                      ),
                      child: color.value == selectedColor.value
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 100),


          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: _isSubmitting
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text(
                      "Save Changes",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _uploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.upload,
          size: 40,
          color: AppColors.textColorSecond,
        ),
        Text(
          "Upload Logo",
          style: TextStyle(
            color: AppColors.textColorSecond,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}







// // lib\content\settings\general_settings_content.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';

// class GeneralSettingsContent extends StatefulWidget {
//   @override
//   _GeneralSettingsContentState createState() => _GeneralSettingsContentState();
// }

// class _GeneralSettingsContentState extends State<GeneralSettingsContent> {
//   final List<Color> colorOptions = [
//     Color(0xFF1C8B97), Color(0xFF2980B9), Color(0xFF0ED70A),
//     Color(0xFF009432), Color(0xFFC40404), Color(0xFFED4C67),
//     Color(0xFFFA8A1A), Color(0xFF851EFF), Color(0xFFD980FA),
//     Color(0xFFF1C40F), Color(0xFF8A9199),
//   ];

//   Color selectedColor = Color(0xFF1C8B97);
//   String workspaceName = "Yasmine Ro's account";
//   bool hideBranding = false;

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "General Settings",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.textColor,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 "Customize your organization and scheduling pages.",
//                 style: TextStyle(
//                   color: AppColors.textColorSecond,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           Divider(color: AppColors.mediumColor, height: 1),
//           SizedBox(height: 24),

//           // Workspace Name and Logo
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Workspace Name",
//                       style: TextStyle(
//                         fontWeight: FontWeight.w500,
//                         color: AppColors.textColor,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     TextField(
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderSide: BorderSide(color: AppColors.mediumColor),
//                         ),
//                         contentPadding: EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 12),
//                       ),
//                       controller: TextEditingController(text: workspaceName),
//                       style: TextStyle(color: AppColors.textColor),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 24),
//               // Logo Upload
//               GestureDetector(
//                 onTap: () {
//                   // Handle image upload
//                 },
//                 child: Container(
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: AppColors.mediumColor),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.upload,
//                         size: 40,
//                         color: AppColors.textColorSecond,
//                       ),
//                       Text(
//                         "Upload Logo",
//                         style: TextStyle(
//                           color: AppColors.textColorSecond,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           Divider(color: AppColors.mediumColor, height: 1),
//           SizedBox(height: 16),

//           // Brand Color
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     "Brand Color",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       color: AppColors.textColor,
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   Icon(
//                     Icons.help_outline,
//                     size: 18,
//                     color: AppColors.textColorSecond,
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: colorOptions.map((color) {
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedColor = color;
//                       });
//                     },
//                     child: Container(
//                       width: 28,
//                       height: 28,
//                       decoration: BoxDecoration(
//                         color: color,
//                         borderRadius: BorderRadius.circular(4),
//                         border: color == selectedColor
//                             ? Border.all(
//                                 color: AppColors.primaryColor, width: 2)
//                             : null,
//                       ),
//                       child: color == selectedColor
//                           ? Icon(
//                               Icons.check,
//                               size: 16,
//                               color: Colors.white,
//                             )
//                           : null,
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           Divider(color: AppColors.mediumColor, height: 1),
//           SizedBox(height: 16),


//           SizedBox(height: 24),

//           // Save Button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () {
//                 // Handle save
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryColor,
//                 padding: EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//               child: Text(
//                 "Save Changes",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//         ],
//       ),
//     );
//   }
// }