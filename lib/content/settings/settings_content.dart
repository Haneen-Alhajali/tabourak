// lib\content\settings\settings_content.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'profile_settings_content.dart';
import 'email_password_settings_content.dart';
import 'general_settings_content.dart';
import 'billing_invoices_content.dart';
import 'payments_content.dart';

class SettingsContent extends StatefulWidget {
  @override
  _SettingsContentState createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  String _selectedSection = 'My Profile';
  bool _isDropdownOpen = false;

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'My Profile',
      'icon': Icons.person_outline,
      'content': ProfileContent(),
      'category': 'Me'
    },
    {
      'title': 'Email & Password',
      'icon': Icons.lock_outline,
      'content': EmailPasswordContent(),
      'category': 'Me'
    },
    {
      'title': 'General Settings',
      'icon': Icons.settings_outlined,
      'content': GeneralSettingsContent(), 
      'category': 'Account'
    },
    {
      'title': 'Billing & Invoices',
      'icon': Icons.receipt_outlined,
      'content': BillingInvoicesContent(),  // Use the new component
      'category': 'Account'
    },
    {
      'title': 'Payments',
      'icon': Icons.payment,
      'content': PaymentsContent(),  // Use the new component
      'category': 'Integrations'
    },
  ];

  Widget _buildDropdownButton() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.mediumColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isDropdownOpen = !_isDropdownOpen;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 24,
                  color: AppColors.textColor,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedSection,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 24,
                  color: AppColors.textColorSecond,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownMenu() {
    if (!_isDropdownOpen) return SizedBox();

    // Group sections by category
    final Map<String, List<Map<String, dynamic>>> groupedSections = {};
    for (var section in _sections) {
      final category = section['category'];
      if (!groupedSections.containsKey(category)) {
        groupedSections[category] = [];
      }
      groupedSections[category]!.add(section);
    }

    return Container(
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.mediumColor),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedSections.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.key != groupedSections.keys.first)
                Divider(height: 1, color: AppColors.mediumColor),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  entry.key,
                  style: TextStyle(
                    color: AppColors.textColorSecond,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...entry.value.map((section) {
                return Material(
                  color: _selectedSection == section['title']
                      ? AppColors.lightcolor
                      : Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSection = section['title'];
                        _isDropdownOpen = false;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            section['icon'],
                            size: 20,
                            color: AppColors.textColor,
                          ),
                          SizedBox(width: 12),
                          Text(
                            section['title'],
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _getCurrentContent() {
    final selected = _sections.firstWhere(
      (section) => section['title'] == _selectedSection,
      orElse: () => _sections[0],
    );
    return selected['content'];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownButton(),
          _buildDropdownMenu(),
          SizedBox(height: 24),
          _getCurrentContent(),
        ],
      ),
    );
  }
}














// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:tabourak/colors/app_colors.dart';

// class SettingsContent extends StatefulWidget {
//   @override
//   _SettingsContentState createState() => _SettingsContentState();
// }

// class _SettingsContentState extends State<SettingsContent> {
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
//     return Container(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header Section
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "User Profile",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.textColor,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 "Your profile information is shared across all organizations you are a member of.",
//                 style: TextStyle(
//                   color: AppColors.textColorSecond,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//           Divider(
//             color: AppColors.mediumColor,
//             thickness: 1,
//             height: 24,
//           ),

//           // Form Section
//           Column(
//             children: [
//               // Name and Timezone Row
//               Column(
//                 children: [
//                   // First Name
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "First Name",
//                         style: TextStyle(
//                           color: AppColors.textColor,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       TextField(
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderSide: BorderSide(color: AppColors.mediumColor),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 10),
//                           hintText: "Enter First Name",
//                           filled: true,
//                           fillColor: AppColors.backgroundColor,
//                         ),
//                         controller: TextEditingController(text: firstName),
//                         style: TextStyle(color: AppColors.textColor),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),

//                   // Last Name
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Last Name",
//                         style: TextStyle(
//                           color: AppColors.textColor,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       TextField(
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderSide: BorderSide(color: AppColors.mediumColor),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 10),
//                           hintText: "Enter Last Name",
//                           filled: true,
//                           fillColor: AppColors.backgroundColor,
//                         ),
//                         controller: TextEditingController(text: lastName),
//                         style: TextStyle(color: AppColors.textColor),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),

//                   // Timezone
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Timezone",
//                         style: TextStyle(
//                           color: AppColors.textColor,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(color: AppColors.mediumColor),
//                           borderRadius: BorderRadius.circular(4),
//                           color: AppColors.backgroundColor,
//                         ),
//                         padding: EdgeInsets.symmetric(horizontal: 12),
//                         height: 48,
//                         child: Row(
//                           children: [
//                             Icon(Icons.public, color: AppColors.primaryColor),
//                             SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 selectedTimezone,
//                                 style: TextStyle(
//                                   color: AppColors.textColor,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                             Text(
//                               "10:12 PM",
//                               style: TextStyle(
//                                 color: AppColors.textColorSecond,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),

//                   // Language
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             "Language",
//                             style: TextStyle(
//                               color: AppColors.textColor,
//                               fontWeight: FontWeight.w500),
//                           ),
//                           SizedBox(width: 4),
//                           Icon(Icons.help_outline,
//                               size: 18, color: AppColors.textColorSecond),
//                         ],
//                       ),
//                       SizedBox(height: 4),
//                       DropdownButtonFormField<String>(
//                         value: selectedLanguage,
//                         items: ["English", "Arabic", "French"]
//                             .map(
//                               (lang) => DropdownMenuItem(
//                                 value: lang,
//                                 child: Text(
//                                   lang,
//                                   style: TextStyle(
//                                       color: AppColors.textColor, fontSize: 16),
//                                 )),
//                             )
//                             .toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             selectedLanguage = value!;
//                           });
//                         },
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderSide:
//                                 BorderSide(color: AppColors.mediumColor),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           contentPadding:
//                               EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                           filled: true,
//                           fillColor: AppColors.backgroundColor,
//                         ),
//                         icon: Icon(Icons.keyboard_arrow_down,
//                             color: AppColors.textColorSecond),
//                         style: TextStyle(color: AppColors.textColor),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),

//                   // Picture
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Picture",
//                         style: TextStyle(
//                           color: AppColors.textColor,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           GestureDetector(
//                             onTap: _pickImage,
//                             child: Stack(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 50,
//                                   backgroundImage: selectedImage != null
//                                       ? FileImage(File(selectedImage!.path))
//                                       : AssetImage(profileImageUrl)
//                                           as ImageProvider,
//                                 ),
//                                 if (selectedImage != null)
//                                   Positioned(
//                                     top: 0,
//                                     right: 0,
//                                     child: GestureDetector(
//                                       onTap: _removeImage,
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           color: AppColors.backgroundColor,
//                                           shape: BoxShape.circle,
//                                         ),
//                                         padding: EdgeInsets.all(2),
//                                         child: Icon(
//                                           Icons.close,
//                                           size: 20,
//                                           color: AppColors.textColor,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 ElevatedButton(
//                                   onPressed: _pickImage,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppColors.mediumColor,
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: 24, vertical: 12),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(4),
//                                     ),
//                                     minimumSize: Size(double.infinity, 48),
//                                   ),
//                                   child: Text(
//                                     "Change Picture",
//                                     style: TextStyle(color: AppColors.textColor),
//                                   ),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   "Click on the image or button to change",
//                                   style: TextStyle(
//                                     color: AppColors.textColorSecond,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(height: 24),

//           // Save Button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryColor,
//                 padding: EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//               child: Text(
//                 "Save Changes",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



