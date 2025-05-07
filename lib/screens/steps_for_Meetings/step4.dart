// lib/screens/steps_for_Meetings/step4.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:tabourak/screens/home_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import '../../colors/app_colors.dart';
import '../../config/config.dart';
import '../../config/globals.dart';

class SchedulingPage extends StatefulWidget {
  const SchedulingPage({Key? key}) : super(key: key);

  @override
  _SchedulingPageState createState() => _SchedulingPageState();
}

class _SchedulingPageState extends State<SchedulingPage> {
  late TextEditingController _titleController;
  Color selectedColor = Color(0xFF1E9BFF);
  File? _image;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isUploading = false;
  double _uploadProgress = 0;
  String _userName = "User";
  bool _hasExistingPage = false;
  Map<String, dynamic>? _existingPage;

  final List<Color> colorOptions = [
    Color(0xFF1C8B97), Color(0xFF2980B9), Color(0xFF0ED70A),
    Color(0xFF009432), Color(0xFFC40404), Color(0xFFED4C67),
    Color(0xFFFA8A1A), Color(0xFF851EFF), Color(0xFFD980FA),
    Color(0xFFF1C40F), Color(0xFF8A9199),
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: "Meet with User");
    _fetchUserData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _image = null;
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      // Fetch user name
      final userResponse = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/user'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
        },
      );

      if (userResponse.statusCode == 200) {
        final userData = jsonDecode(userResponse.body) as Map<String, dynamic>;
        setState(() {
          _userName = userData['name'] ?? 'User';
          _titleController.text = "Meet with $_userName";
        });
      }

      // Check for existing booking page settings
      final bookingPageResponse = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/booking-pages'),
        headers: {
          'Authorization': 'Bearer $globalAuthToken',
        },
      );

      if (bookingPageResponse.statusCode == 200) {
        final pageData = jsonDecode(bookingPageResponse.body) as Map<String, dynamic>;
        if (pageData.isNotEmpty) {
          setState(() {
            _hasExistingPage = true;
            _existingPage = pageData;
            _titleController.text = _existingPage!['title'] ?? "Meet with $_userName";
            
            // Set color if it exists in the existing page
            if (_existingPage!['color_primary'] != null) {
              final colorString = _existingPage!['color_primary'].toString().replaceFirst('#', '');
              selectedColor = Color(int.parse('0xFF$colorString'));
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }
 
  Future<void> _pickImage() async {
    if (_isLoading || _isUploading) return;
    
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
          _image = imageFile;
          _uploadProgress = 0;
        });
      }
    } catch (e) {
      debugPrint('Image picking error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load image: ${e.toString()}'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _saveBookingPage() async {
    if (_isSubmitting || _isUploading) return;
    
    setState(() {
      _isSubmitting = true;
      _isLoading = true;
    });

    try {
      if (_titleController.text.isEmpty) {
        throw 'Please enter a title for your scheduling page';
      }

      String? imageUrl;
      if (_image != null) {
        setState(() => _isUploading = true);
        imageUrl = await _uploadImageWithoutStream(_image!);
        setState(() => _isUploading = false);
        if (imageUrl == null) {
          throw 'Failed to upload image';
        }
      } else if (_hasExistingPage && _existingPage?['logo_url'] != null) {
        // Keep existing image if no new one was uploaded
        imageUrl = _existingPage!['logo_url'];
      }

      final colorHex = '#${selectedColor.value.toRadixString(16).substring(2)}';
      
      // Changed endpoint to match new backend structure
      final response = await (_hasExistingPage
          ? http.put(
              Uri.parse('${AppConfig.baseUrl}/api/booking-pages'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $globalAuthToken',
              },
              body: jsonEncode({
                'title': _titleController.text,
                'color_primary': colorHex,
                'logo_url': imageUrl,
              }),
            )
          : http.post(
              Uri.parse('${AppConfig.baseUrl}/api/booking-pages'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $globalAuthToken',
              },
              body: jsonEncode({
                'title': _titleController.text,
                'color_primary': colorHex,
                'logo_url': imageUrl,
              }),
            )).timeout(Duration(seconds: 30));

      // final responseData = jsonDecode(response.body);
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        throw responseData['error'] ?? 'Failed to ${_hasExistingPage ? 'update' : 'create'} booking page: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error in _saveBookingPage: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isLoading = false;
          _isUploading = false;
        });
      }
    }
  }

  Future<String?> _uploadImageWithoutStream(File image) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image upload failed: ${e.toString()}'),
          duration: Duration(seconds: 4),
        ),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            top: 60,
            left: 20,
            child: Image.asset(
              'images/tabourakNobackground.png',
              width: 60,
              height: 60,
            ),
          ),
          Positioned(
            top: 80,
            right: 20,
            child: Text(
              "Step 4 of 4",
              style: TextStyle(
                color: AppColors.textColorSecond,
                fontSize: 15,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 150,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom > 0 
                  ? MediaQuery.of(context).viewInsets.bottom + 60
                  : 80,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Finally, Let's Make it Yours",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Personalize your scheduling page to match your brand and style.",
                          style: TextStyle(color: AppColors.textColorSecond),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Your Scheduling Page's Title",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "Enter title",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Color Scheme",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 6.4,
                    runSpacing: 6.4,
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
                          ),
                          child: selectedColor == color
                              ? Center(
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                )
                              : SizedBox(),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Your Logo",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.textColorSecond),
                              ),
                              child: _image == null
                                  ? (_hasExistingPage && _existingPage?['logo_url'] != null
                                      ? ClipOval(
                                          child: Image.network(
                                            _existingPage!['logo_url'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(
                                                Icons.camera_alt,
                                                size: 40,
                                                color: AppColors.textColorSecond,
                                              );
                                            },
                                          ),
                                        )
                                      : Icon(
                                          Icons.camera_alt,
                                          size: 40,
                                          color: AppColors.textColorSecond,
                                        ))
                                  : ClipOval(
                                      child: Image.file(
                                        _image!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          ),
                          if (_isUploading && _image != null)
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
                        ],
                      ),
                      SizedBox(width: 12),
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
                              child: _isUploading && _image != null
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
                                  : Text("Upload Picture"),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "JPG or PNG. For best presentation, should be square and at least 128px by 128px.",
                              style: TextStyle(
                                color: AppColors.textColorSecond,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 210),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: (_isSubmitting || _isUploading) ? null : _saveBookingPage,
                      child: (_isSubmitting || _isUploading)
                          ? CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              _hasExistingPage ? "Update Scheduling Page" : "Create Scheduling Page",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.backgroundColor,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom > 0 
                ? MediaQuery.of(context).viewInsets.bottom + 20
                : 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "Privacy Policy | Terms & Conditions",
                  style: TextStyle(
                    color: AppColors.textColorSecond,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "© 2025 Tabourak",
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
    );
  }
}
// // lib\screens\steps_for_Meetings\step4.dart
// // lib\screens\steps_for_Meetings\step4.dart
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:path/path.dart' as path;
// import 'package:tabourak/screens/home_screen.dart';
// import 'dart:io';
// import 'dart:convert';
// import 'dart:async';
// import '../../colors/app_colors.dart';
// import '../../config/config.dart';
// import '../../config/globals.dart';


