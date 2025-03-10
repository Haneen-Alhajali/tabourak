import 'package:flutter/material.dart';

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.blue),
            SizedBox(width: 8),
            Text("My Profile", style: TextStyle(color: Colors.black)),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.arrow_drop_down, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "User Profile",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "Your profile information is shared across all organizations you are a member of.",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              
              Text("First Name"),
              SizedBox(height: 4),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter First Name",
                ),
                controller: TextEditingController(text: firstName),
              ),
              SizedBox(height: 12),

              Text("Last Name"),
              SizedBox(height: 4),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter Last Name",
                ),
                controller: TextEditingController(text: lastName),
              ),
              SizedBox(height: 12),

              Text("Timezone"),
              SizedBox(height: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.public, color: Colors.blue),
                title: Text(selectedTimezone),
                trailing: Text(
                  "10:12 PM",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {},
              ),
              SizedBox(height: 12),

              Text("Language"),
              SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: selectedLanguage,
                items: ["English", "Arabic", "French"]
                    .map((lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(lang),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLanguage = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),

              Text("Picture"),
              SizedBox(height: 8),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(profileImageUrl),
                ),
              ),
              SizedBox(height: 16),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text("Save Changes", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
