import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tabourak/screens/home_screen.dart';
import 'dart:io';
import '../../colors/app_colors.dart';

class SchedulingPage extends StatefulWidget {
  @override
  _SchedulingPageState createState() => _SchedulingPageState();
}

class _SchedulingPageState extends State<SchedulingPage> {
  TextEditingController _titleController = TextEditingController();
  Color selectedColor = Colors.blue;
  File? _image;

  final List<Color> colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.lightGreen,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.grey,
  ];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tabourak"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Finally, Let’s Make it Yours",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Personalize your scheduling page to match your brand and style.",
            ),
            SizedBox(height: 20),
            Text("Your Scheduling Page’s Title"),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Enter title",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text("Color Scheme"),
            SizedBox(height: 8),
            Wrap(
              children:
                  colorOptions.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(4),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border:
                              selectedColor == color
                                  ? Border.all(width: 3, color: Colors.black)
                                  : null,
                        ),
                      ),
                    );
                  }).toList(),
            ),
            SizedBox(height: 20),
            Text("Your Headshot"),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child:
                  _image == null
                      ? Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.textColorSecond),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: AppColors.textColorSecond,
                        ),
                      )
                      : CircleAvatar(
                        radius: 50,
                        backgroundImage: FileImage(_image!),
                      ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 500),
                      pageBuilder: (_, __, ___) => HomeScreen(),
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(1, 0),
                            end: Offset(0, 0),
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Text(
                  "Create Scheduling Page",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.backgroundColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
