import 'package:flutter/material.dart';

class MembersContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Members",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: Icon(Icons.add),
            label: Text("Invite Members"),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            Row(
              children: [
                _buildTab("Active (1)", true),
                _buildTab("Deactivated (0)", false),
              ],
            ),
            SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  _buildMemberCard(
                    imageUrl: "assets/images/img.JPG",
                    name: "Shahd Yaseen",
                    email: "shadhabit@gmail.com",
                    role: "Owner",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    
    
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
          color: isActive ? Colors.blue : Colors.grey,
          decoration: isActive ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildMemberCard({required String imageUrl, required String name, required String email, required String role}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(imageUrl),
              radius: 25,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(email, style: TextStyle(color: Colors.blue)),
                  Text(role, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {

              },
            ),
          ],
        ),
      ),
    );
  }
}