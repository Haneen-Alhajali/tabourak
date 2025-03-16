import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:tabourak/colors/app_colors.dart';

class SettingsContent extends StatefulWidget {
  @override
  _SettingsContentState createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  String firstName = "Shahd";
  String lastName = "Yaseen";
  String selectedLanguage = "English";
  String selectedTimezone = "Asia / Jerusalem";
  String profileImageUrl = "assets/images/img.JPG";
  XFile? selectedImage;

  @override
  Widget build(BuildContext context) {
    return Column(
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
          style: TextStyle(color: AppColors.textColorSecond),
        ),
        SizedBox(height: 16),

        Text("First Name", style: TextStyle(color: AppColors.textColor)),
        SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter First Name",
          ),
          controller: TextEditingController(text: firstName),
          style: TextStyle(color: AppColors.textColor),
        ),
        SizedBox(height: 12),

        Text("Last Name", style: TextStyle(color: AppColors.textColor)),
        SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter Last Name",
          ),
          controller: TextEditingController(text: lastName),
          style: TextStyle(color: AppColors.textColor),
        ),
        SizedBox(height: 12),

        Text("Timezone", style: TextStyle(color: AppColors.textColor)),
        SizedBox(height: 4),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.public, color: AppColors.primaryColor),
          title: Text(selectedTimezone),
          trailing: Text(
            "10:12 PM",
            style: TextStyle(color: AppColors.textColor),
          ),
          onTap: () {},
        ),
        SizedBox(height: 12),

        Text("Language", style: TextStyle(color: AppColors.textColor)),
        SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: selectedLanguage,
          items:
              ["English", "Arabic", "French"]
                  .map(
                    (lang) => DropdownMenuItem(
                      value: lang,
                      child: Text(
                        lang,
                        style: TextStyle(color: AppColors.textColor),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            setState(() {
              selectedLanguage = value!;
            });
          },
          decoration: InputDecoration(border: OutlineInputBorder()),
        ),
        SizedBox(height: 12),

        Text("Picture", style: TextStyle(color: AppColors.textColor)),
        SizedBox(height: 8),
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage:
                    selectedImage != null
                        ? FileImage(File(selectedImage!.path))
                        : AssetImage(profileImageUrl) as ImageProvider,
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      selectedImage = image;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mediumColor,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  "Change Picture",
                  style: TextStyle(color: AppColors.textColor),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),

        Center(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mediumColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              "Save Changes",
              style: TextStyle(color: AppColors.textColor),
            ),
          ),
        ),
      ],
    );
  }
}