// class SchedulingPage extends StatefulWidget {

//   const SchedulingPage({Key? key}) : super(key: key);

//   @override
//   _SchedulingPageState createState() => _SchedulingPageState();
// }

// class _SchedulingPageState extends State<SchedulingPage> {
//   late TextEditingController _titleController;
//   Color selectedColor = Color(0xFF1E9BFF);
//   File? _image;
//   bool _isLoading = false;
//   bool _isSubmitting = false;
//   bool _isUploading = false;
//   double _uploadProgress = 0;
//   String _userName = "User";
//   bool _hasExistingPage = false;
//   Map<String, dynamic>? _existingPage;

//   final List<Color> colorOptions = [
//     Color(0xFF1C8B97), Color(0xFF2980B9), Color(0xFF0ED70A),
//     Color(0xFF009432), Color(0xFFC40404), Color(0xFFED4C67),
//     Color(0xFFFA8A1A), Color(0xFF851EFF), Color(0xFFD980FA),
//     Color(0xFFF1C40F), Color(0xFF8A9199),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: "Meet with User");
//     _fetchUserData();
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _image = null;
//     super.dispose();
//   }

//   Future<void> _fetchUserData() async {
//     try {
//       // Fetch user name
//       final userResponse = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/user'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (userResponse.statusCode == 200) {
//         final userData = jsonDecode(userResponse.body);
//         setState(() {
//           _userName = userData['name'] ?? 'User';
//           _titleController.text = "Meet with $_userName";
//         });
//       }

//       // Check for existing booking page
//       final bookingPageResponse = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/booking-pages'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (bookingPageResponse.statusCode == 200) {
//         final pages = jsonDecode(bookingPageResponse.body);
//         if (pages is List && pages.isNotEmpty) {
//           setState(() {
//             _hasExistingPage = true;
//             _existingPage = pages[0];
//             _titleController.text = _existingPage!['title'] ?? "Meet with $_userName";
            
//             // Set color if it exists in the existing page
//             if (_existingPage!['color_primary'] != null) {
//               final colorString = _existingPage!['color_primary'].toString().replaceFirst('#', '');
//               selectedColor = Color(int.parse('0xFF$colorString'));
//             }
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Error fetching user data: $e');
//     }
//   }

//   Future<void> _pickImage() async {
//     if (_isLoading || _isUploading) return;
    
//     try {
//       final pickedFile = await ImagePicker().pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 85,
//         maxWidth: 1024,
//         maxHeight: 1024,
//       );
      
//       if (pickedFile != null) {
//         final imageFile = File(pickedFile.path);
//         final bytes = await imageFile.readAsBytes();
//         if (bytes.isEmpty) throw 'Image file is empty';

