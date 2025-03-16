import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';

class SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSettingItem(title: 'Page Title', value: 'Meet with Yasmine Ro'),
        Divider(),
        _buildSettingItem(
          title: 'Page URL',
          value: 'https://appt.link/meet-with-yasmine-ro-yUnB9Oqn',
        ),
        Divider(),
        _buildSettingItem(
          title: 'Welcome Message',
          value: 'No welcome message provided.',
        ),
        Divider(),
        _buildImageUploadSection(),
        Divider(),
        _buildSettingItem(title: 'Language', value: 'English'),
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
              Text(title, style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.textColor)),
              SizedBox(height: 4),
              Text(
                value,
                softWrap: true, 
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
        TextButton(onPressed: () {}, child: Text('Edit',style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.textColorSecond))),
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
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/a/ACg8ocJAQC0fAmGjJI69Gu6m5-EuRhxJDIlgOj6E0lZxiH24QDKTKA=s96-c',
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                      style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mediumColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
                    child: Text('Upload Picture',style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.textColor)),
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
