import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/content/pages/FormFieldApp.dart';

class MeetingDetailsPage extends StatefulWidget {
  final String title;
  final String duration;
  final String type;
  final String link;
  final int id; // Add this line

  const MeetingDetailsPage({
    required this.title,
    required this.duration,
    required this.type,
    required this.link,
    required this.id, // Add this line
  });

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  String selectedLocation = "place";
  String locationDecision = "host";

  late TextEditingController titleController;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController lengthController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  List<Map<String, dynamic>> customFields = [];

  String selectedUnit = "Minutes";
  int selectedColorIndex = 0;

  final List<Color> colorOptions = [
    Color(0xFF1C8B97),
    Colors.blueAccent,
    Colors.green,
    Colors.greenAccent,
    Colors.red,
    Colors.redAccent,
    Colors.orange,
    Colors.deepPurple,
    Colors.purpleAccent,
    Colors.yellow,
    Colors.grey,
    Colors.black,
  ];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    lengthController = TextEditingController(
      text: widget.duration.split(" ")[0],
    );
  }

  IconData getIconByName(String name) {
    switch (name) {
      case 'Text Field':
        return Icons.text_fields;

      case 'Paragraph Field':
        return Icons.notes;

      case 'Choice Field':
        return Icons.radio_button_checked;

      case 'Multiple Choice Field':
        return Icons.check_circle_outline;

      case 'Checkbox Field':
        return Icons.check_box;

      case 'Place Field':
        return Icons.place;

      case 'Date Field':
        return Icons.date_range;

      default:
        return Icons.text_fields;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),

          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),

              child: ElevatedButton.icon(
                onPressed: () {
                  print("Save Changes pressed");
                },
                label: Text(
                  "Save Changes",
                  style: TextStyle(color: AppColors.backgroundColor),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ],

          bottom: TabBar(
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Location'),
              Tab(text: 'Availability'),
              Tab(text: 'Intake Form'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  SizedBox(height: 24),

                  Text(
                    "Meeting Name",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Text(
                        "Description",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 6),
                      Tooltip(
                        message: "Write a brief description of the meeting",
                        child: Icon(Icons.help_outline, size: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Add description',
                    ),
                  ),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Text(
                        "Length",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 6),
                      Tooltip(
                        message: "How long will the meeting take?",
                        child: Icon(Icons.help_outline, size: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: lengthController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      DropdownButton<String>(
                        value: selectedUnit,
                        items:
                            ["Minutes", "Hours"]
                                .map(
                                  (unit) => DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUnit = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  Text("Color", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(colorOptions.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColorIndex = index;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: colorOptions[index],
                          radius: 14,
                          child:
                              selectedColorIndex == index
                                  ? Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // باقي التبويبات
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  locationOption(
                    icon: Icons.home,
                    title: "We'll meet at a place",
                    selected: selectedLocation == "place",
                    onTap: () => setState(() => selectedLocation = "place"),
                    child:
                        selectedLocation == "place"
                            ? Column(
                              children: [
                                RadioListTile(
                                  title: Text("I'll decide where we meet:"),
                                  value: "host",
                                  groupValue: locationDecision,
                                  onChanged: (val) {
                                    setState(() {
                                      locationDecision = val!;
                                    });
                                  },
                                ),
                                if (locationDecision == "host")
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: "Enter address",
                                        prefixIcon: Icon(Icons.location_on),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                RadioListTile(
                                  title: Text(
                                    "Attendee will decide where we meet",
                                  ),
                                  subtitle: Text(
                                    "A questionnaire field will be added to collect their location.",
                                  ),
                                  value: "attendee",
                                  groupValue: locationDecision,
                                  onChanged: (val) {
                                    setState(() {
                                      locationDecision = val!;
                                    });
                                  },
                                ),
                              ],
                            )
                            : null,
                  ),
                  SizedBox(height: 12),

                  locationOption(
                    icon: Icons.phone,
                    title: "We'll meet on a phone call",
                    selected: selectedLocation == "phone",
                    onTap: () => setState(() => selectedLocation = "phone"),
                    child:
                        selectedLocation == "phone"
                            ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: TextField(
                                controller: phoneNumberController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: "Enter phone number",
                                  prefixIcon: Icon(Icons.phone),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            )
                            : null,
                  ),

                  SizedBox(height: 12),

                  locationOption(
                    icon: Icons.videocam,
                    title: "Meet on a web conference",
                    selected: selectedLocation == "web",
                    onTap: () => setState(() => selectedLocation = "web"),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Which schedule should be used for availability?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade100,
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.calendar_today,
                        color: AppColors.accentColor,
                      ),
                      title: Text("My Availability"),
                      subtitle: Text("Weekdays, 9:00 AM - 5:00 PM"),
                      trailing: Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                  SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      // هنا يمكنكِ فتح صفحة تعديل الجدول
                      print("Edit schedule clicked");
                    },
                    child: Text(
                      "Edit schedule",
                      style: TextStyle(color: AppColors.textColor),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  intakeFieldTile(
                    icon: Icons.person_outline,
                    title: "First & Last Name",
                    subtitle: "Collected automatically",
                  ),
                  SizedBox(height: 12),
                  intakeFieldTile(
                    icon: Icons.alternate_email,
                    title: "Email Address",
                    subtitle: "Collected automatically",
                  ),

                  ...customFields.map((field) {
                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        leading: Icon(getIconByName(field['icon'])),
                        title: Text(field['label']),
                        trailing: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              customFields.remove(field);
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),

                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final newField = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateFormFieldScreen(),
                        ),
                      );

                      if (newField != null) {
                        setState(() {
                          customFields.add(newField);
                        });
                      }
                    },

                    child: Text(
                      "+ Add Another Question",
                      style: TextStyle(
                        color: AppColors.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget locationOption({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
    Widget? child,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.secondaryColor : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(10),
          color:
              selected
                  ? const Color.fromARGB(255, 235, 253, 255)
                  : Colors.white,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: selected ? AppColors.secondaryColor : Colors.black,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: AppColors.secondaryColor),
              ],
            ),
            if (child != null) SizedBox(height: 8),
            if (child != null) child,
          ],
        ),
      ),
    );
  }

  Widget intakeFieldTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey.shade700),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}