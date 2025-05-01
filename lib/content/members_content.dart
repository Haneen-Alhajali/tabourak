import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';

class MembersContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          color: AppColors.backgroundColor,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Members",
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.lightcolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(Icons.add),
                    label: Text("Invite Members"),
                  ),
                ],
              ),
              Divider(height: 1, color: Colors.grey[300]),
              SizedBox(height: 16),

              Row(
                children: [
                  _buildTab("Active (1)", true),
                  _buildTab("Deactivated (0)", false),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),

        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.6,
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildMemberCard(
                imageUrl: "images/img.JPG",
                name: "Shahd Yaseen",
                email: "shadhabit@gmail.com",
                role: "Owner",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.textColor : AppColors.textColorSecond,
          decoration: isActive ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildMemberCard({
    required String imageUrl,
    required String name,
    required String email,
    required String role,
  }) {
    return Card(
      color: AppColors.mediumColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage(imageUrl), radius: 25),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(email, style: TextStyle(color: AppColors.secondaryColor)),
                  Text(role, style: TextStyle(color: AppColors.textColorSecond)),
                ],
              ),
            ),
            IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
