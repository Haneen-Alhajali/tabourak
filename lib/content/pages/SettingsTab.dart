import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tabourak/colors/app_colors.dart';

class SettingsTab extends StatefulWidget {
  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  File? _selectedImage;
  Map<String, String> settings = {
    'Page Title': 'Meet with Yasmine Ro',
    'Page URL': 'https://appt.link/meet-with-yasmine-ro-yUnB9Oqn',
    'Welcome Message': 'No welcome message provided.',
    'Language': 'English',
  };

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
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
              },
              child: Text('Save', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
            CircleAvatar(
              radius: 40,
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : NetworkImage('https://lh3.googleusercontent.com/a/ACg8ocJAQC0fAmGjJI69Gu6m5-EuRhxJDIlgOj6E0lZxiH24QDKTKA=s96-c') as ImageProvider,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mediumColor,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Upload Picture', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColor)),
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
}