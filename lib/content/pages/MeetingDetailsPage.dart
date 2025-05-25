import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/config/config.dart';
import 'package:tabourak/content/pages/FormFieldApp.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tabourak/content/pages/UpdateFormApp.dart';

class MeetingDetailsPage extends StatefulWidget {
  final String title;
  final String duration;
  final String type;
  final String link;

  const MeetingDetailsPage({
    required this.title,
    required this.duration,
    required this.type,
    required this.link,
  });

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  final appointmentId = "17";

  /////////////////////////////delete Fields from databaze

  Future<void> deleteFieldFromDatabase(int fieldId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/custom-fields/$fieldId');

    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete field from database');
    }
  }

  ////////////////////////////////////////
  ///////////////////////////// for ordering

  Future<void> updateFieldOrderInDatabase(int fieldId, int newOrder) async {
    final url = Uri.parse(
      '${AppConfig.baseUrl}/api/custom-fields/order/$fieldId',
    );
    print('📡 PATCH → $url with order=$newOrder');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'display_order': newOrder}),
    );

    print('📥 Response (${response.statusCode}): ${response.body}');

    if (response.statusCode != 200) {
      print('❌ فشل تحديث الترتيب: ${response.body}');
      throw Exception('Failed to update field order');
    } else {
      print('✅ ترتيب الحقل $fieldId تم تحديثه إلى $newOrder');
    }
  }

  /////////////////////////////////////

  ///////////////////////// get Fields from databaze

  Future<void> fetchExistingFields(int appointmentId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/custom-fields/$appointmentId'),
    );
    print('📡 جلب الحقول من الباك للـ meetingId = $appointmentId');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final sortedFields = List<Map<String, dynamic>>.from(data)..sort(
        (a, b) => (a['display_order'] ?? 0).compareTo(b['display_order'] ?? 0),
      );

      setState(() {
        existingFields = sortedFields;
        allFields = [...existingFields, ...customFields];
      });
    } else {
      print('❌ Failed to load fields');
    }
  }

  //////////////////////////////////////
  /////////////////////////converter of type field
  String? convertFieldType(String? rawType) {
    final typeMap = {
      'Text Field': 'text',
      'Paragraph Field': 'textarea',
      'Dropdown Field': 'dropdown',
      'Multiple Choice Field': 'multiple_choice',
      'Choice Field': 'radio',
      'Checkbox Field': 'checkbox',
      'Place Field': 'place',
      'Date Field': 'date',
      'Time Field': 'time',
      'Upload File': 'file',
    };
    //    type ENUM('text','textarea','dropdown','checkbox','radio','place','date','time') NOT NULL,

    return typeMap[rawType?.trim()];
  }

  //for  customFields
  /////////////////////////////////////////
  Future<void> saveCustomFields(int appointmentId) async {
    for (var field in customFields) {
      print(
        "🔴🔴🔴🔴🔴✅✅✅✅✅✅✅✅✅✅✅✅customFields  ✅✅✅✅✅✅✅✅✅✅✅✅🔴🔴🔴🔴🔴 " +
            customFields.toString(),
      );
      print(
        "🔴🔴🔴🔴🔴✅✅✅✅✅✅✅✅✅✅✅✅allFields.length✅✅✅✅✅✅✅✅✅✅✅✅🔴🔴🔴🔴🔴 " +
            allFields.length.toString(),
      );

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/custom-fields'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "appointment_id": appointmentId,
          "label": field['label'],
          "type": convertFieldType(field['type']),
          "is_required": field['is_required'] ?? false,
          "help_text": field['help_text'] ?? null,
          "display_order": allFields.length,
          "default_value": field['default_value'] ?? null,
          "options":
              field['options'] is List<String>
                  ? field['options']
                  : (field['options'] is List
                      ? List<String>.from(
                        field['options'].map((e) => e.toString()),
                      )
                      : []),
        }),
      );

      if (response.statusCode == 201) {
        //    allFields = [...existingFields, ...customFields];
        print("saveed successfully ${field['label']}");
      } else {
        print("error in save ${response.body}");
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////////////
  Future<void> fetchAppointmentDetails() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/appointment/$appointmentId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final message = data['message'];

      setState(() {
        if (message == 'Meeting type: Zoom video call') {
          selectedLocation = 'web';
        } else if (message == 'Phone call meeting') {
          selectedLocation = 'phone';
          phoneNumberController.text = data['phone'] ?? '';
        } else if (message ==
            'Phone number not provided for phone call meeting.') {
          selectedLocation = 'phone';
          phoneNumberController.clear();
        } else if (message == 'In-person meeting at the following location') {
          selectedLocation = 'place';
          locationDecision = 'host';
          locationController.text = data['location'] ?? '';
        } else if (message == 'Location not provided for in-person meeting.') {
          selectedLocation = 'none';
          locationDecision = 'none';
          locationController.clear();
        } else {
          // Default fallback
          selectedLocation = 'none';
        }
      });
    } else {
      print('Failed to fetch appointment details');
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<void> updateAppointmentDetails() async {
    final url = Uri.parse(
      '${AppConfig.baseUrl}/api/appointment/$appointmentId',
    );

    Map<String, dynamic> body = {};

    if (selectedLocation == "web") {
      body = {"meeting_type": "video_call"};
    } else if (selectedLocation == "phone") {
      body = {
        "meeting_type": "phone_call",
        "meeting_phone": phoneNumberController.text,
      };
    } else if (selectedLocation == "place") {
      body = {
        "meeting_type": "in_person",
        "location": locationDecision == "host" ? locationController.text : "",
      };
    } else {
      body = {"meeting_type": "in_person"};
    }

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment updated successfully')),
      );
    } else {
      print("Failed to update appointment: ${response.body}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update appointment')));
    }
  }

  String locationDecision = "host";
  String selectedLocation = "";

  late TextEditingController titleController;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController lengthController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  List<Map<String, dynamic>> existingFields = [];
  List<Map<String, dynamic>> customFields = [];
  late List<Map<String, dynamic>> allFields;

  String selectedUnit = "Minutes";
  int selectedColorIndex = 0;

  final List<Color> colorOptions = [
    Colors.blue,
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
    fetchAppointmentDetails();
    fetchExistingFields(17);

    allFields = [...existingFields, ...customFields];
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

      case 'Time Field':
        return Icons.access_time;

      case 'Upload File':
        return Icons.upload_file;

      // data baze
      case 'text':
        return Icons.text_fields;

      case 'textarea':
        return Icons.notes;

      case 'dropdown':
        return Icons.arrow_drop_down_circle;

      case 'checkbox':
        return Icons.check_box;

      case 'radio':
        return Icons.radio_button_checked;

      case 'place':
        return Icons.place;

      case 'date':
        return Icons.date_range;

      case 'time':
        return Icons.access_time;

      case 'file':
        return Icons.upload_file;

      case 'multiple_choice':
        return Icons.check_circle_outline;

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
                onPressed: () async {
                  //  await saveCustomFields(int.parse(appointmentId));

                  //    customFields = [];
                  allFields = [...existingFields, ...customFields];

                  print(
                    " ✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅ allFields = [...existingFields,..];   " +
                        allFields.toString(),
                  );

                  await updateAppointmentDetails();
                  customFields = [];
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

            //// location
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  locationOption(
                    icon: Icons.not_listed_location,
                    title: "No location specified",
                    selected: selectedLocation == "none",
                    onTap: () => setState(() => selectedLocation = "none"),
                  ),
                  SizedBox(height: 12),

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
                                      controller: locationController,
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
            ///////////////////////////////////////////////////////
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

            SingleChildScrollView(
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
                  SizedBox(height: 16),

                  // dynamic data
                  ReorderableListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),

                    onReorder: (oldIndex, newIndex) {
                      print(
                        "💡💡💡💡💡💡💡💡💡oldIndex " +
                            oldIndex.toString() +
                            "💡💡💡💡💡💡💡💡💡newIndex" +
                            newIndex.toString(),
                      );
                      if (newIndex > oldIndex) newIndex -= 1;
                      setState(() {
                        final item = allFields.removeAt(oldIndex);
                        allFields.insert(newIndex, item);
                        print(
                          "💡♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️💡allFields reorder " +
                              allFields.toString(),
                        );

                        for (int i = 0; i < allFields.length; i++) {
                          final field = allFields[i];
                          if (field.containsKey('field_id')) {
                            updateFieldOrderInDatabase(field['field_id'], i);

                            print(
                              "📦📦📦📦updateFieldOrderInDatabase(field['field_id'], i); 📦📦📦📦" +
                                  allFields.toString(),
                            );
                          }
                        }
                      });
                    },

                    /*  onReorder: (oldIndex, newIndex) {                
                      if (newIndex > oldIndex) newIndex -= 1;
                      setState(() {
                        final item = allFields.removeAt(oldIndex);
                        allFields.insert(newIndex, item);
                      });

                      for (int i = 0; i < allFields.length; i++) {
                        final field = allFields[i];
                        if (field.containsKey('field_id')) {
                          updateFieldOrderInDatabase(field['field_id'], i);
                        }
                      }
                    },*/
                    //ork
                    ////////////////////////////////

                    /////////////////////////////////////////
                    /*  onReorder: (oldIndex, newIndex) async {
                      if (newIndex > oldIndex) newIndex -= 1;
                      setState(() {
                        final item = allFields.removeAt(oldIndex);
                        allFields.insert(newIndex, item);
                      });

                      for (int i = 0; i < allFields.length; i++) {
                        final field = allFields[i];
                        if (field.containsKey('field_id')) {
                          await updateFieldOrderInDatabase(
                            field['field_id'],
                            i,
                          );
                      //    await fetchExistingFields(1);
                        }
                      }              
                    },*/
                    children: List.generate(allFields.length, (index) {
                      final field = allFields[index];
                      return Card(
                        key: ValueKey(field['field_id'] ?? field['label']),
                        color: Colors.white,
                        child: ListTile(
                          leading: Icon(
                            getIconByName(
                              field['icon'] ?? field['type'] ?? 'question_mark',
                            ),
                          ),
                          title: Text(field['label']),
                          trailing: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () async {
                              if (field.containsKey('field_id')) {
                                await deleteFieldFromDatabase(
                                  field['field_id'],
                                );
                                setState(() {
                                  allFields.remove(field);
                                });
                              } else {
                                setState(() {
                                  allFields.remove(field);
                                });
                              }
                            },
                          ),
                          onTap: () async {
                            if (field['field_id'] != null) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => UpdateFormFieldScreen(
                                        fieldId: field['field_id'],
                                      ),
                                ),
                              );
                              await fetchExistingFields(17);
                            }
                          },
                        ),
                      );
                    }),
                  ),

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
                          saveCustomFields(int.parse(appointmentId));
                          customFields = [];
                          fetchExistingFields(17);
                          allFields = [...existingFields, ...customFields];
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

            /*
   ReorderableListView(
    padding: const EdgeInsets.all(16.0),
    onReorder: (oldIndex, newIndex) async {
      if (newIndex > oldIndex) newIndex -= 1;

      setState(() {
        final item = allFields.removeAt(oldIndex);
        allFields.insert(newIndex, item);
      });

      // بعد التغيير، احفظ الترتيب الجديد في قاعدة البيانات
      for (int i = 0; i < allFields.length; i++) {
        final field = allFields[i];
        if (field.containsKey('field_id')) {
        //  await updateFieldOrderInDatabase(field['field_id'], i); // ارسلي الترتيب الجديد
        }
      }
    },
    children: List.generate(allFields.length, (index) {
      final field = allFields[index];
      return Card(
        key: ValueKey(field['field_id'] ?? field['label']),
        color: Colors.white,
        child: ListTile(
          leading: Icon(getIconByName(field['icon'] ?? field['type'] ?? 'question_mark')),
          title: Text(field['label']),
          trailing: IconButton(
            icon: Icon(Icons.close),
            onPressed: () async {
              if (field.containsKey('field_id')) {
                await deleteFieldFromDatabase(field['field_id']);
                setState(() {
                  allFields.remove(field);
                });
              } else {
                setState(() {
                  allFields.remove(field);
                });
              }
            },
          ),
          onTap: () async {
            if (field['field_id'] != null) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UpdateFormFieldScreen(fieldId: field['field_id']),
                ),
              );
              await fetchExistingFields(1); // جلب الحقول من جديد
            }
          },
        ),
      );
    }),
  ),
*/

            /*
            SingleChildScrollView(
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

                  ...[...existingFields, ...customFields].map((field) {
                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        leading: Icon(
                          getIconByName(
                            field['icon'] ?? field['type'] ?? 'question_mark',
                          ),
                        ),
                        title: Text(field['label']),
                        trailing: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () async {
                            if (field.containsKey('field_id')) {
                              try {
                                await deleteFieldFromDatabase(
                                  field['field_id'],
                                );
                                setState(() {
                                  existingFields.remove(field);
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error deleting field: $e'),
                                  ),
                                );
                              }
                            } else {
                              setState(() {
                                customFields.remove(field);
                              });
                            }
                          },
                        ),
                        onTap: () async {
                          if (field['field_id'] != null) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => UpdateFormFieldScreen(
                                      fieldId: field['field_id'],
                                    ),
                              ),
                            );
                            await fetchExistingFields(1);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "This field hasn't been saved yet.",
                                ),
                              ),
                            );
                          }
                        },
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
            ),*/
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