//         setState(() {
//           _image = imageFile;
//           _uploadProgress = 0;
//         });
//       }
//     } catch (e) {
//       debugPrint('Image picking error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to load image: ${e.toString()}'),
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   Future<void> _saveBookingPage() async {
//     if (_isSubmitting || _isUploading) return;
    
//     setState(() {
//       _isSubmitting = true;
//       _isLoading = true;
//     });

//     try {
//       if (_titleController.text.isEmpty) {
//         throw 'Please enter a title for your scheduling page';
//       }

//       String? imageUrl;
//       if (_image != null) {
//         setState(() => _isUploading = true);
//         imageUrl = await _uploadImageWithoutStream(_image!);
//         setState(() => _isUploading = false);
//         if (imageUrl == null) {
//           throw 'Failed to upload image';
//         }
//       } else if (_hasExistingPage && _existingPage?['logo_url'] != null) {
//         // Keep existing image if no new one was uploaded
//         imageUrl = _existingPage!['logo_url'];
//       }

//       final colorHex = '#${selectedColor.value.toRadixString(16).substring(2)}';
      
//       final response = await (_hasExistingPage
//           ? http.put(
//               Uri.parse('${AppConfig.baseUrl}/api/booking-pages/${_existingPage!['page_id']}'),
//               headers: {
//                 'Content-Type': 'application/json',
//                 'Authorization': 'Bearer $globalAuthToken',
//               },
//               body: jsonEncode({
//                 'title': _titleController.text,
//                 'color_primary': colorHex,
//                 'logo_url': imageUrl,
//               }),
//             )
//           : http.post(
//               Uri.parse('${AppConfig.baseUrl}/api/booking-pages'),
//               headers: {
//                 'Content-Type': 'application/json',
//                 'Authorization': 'Bearer $globalAuthToken',
//               },
//               body: jsonEncode({
//                 'title': _titleController.text,
//                 'color_primary': colorHex,
//                 'logo_url': imageUrl,
//               }),
//             )).timeout(Duration(seconds: 30));

//       final responseData = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       } else {
//         throw responseData['error'] ?? 'Failed to ${_hasExistingPage ? 'update' : 'create'} booking page: ${response.statusCode}';
//       }
//     } catch (e) {
//       debugPrint('Error in _saveBookingPage: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(e.toString()),
//           duration: Duration(seconds: 4),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSubmitting = false;
//           _isLoading = false;
//           _isUploading = false;
//         });
//       }
//     }
//   }

//   Future<String?> _uploadImageWithoutStream(File image) async {
//     try {
//       if (!await image.exists()) throw 'Image file not found';
//       if (await image.length() <= 0) throw 'Image file is empty';

//       final extension = path.extension(image.path).toLowerCase().replaceFirst('.', '');
//       if (!['jpg', 'jpeg', 'png'].contains(extension)) {
//         throw 'Only JPG/PNG images are allowed';
//       }

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('${AppConfig.baseUrl}/api/upload/image'),
//       );
//       request.headers['Authorization'] = 'Bearer $globalAuthToken';

//       var multipartFile = await http.MultipartFile.fromPath(
//         'file',
//         image.path,
//         contentType: MediaType('image', extension),
//       );
//       request.files.add(multipartFile);

//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);
//       final jsonResponse = jsonDecode(response.body);

//       if (response.statusCode == 201) {
//         return jsonResponse['url'];
//       } else {
//         throw jsonResponse['error'] ?? 'Upload failed with status ${response.statusCode}';
//       }
//     } catch (e) {
//       debugPrint('Image upload error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Image upload failed: ${e.toString()}'),
//           duration: Duration(seconds: 4),
//         ),
//       );
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       resizeToAvoidBottomInset: false,
//       body: Stack(
//         children: [
//           Positioned(
//             top: 60,
//             left: 20,
//             child: Image.asset(
//               'images/tabourakNobackground.png',
//               width: 60,
//               height: 60,
//             ),
//           ),
//           Positioned(
//             top: 80,
//             right: 20,
//             child: Text(
//               "Step 4 of 4",
//               style: TextStyle(
//                 color: AppColors.textColorSecond,
//                 fontSize: 15,
//               ),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.only(
//               top: 150,
//               left: 20,
//               right: 20,
//               bottom: MediaQuery.of(context).viewInsets.bottom > 0 
//                   ? MediaQuery.of(context).viewInsets.bottom + 60
//                   : 80,
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Column(
//                       children: [
//                         Text(
//                           "Finally, Let's Make it Yours",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           "Personalize your scheduling page to match your brand and style.",
//                           style: TextStyle(color: AppColors.textColorSecond),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "Your Scheduling Page's Title",
//                     style: TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   SizedBox(height: 5),
//                   TextField(
//                     controller: _titleController,
//                     decoration: InputDecoration(
//                       hintText: "Enter title",
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "Color Scheme",
//                     style: TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   SizedBox(height: 8),
//                   Wrap(
//                     spacing: 6.4,
//                     runSpacing: 6.4,
//                     children: colorOptions.map((color) {
//                       return GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             selectedColor = color;
//                           });
//                         },
//                         child: Container(
//                           width: 28,
//                           height: 28,
//                           decoration: BoxDecoration(
//                             color: color,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: selectedColor == color
//                               ? Center(
//                                   child: Icon(
//                                     Icons.check,
//                                     color: Colors.white,
//                                     size: 16,
//                                   ),
//                                 )
//                               : SizedBox(),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "Your Logo",
//                     style: TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Stack(
//                         children: [
//                           GestureDetector(
//                             onTap: _pickImage,
//                             child: Container(
//                               width: 100,
//                               height: 100,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: AppColors.textColorSecond),
//                               ),
//                               child: _image == null
//                                   ? (_hasExistingPage && _existingPage?['logo_url'] != null
//                                       ? ClipOval(
//                                           child: Image.network(
//                                             _existingPage!['logo_url'],
//                                             fit: BoxFit.cover,
//                                             errorBuilder: (context, error, stackTrace) {
//                                               return Icon(
//                                                 Icons.camera_alt,
//                                                 size: 40,
//                                                 color: AppColors.textColorSecond,
//                                               );
//                                             },
//                                           ),
//                                         )
//                                       : Icon(
//                                           Icons.camera_alt,
//                                           size: 40,
//                                           color: AppColors.textColorSecond,
//                                         ))
//                                   : ClipOval(
//                                       child: Image.file(
//                                         _image!,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                           if (_isUploading && _image != null)
//                             Positioned.fill(
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.black54,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Center(
//                                   child: CircularProgressIndicator(
//                                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             ElevatedButton(
//                               onPressed: _isUploading ? null : _pickImage,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.transparent,
//                                 foregroundColor: AppColors.primaryColor,
//                                 elevation: 0,
//                                 side: BorderSide(color: AppColors.primaryColor),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 minimumSize: Size(double.infinity, 40),
//                               ),
//                               child: _isUploading && _image != null
//                                   ? Row(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
//                                         ),
//                                         SizedBox(width: 8),
//                                         Text("Uploading..."),
//                                       ],
//                                     )
//                                   : Text("Upload Picture"),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               "JPG or PNG. For best presentation, should be square and at least 128px by 128px.",
//                               style: TextStyle(
//                                 color: AppColors.textColorSecond,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 210),
//                   Center(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primaryColor,
//                         padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                         minimumSize: Size(double.infinity, 50),
//                       ),
//                       onPressed: (_isSubmitting || _isUploading) ? null : _saveBookingPage,
//                       child: (_isSubmitting || _isUploading)
//                           ? CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             )
//                           : Text(
//                               _hasExistingPage ? "Update Scheduling Page" : "Create Scheduling Page",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: AppColors.backgroundColor,
//                               ),
//                             ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: MediaQuery.of(context).viewInsets.bottom > 0 
//                 ? MediaQuery.of(context).viewInsets.bottom + 20
//                 : 20,
//             left: 0,
//             right: 0,
//             child: Column(
//               children: [
//                 Text(
//                   "Privacy Policy | Terms & Conditions",
//                   style: TextStyle(
//                     color: AppColors.textColorSecond,
//                     fontSize: 12,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   "© 2025 Tabourak",
//                   style: TextStyle(
//                     color: AppColors.textColorSecond,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }












// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:path/path.dart' as path;
// import 'package:tabourak/screens/home_screen.dart';
// import 'dart:io';
// import 'dart:convert';
// import 'dart:async';
// import '../../colors/app_colors.dart';
// import '../../config/config.dart';

// class SchedulingPage extends StatefulWidget {
//   final String authToken;

//   const SchedulingPage({Key? key, required this.authToken}) : super(key: key);

//   @override
//   _SchedulingPageState createState() => _SchedulingPageState();
// }

// class _SchedulingPageState extends State<SchedulingPage> {
//   late TextEditingController _titleController;
//   Color selectedColor = Color(0xFF1E9BFF);
//   File? _image;
//   bool _isLoading = false;
//   bool _isSubmitting = false;
//   bool _isUploading = false;
//   double _uploadProgress = 0;
//   String _userName = "User";

//   final List<Color> colorOptions = [
//     Color(0xFF1E9BFF), Color(0xFF2980B9), Color(0xFF0ED70A),
//     Color(0xFF009432), Color(0xFFC40404), Color(0xFFED4C67),
//     Color(0xFFFA8A1A), Color(0xFF851EFF), Color(0xFFD980FA),
//     Color(0xFFF1C40F), Color(0xFF8A9199),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: "Meet with User");
//     _fetchUserName();
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _image = null;
//     super.dispose();
//   }

//   Future<void> _fetchUserName() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/user'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final userData = jsonDecode(response.body);
//         setState(() {
//           _userName = userData['name'] ?? 'User';
//           _titleController.text = "Meet with $_userName";
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching user name: $e');
//     }
//   }

//   Future<void> _pickImage() async {
//     if (_isLoading || _isUploading) return;
    
//     try {
//       final pickedFile = await ImagePicker().pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 85,
//         maxWidth: 1024,
//         maxHeight: 1024,
//       );
      
//       if (pickedFile != null) {
//         final imageFile = File(pickedFile.path);
//         final bytes = await imageFile.readAsBytes();
//         if (bytes.isEmpty) throw 'Image file is empty';

//         setState(() {
//           _image = imageFile;
//           _uploadProgress = 0;
//         });
//       }
//     } catch (e) {
//       debugPrint('Image picking error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to load image: ${e.toString()}'),
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   Future<void> _createBookingPage() async {
//     if (_isSubmitting || _isUploading) return;
    
//     setState(() {
//       _isSubmitting = true;
//       _isLoading = true;
//     });

//     try {
//       if (_titleController.text.isEmpty) {
//         throw 'Please enter a title for your scheduling page';
//       }

//       String? imageUrl;
//       if (_image != null) {
//         setState(() => _isUploading = true);
//         imageUrl = await _uploadImageWithoutStream(_image!);
//         setState(() => _isUploading = false);
//         if (imageUrl == null) {
//           throw 'Failed to upload image';
//         }
//       }

//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/booking-pages'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//         body: jsonEncode({
//           'title': _titleController.text,
//           'color_primary': '#${selectedColor.value.toRadixString(16).substring(2)}',
//           'logo_url': imageUrl,
//         }),
//       ).timeout(Duration(seconds: 30));

//       final responseData = jsonDecode(response.body);

//       if (response.statusCode == 201) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       } else if (response.statusCode == 400) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       } else {
//         throw responseData['error'] ?? 'Failed to create booking page: ${response.statusCode}';
//       }
//     } catch (e) {
//       debugPrint('Error in _createBookingPage: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(e.toString()),
//           duration: Duration(seconds: 4),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSubmitting = false;
//           _isLoading = false;
//           _isUploading = false;
//         });
//       }
//     }
//   }

//   Future<String?> _uploadImageWithoutStream(File image) async {
//     try {
//       if (!await image.exists()) throw 'Image file not found';
//       if (await image.length() <= 0) throw 'Image file is empty';

//       final extension = path.extension(image.path).toLowerCase().replaceFirst('.', '');
//       if (!['jpg', 'jpeg', 'png'].contains(extension)) {
//         throw 'Only JPG/PNG images are allowed';
//       }

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('${AppConfig.baseUrl}/api/upload/image'),
//       );
//       request.headers['Authorization'] = 'Bearer $globalAuthToken';

//       var multipartFile = await http.MultipartFile.fromPath(
//         'file',
//         image.path,
//         contentType: MediaType('image', extension),
//       );
//       request.files.add(multipartFile);

//       // Send the request without progress tracking
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);
//       final jsonResponse = jsonDecode(response.body);

//       if (response.statusCode == 201) {
//         return jsonResponse['url'];
//       } else {
//         throw jsonResponse['error'] ?? 'Upload failed with status ${response.statusCode}';
//       }
//     } catch (e) {
//       debugPrint('Image upload error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Image upload failed: ${e.toString()}'),
//           duration: Duration(seconds: 4),
//         ),
//       );
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       resizeToAvoidBottomInset: false,
//       body: Stack(
//         children: [
//           Positioned(
//             top: 60,
//             left: 20,
//             child: Image.asset(
//               'images/tabourakNobackground.png',
//               width: 60,
//               height: 60,
//             ),
//           ),
//           Positioned(
//             top: 80,
//             right: 20,
//             child: Text(
//               "Step 4 of 4",
//               style: TextStyle(
//                 color: AppColors.textColorSecond,
//                 fontSize: 15,
//               ),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.only(
//               top: 150,
//               left: 20,
//               right: 20,
//               bottom: MediaQuery.of(context).viewInsets.bottom > 0 
//                   ? MediaQuery.of(context).viewInsets.bottom + 60
//                   : 80,
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Column(
//                       children: [
//                         Text(
//                           "Finally, Let's Make it Yours",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           "Personalize your scheduling page to match your brand and style.",
//                           style: TextStyle(color: AppColors.textColorSecond),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "Your Scheduling Page's Title",
//                     style: TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   SizedBox(height: 5),
//                   TextField(
//                     controller: _titleController,
//                     decoration: InputDecoration(
//                       hintText: "Enter title",
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "Color Scheme",
//                     style: TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   SizedBox(height: 8),
//                   Wrap(
//                     spacing: 6.4,
//                     runSpacing: 6.4,
//                     children: colorOptions.map((color) {
//                       return GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             selectedColor = color;
//                           });
//                         },
//                         child: Container(
//                           width: 28,
//                           height: 28,
//                           decoration: BoxDecoration(
//                             color: color,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: selectedColor == color
//                               ? Center(
//                                   child: Icon(
//                                     Icons.check,
//                                     color: Colors.white,
//                                     size: 16,
//                                   ),
//                                 )
//                               : SizedBox(),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "Your Headshot",
//                     style: TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Stack(
//                         children: [
//                           GestureDetector(
//                             onTap: _pickImage,
//                             child: Container(
//                               width: 100,
//                               height: 100,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: AppColors.textColorSecond),
//                               ),
//                               child: _image == null
//                                   ? Icon(
//                                       Icons.camera_alt,
//                                       size: 40,
//                                       color: AppColors.textColorSecond,
//                                     )
//                                   : ClipOval(
//                                       child: Image.file(
//                                         _image!,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                           if (_isUploading && _image != null)
//                             Positioned.fill(
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.black54,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Center(
//                                   child: CircularProgressIndicator(
//                                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             ElevatedButton(
//                               onPressed: _isUploading ? null : _pickImage,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.transparent,
//                                 foregroundColor: AppColors.primaryColor,
//                                 elevation: 0,
//                                 side: BorderSide(color: AppColors.primaryColor),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 minimumSize: Size(double.infinity, 40),
//                               ),
//                               child: _isUploading && _image != null
//                                   ? Row(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
//                                         ),
//                                         SizedBox(width: 8),
//                                         Text("Uploading..."),
//                                       ],
//                                     )
//                                   : Text("Upload Picture"),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               "JPG or PNG. For best presentation, should be square and at least 128px by 128px.",
//                               style: TextStyle(
//                                 color: AppColors.textColorSecond,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 210),
//                   Center(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primaryColor,
//                         padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                         minimumSize: Size(double.infinity, 50),
//                       ),
//                       onPressed: (_isSubmitting || _isUploading) ? null : _createBookingPage,
//                       child: (_isSubmitting || _isUploading)
//                           ? CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             )
//                           : Text(
//                               "Create Scheduling Page",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: AppColors.backgroundColor,
//                               ),
//                             ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: MediaQuery.of(context).viewInsets.bottom > 0 
//                 ? MediaQuery.of(context).viewInsets.bottom + 20
//                 : 20,
//             left: 0,
//             right: 0,
//             child: Column(
//               children: [
//                 Text(
//                   "Privacy Policy | Terms & Conditions",
//                   style: TextStyle(
//                     color: AppColors.textColorSecond,
//                     fontSize: 12,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   "© 2025 Tabourak",
//                   style: TextStyle(
//                     color: AppColors.textColorSecond,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:path/path.dart' as path;
// import 'package:tabourak/screens/home_screen.dart';
// import 'dart:io';
// import 'dart:convert';
// import 'dart:async';
// import '../../colors/app_colors.dart';
// import '../../config/config.dart';

// class SchedulingPage extends StatefulWidget {
//   final String authToken;

//   const SchedulingPage({Key? key, required this.authToken}) : super(key: key);

//   @override
//   _SchedulingPageState createState() => _SchedulingPageState();
// }

// class _SchedulingPageState extends State<SchedulingPage> {
//   late TextEditingController _titleController;
//   Color selectedColor = Color(0xFF1E9BFF);
//   File? _image;
//   bool _isLoading = false;
//   bool _isSubmitting = false;
//   bool _isUploading = false;
//   double _uploadProgress = 0;
//   String _userName = "User";

//   final List<Color> colorOptions = [
//     Color(0xFF1E9BFF), Color(0xFF2980B9), Color(0xFF0ED70A),
//     Color(0xFF009432), Color(0xFFC40404), Color(0xFFED4C67),
//     Color(0xFFFA8A1A), Color(0xFF851EFF), Color(0xFFD980FA),
//     Color(0xFFF1C40F), Color(0xFF8A9199),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: "Meet with User");
//     _fetchUserName();
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _image = null;
//     super.dispose();
//   }

//   Future<void> _fetchUserName() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/user'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final userData = jsonDecode(response.body);
//         setState(() {
//           _userName = userData['name'] ?? 'User';
//           _titleController.text = "Meet with $_userName";
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching user name: $e');
//     }
//   }

//   Future<void> _pickImage() async {
//     if (_isLoading || _isUploading) return;
    
//     try {
//       final pickedFile = await ImagePicker().pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 85,
//         maxWidth: 1024,
//         maxHeight: 1024,
//       );
      
//       if (pickedFile != null) {
//         final imageFile = File(pickedFile.path);
//         final bytes = await imageFile.readAsBytes();
//         if (bytes.isEmpty) throw 'Image file is empty';

//         setState(() {
//           _image = imageFile;
//           _uploadProgress = 0;
//         });
//       }
//     } catch (e) {
//       debugPrint('Image picking error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to load image: ${e.toString()}'),
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   Future<void> _createBookingPage() async {
//     if (_isSubmitting || _isUploading) return;
    
//     setState(() {
//       _isSubmitting = true;
//       _isLoading = true;
//     });

//     try {
//       if (_titleController.text.isEmpty) {
//         throw 'Please enter a title for your scheduling page';
//       }

//       String? imageUrl;
//       if (_image != null) {
//         setState(() => _isUploading = true);
//         imageUrl = await _uploadImage(_image!);
//         setState(() => _isUploading = false);
//         if (imageUrl == null) {
//           throw 'Failed to upload image';
//         }
//       }

//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/booking-pages'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//         body: jsonEncode({
//           'title': _titleController.text,
//           'color_primary': '#${selectedColor.value.toRadixString(16).substring(2)}',
//           'logo_url': imageUrl,
//         }),
//       ).timeout(Duration(seconds: 30));

//       final responseData = jsonDecode(response.body);

//       if (response.statusCode == 201) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       } else if (response.statusCode == 400) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       } else {
//         throw responseData['error'] ?? 'Failed to create booking page: ${response.statusCode}';
//       }
//     } catch (e) {
//       debugPrint('Error in _createBookingPage: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(e.toString()),
//           duration: Duration(seconds: 4),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSubmitting = false;
//           _isLoading = false;
//           _isUploading = false;
//         });
//       }
//     }
//   }

//   Future<String?> _uploadImage(File image) async {
//     try {
//       if (!await image.exists()) throw 'Image file not found';
//       if (await image.length() <= 0) throw 'Image file is empty';

//       final extension = path.extension(image.path).toLowerCase().replaceFirst('.', '');
//       if (!['jpg', 'jpeg', 'png'].contains(extension)) {
//         throw 'Only JPG/PNG images are allowed';
//       }

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('${AppConfig.baseUrl}/api/upload/image'),
//       );
//       request.headers['Authorization'] = 'Bearer $globalAuthToken';

//       var multipartFile = await http.MultipartFile.fromPath(
//         'file',
//         image.path,
//         contentType: MediaType('image', extension),
//       );
//       request.files.add(multipartFile);

//       final totalBytes = await image.length();
//       var byteCount = 0;
//       final responseCompleter = Completer<http.Response>();

//       final streamedResponse = await request.send();
//       final responseStream = streamedResponse.stream.asBroadcastStream();

//       // Progress listener
//       responseStream.listen(
//         (chunk) {
//           byteCount += chunk.length;
//           if (mounted) {
//             setState(() {
//               _uploadProgress = byteCount / totalBytes;
//             });
//           }
//         },
//         onError: responseCompleter.completeError,
//         cancelOnError: true,
//       );

//       // Response listener
//       responseStream.listen(
//         null,
//         onDone: () async {
//           try {
//             final response = await http.Response.fromStream(streamedResponse);
//             responseCompleter.complete(response);
//           } catch (e) {
//             responseCompleter.completeError(e);
//           }
//         },
//         onError: responseCompleter.completeError,
//         cancelOnError: true,
//       );

//       final response = await responseCompleter.future;
//       final jsonResponse = jsonDecode(response.body);

//       if (response.statusCode == 201) {
//         return jsonResponse['url'];
//       } else {
//         throw jsonResponse['error'] ?? 'Upload failed with status ${response.statusCode}';
//       }
//     } catch (e) {
//       debugPrint('Image upload error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Image upload failed: ${e.toString()}'),
//           duration: Duration(seconds: 4),
//         ),
//       );
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       resizeToAvoidBottomInset: false,
//       body: Stack(
//         children: [
//           Positioned(
//             top: 60,
//             left: 20,
//             child: Image.asset(
//               'images/tabourakNobackground.png',
//               width: 60,
//               height: 60,
//             ),
//           ),
//           Positioned(
//             top: 80,
//             right: 20,
//             child: Text(
//               "Step 4 of 4",
//               style: TextStyle(
//                 color: AppColors.textColorSecond,
//                 fontSize: 15,
//               ),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.only(
//               top: 150,
//               left: 20,
//               right: 20,
//               bottom: MediaQuery.of(context).viewInsets.bottom > 0 
//                   ? MediaQuery.of(context).viewInsets.bottom + 60
//                   : 80,
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Column(
//                       children: [
//                         Text(
//                           "Finally, Let's Make it Yours",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           "Personalize your scheduling page to match your brand and style.",
//                           style: TextStyle(color: AppColors.textColorSecond),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "Your Scheduling Page's Title",
//                     style: TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   SizedBox(height: 5),
//                   TextField(
//                     controller: _titleController,
//                     decoration: InputDecoration(
//                       hintText: "Enter title",
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "Color Scheme",
//                     style: TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   SizedBox(height: 8),
//                   Wrap(
//                     spacing: 6.4,
//                     runSpacing: 6.4,
//                     children: colorOptions.map((color) {
//                       return GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             selectedColor = color;
//                           });
//                         },
//                         child: Container(
//                           width: 28,
//                           height: 28,
//                           decoration: BoxDecoration(
//                             color: color,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: selectedColor == color
//                               ? Center(
//                                   child: Icon(
//                                     Icons.check,
//                                     color: Colors.white,
//                                     size: 16,
//                                   ),
//                                 )
//                               : SizedBox(),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "Your Headshot",
//                     style: TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Stack(
//                         children: [
//                           GestureDetector(
//                             onTap: _pickImage,
//                             child: Container(
//                               width: 100,
//                               height: 100,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: AppColors.textColorSecond),
//                               ),
//                               child: _image == null
//                                   ? Icon(
//                                       Icons.camera_alt,
//                                       size: 40,
//                                       color: AppColors.textColorSecond,
//                                     )
//                                   : ClipOval(
//                                       child: Image.file(
//                                         _image!,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                           if ((_isLoading || _isUploading) && _image != null)
//                             Positioned.fill(
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.black54,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Center(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       CircularProgressIndicator(
//                                         value: _uploadProgress,
//                                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                       ),
//                                       SizedBox(height: 8),
//                                       Text(
//                                         '${(_uploadProgress * 100).toStringAsFixed(0)}%',
//                                         style: TextStyle(color: Colors.white),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             ElevatedButton(
//                               onPressed: (_isLoading || _isUploading) ? null : _pickImage,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.transparent,
//                                 foregroundColor: AppColors.primaryColor,
//                                 elevation: 0,
//                                 side: BorderSide(color: AppColors.primaryColor),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 minimumSize: Size(double.infinity, 40),
//                               ),
//                               child: (_isLoading || _isUploading) && _image != null
//                                   ? Row(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
//                                         ),
//                                         SizedBox(width: 8),
//                                         Text("Uploading..."),
//                                       ],
//                                     )
//                                   : Text("Upload Picture"),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               "JPG or PNG. For best presentation, should be square and at least 128px by 128px.",
//                               style: TextStyle(
//                                 color: AppColors.textColorSecond,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 210),
//                   Center(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primaryColor,
//                         padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                         minimumSize: Size(double.infinity, 50),
//                       ),
//                       onPressed: (_isSubmitting || _isUploading) ? null : _createBookingPage,
//                       child: (_isSubmitting || _isUploading)
//                           ? CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             )
//                           : Text(
//                               "Create Scheduling Page",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: AppColors.backgroundColor,
//                               ),
//                             ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: MediaQuery.of(context).viewInsets.bottom > 0 
//                 ? MediaQuery.of(context).viewInsets.bottom + 20
//                 : 20,
//             left: 0,
//             right: 0,
//             child: Column(
//               children: [
//                 Text(
//                   "Privacy Policy | Terms & Conditions",
//                   style: TextStyle(
//                     color: AppColors.textColorSecond,
//                     fontSize: 12,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   "© 2025 Tabourak",
//                   style: TextStyle(
//                     color: AppColors.textColorSecond,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:path/path.dart' as path;
// import 'package:tabourak/screens/home_screen.dart';
// import 'dart:io';
// import 'dart:convert';
// import 'dart:async';
// import '../../colors/app_colors.dart';
// import '../../config/config.dart';

// class SchedulingPage extends StatefulWidget {
//   final String authToken;

//   const SchedulingPage({Key? key, required this.authToken}) : super(key: key);

//   @override
//   _SchedulingPageState createState() => _SchedulingPageState();
// }

// class _SchedulingPageState extends State<SchedulingPage> {
//   late TextEditingController _titleController;
//   Color selectedColor = Color(0xFF1E9BFF);
//   File? _image;
//   bool _isLoading = false;
//   bool _isSubmitting = false;
//   double _uploadProgress = 0;
//   String _userName = "User";

//   final List<Color> colorOptions = [
//     Color(0xFF1E9BFF), Color(0xFF2980B9), Color(0xFF0ED70A),
//     Color(0xFF009432), Color(0xFFC40404), Color(0xFFED4C67),
//     Color(0xFFFA8A1A), Color(0xFF851EFF), Color(0xFFD980FA),
//     Color(0xFFF1C40F), Color(0xFF8A9199),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: "Meet with User");
//     _fetchUserName();
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _image = null; // Clear image from memory
//     super.dispose();
//   }

//   Future<void> _fetchUserName() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/user'),
//         headers: {
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final userData = jsonDecode(response.body);
//         setState(() {
//           _userName = userData['name'] ?? 'User';
//           _titleController.text = "Meet with $_userName";
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching user name: $e');
//     }
//   }

//   Future<void> _pickImage() async {
//     if (_isLoading) return;
    
//     try {
//       final pickedFile = await ImagePicker().pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 85,
//         maxWidth: 1024,
//         maxHeight: 1024,
//       );
      
//       if (pickedFile != null) {
//         // Verify the image can be loaded
//         final imageFile = File(pickedFile.path);
//         final bytes = await imageFile.readAsBytes();
//         if (bytes.isEmpty) throw 'Image file is empty';

//         setState(() {
//           _image = imageFile;
//           _uploadProgress = 0;
//         });
//       }
//     } catch (e) {
//       debugPrint('Image picking error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to load image: ${e.toString()}'),
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   Future<void> _createBookingPage() async {
//     if (_isSubmitting) return;
    
//     setState(() {
//       _isSubmitting = true;
//       _isLoading = true;
//     });

//     try {
//       if (_titleController.text.isEmpty) {
//         throw 'Please enter a title for your scheduling page';
//       }

//       String? imageUrl;
//       if (_image != null) {
//         imageUrl = await _uploadImage(_image!);
//         if (imageUrl == null) {
//           throw 'Failed to upload image';
//         }
//       }

//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/booking-pages'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $globalAuthToken',
//         },
//         body: jsonEncode({
//           'title': _titleController.text,
//           'color_primary': '#${selectedColor.value.toRadixString(16).substring(2)}',
//           'logo_url': imageUrl,
//         }),
//       ).timeout(Duration(seconds: 30));

//       final responseData = jsonDecode(response.body);

//       if (response.statusCode == 201) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       } else if (response.statusCode == 400) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       } else {
//         throw responseData['error'] ?? 'Failed to create booking page: ${response.statusCode}';
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(e.toString()),
//           duration: Duration(seconds: 4),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isSubmitting = false;
//         _isLoading = false;
//       });
//     }
//   }

//   Future<String?> _uploadImage(File image) async {
//     try {
//       // Verify file exists and is readable
//       if (!await image.exists()) throw 'Image file not found';
//       if (await image.length() <= 0) throw 'Image file is empty';

//       setState(() {
//         _isLoading = true;
//         _uploadProgress = 0;
//       });

//       final extension = path.extension(image.path).toLowerCase().replaceFirst('.', '');
//       if (!['jpg', 'jpeg', 'png'].contains(extension)) {
//         throw 'Only JPG/PNG images are allowed';
//       }

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('${AppConfig.baseUrl}/api/upload/image'),
//       );
//       request.headers['Authorization'] = 'Bearer $globalAuthToken';

//       var multipartFile = await http.MultipartFile.fromPath(
//         'file',
//         image.path,
//         contentType: MediaType('image', extension),
//       );
//       request.files.add(multipartFile);

//       var totalBytes = await image.length();
//       var byteCount = 0;

//       // Track upload progress
//       var response = await request.send();
//       response.stream.listen(
//         (List<int> chunk) {
//           byteCount += chunk.length;
//           setState(() {
//             _uploadProgress = byteCount / totalBytes;
//           });
//         },
//         onError: (e) {
//           debugPrint('Upload error: $e');
//           throw 'Upload failed: $e';
//         },
//       );

//       var responseData = await response.stream.bytesToString();
//       var jsonResponse = jsonDecode(responseData);

//       if (response.statusCode == 201) {
//         return jsonResponse['url'];
//       } else {
//         throw jsonResponse['error'] ?? 'Upload failed with status ${response.statusCode}';
//       }
//     } catch (e) {
//       debugPrint('Image upload error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Image upload failed: ${e.toString()}'),
//           duration: Duration(seconds: 4),
//         ),
//       );
//       return null;
//     } finally {
//       setState(() {
//         _isLoading = false;
//         _uploadProgress = 0;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       resizeToAvoidBottomInset: false,
//       body: Stack(
//         children: [
//           Positioned(
//             top: 60,
//             left: 20,
//             child: Image.asset(
//               'images/tabourakNobackground.png',
//               width: 60,
//               height: 60,
//             ),
//           ),
//           Positioned(
//             top: 80,
//             right: 20,
//             child: Text(
//               "Step 4 of 4",
//               style: TextStyle(
//                 color: AppColors.textColorSecond,
//                 fontSize: 15,
//               ),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.only(
//               top: 150,
//               left: 20,
//               right: 20,
//               bottom: MediaQuery.of(context).viewInsets.bottom > 0 
//                   ? MediaQuery.of(context).viewInsets.bottom + 60
//                   : 80,
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Column(
//                       children: [
//                         Text(
//                           "Finally, Let's Make it Yours",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.textColor,
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           "Personalize your scheduling page to match your brand and style.",
//                           style: TextStyle(color: AppColors.textColorSecond),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "Your Scheduling Page's Title",
//                     style: TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   SizedBox(height: 5),
//                   TextField(
//                     controller: _titleController,
//                     decoration: InputDecoration(
//                       hintText: "Enter title",
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "Color Scheme",
//                     style: TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   SizedBox(height: 8),
//                   Wrap(
//                     spacing: 6.4,
//                     runSpacing: 6.4,
//                     children: colorOptions.map((color) {
//                       return GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             selectedColor = color;
//                           });
//                         },
//                         child: Container(
//                           width: 28,
//                           height: 28,
//                           decoration: BoxDecoration(
//                             color: color,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: selectedColor == color
//                               ? Center(
//                                   child: Icon(
//                                     Icons.check,
//                                     color: Colors.white,
//                                     size: 16,
//                                   ),
//                                 )
//                               : SizedBox(),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "Your Headshot",
//                     style: TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Stack(
//                         children: [
//                           GestureDetector(
//                             onTap: _pickImage,
//                             child: Container(
//                               width: 100,
//                               height: 100,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: AppColors.textColorSecond),
//                               ),
//                               child: _image == null
//                                   ? Icon(
//                                       Icons.camera_alt,
//                                       size: 40,
//                                       color: AppColors.textColorSecond,
//                                     )
//                                   : ClipOval(
//                                       child: Image.file(
//                                         _image!,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                           if (_isLoading && _image != null)
//                             Positioned.fill(
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.black54,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Center(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       CircularProgressIndicator(
//                                         value: _uploadProgress,
//                                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                       ),
//                                       SizedBox(height: 8),
//                                       Text(
//                                         '${(_uploadProgress * 100).toStringAsFixed(0)}%',
//                                         style: TextStyle(color: Colors.white),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             ElevatedButton(
//                               onPressed: _isLoading ? null : _pickImage,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.transparent,
//                                 foregroundColor: AppColors.primaryColor,
//                                 elevation: 0,
//                                 side: BorderSide(color: AppColors.primaryColor),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 minimumSize: Size(double.infinity, 40),
//                               ),
//                               child: _isLoading && _image != null
//                                   ? Row(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
//                                         ),
//                                         SizedBox(width: 8),
//                                         Text("Uploading..."),
//                                       ],
//                                     )
//                                   : Text("Upload Picture"),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               "JPG or PNG. For best presentation, should be square and at least 128px by 128px.",
//                               style: TextStyle(
//                                 color: AppColors.textColorSecond,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 210),
//                   Center(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primaryColor,
//                         padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                         minimumSize: Size(double.infinity, 50),
//                       ),
//                       onPressed: _isSubmitting ? null : _createBookingPage,
//                       child: _isSubmitting
//                           ? CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             )
//                           : Text(
//                               "Create Scheduling Page",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: AppColors.backgroundColor,
//                               ),
//                             ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: MediaQuery.of(context).viewInsets.bottom > 0 
//                 ? MediaQuery.of(context).viewInsets.bottom + 20
//                 : 20,
//             left: 0,
//             right: 0,
//             child: Column(
//               children: [
//                 Text(
//                   "Privacy Policy | Terms & Conditions",
//                   style: TextStyle(
//                     color: AppColors.textColorSecond,
//                     fontSize: 12,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   "© 2025 Tabourak",
//                   style: TextStyle(
//                     color: AppColors.textColorSecond,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tabourak/screens/home_screen.dart';
// import 'dart:io';
// import '../../colors/app_colors.dart';
// import '../../config/config.dart';

// class SchedulingPage extends StatefulWidget {
//   final String authToken;

//   const SchedulingPage({Key? key, required this.authToken}) : super(key: key);

//   @override
//   _SchedulingPageState createState() => _SchedulingPageState();
// }

// class _SchedulingPageState extends State<SchedulingPage> {
//   TextEditingController _titleController = TextEditingController(text: "Meet with Majd Karim");
//   Color selectedColor = Color(0xFF1E9BFF);
//   File? _image;

//   final List<Color> colorOptions = [
//     Color(0xFF1E9BFF), Color(0xFF2980B9), Color(0xFF0ED70A),
//     Color(0xFF009432), Color(0xFFC40404), Color(0xFFED4C67),
//     Color(0xFFFA8A1A), Color(0xFF851EFF), Color(0xFFD980FA),
//     Color(0xFFF1C40F), Color(0xFF8A9199),
//   ];

//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       resizeToAvoidBottomInset: false, // Important for manual keyboard handling
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return Stack(
//             children: [
//               // Header with logo and step indicator
//               Positioned(
//                 top: 60,
//                 left: 20,
//                 child: Image.asset(
//                   'images/tabourakNobackground.png',
//                   width: 60,
//                   height: 60,
//                 ),
//               ),
//               Positioned(
//                 top: 80,
//                 right: 20,
//                 child: Text(
//                   "Step 4 of 4",
//                   style: TextStyle(
//                     color: AppColors.textColorSecond,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),

//               // Main content - now scrollable
//               Padding(
//                 padding: EdgeInsets.only(
//                   top: 150,
//                   left: 20,
//                   right: 20,
//                   bottom: MediaQuery.of(context).viewInsets.bottom > 0 
//                       ? MediaQuery.of(context).viewInsets.bottom + 60 // Extra space for footer when keyboard is open
//                       : 80,
//                 ),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Centered title and subtitle
//                       Center(
//                         child: Column(
//                           children: [
//                             Text(
//                               "Finally, Let's Make it Yours",
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.textColor,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               "Personalize your scheduling page to match your brand and style.",
//                               style: TextStyle(color: AppColors.textColorSecond),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       Text(
//                         "Your Scheduling Page's Title",
//                         style: TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                       SizedBox(height: 5),
//                       TextField(
//                         controller: _titleController,
//                         decoration: InputDecoration(
//                           hintText: "Enter title",
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       Text(
//                         "Color Scheme",
//                         style: TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                       SizedBox(height: 8),
//                       Wrap(
//                         spacing: 6.4,
//                         runSpacing: 6.4,
//                         children: colorOptions.map((color) {
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 selectedColor = color;
//                               });
//                             },
//                             child: Container(
//                               width: 28,
//                               height: 28,
//                               decoration: BoxDecoration(
//                                 color: color,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: selectedColor == color
//                                   ? Center(
//                                       child: Icon(
//                                         Icons.check,
//                                         color: Colors.white,
//                                         size: 16,
//                                       ),
//                                     )
//                                   : SizedBox(),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                       SizedBox(height: 20),
//                       Text(
//                         "Your Headshot",
//                         style: TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           GestureDetector(
//                             onTap: _pickImage,
//                             child: Container(
//                               width: 100,
//                               height: 100,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: AppColors.textColorSecond),
//                               ),
//                               child: _image == null
//                                   ? Icon(
//                                       Icons.camera_alt,
//                                       size: 40,
//                                       color: AppColors.textColorSecond,
//                                     )
//                                   : ClipOval(
//                                       child: Image.file(
//                                         _image!,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                           SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 ElevatedButton(
//                                   onPressed: _pickImage,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.transparent,
//                                     foregroundColor: AppColors.primaryColor,
//                                     elevation: 0,
//                                     side: BorderSide(color: AppColors.primaryColor),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                     minimumSize: Size(double.infinity, 40),
//                                   ),
//                                   child: Text("Upload Picture"),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   "JPG or PNG. For best presentation, should be square and at least 128px by 128px.",
//                                   style: TextStyle(
//                                     color: AppColors.textColorSecond,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 210),
//                       Center(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primaryColor,
//                             padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                             minimumSize: Size(double.infinity, 50),
//                           ),
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => HomeScreen(),
//                               ),
//                             );
//                           },
//                           child: Text(
//                             "Create Scheduling Page",
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: AppColors.backgroundColor,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),

//               // Footer fixed at bottom
//               Positioned(
//                 bottom: MediaQuery.of(context).viewInsets.bottom > 0 
//                     ? MediaQuery.of(context).viewInsets.bottom + 20 // Position above keyboard
//                     : 20,
//                 left: 0,
//                 right: 0,
//                 child: Column(
//                   children: [
//                     Text(
//                       "Privacy Policy | Terms & Conditions",
//                       style: TextStyle(
//                         color: AppColors.textColorSecond,
//                         fontSize: 12,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       "© 2025 Tabourak",
//                       style: TextStyle(
//                         color: AppColors.textColorSecond,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
