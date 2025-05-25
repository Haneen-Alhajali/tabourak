import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tabourak/config/config.dart';
import 'package:intl/intl.dart';
import 'package:tabourak/web%20pages/BookingConfirmationApp.dart';
//import 'package:flutter_native_timezone/flutter_native_timezone.dart';

/*
void main() => runApp(FormFieldApp());

class FormFieldApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IntakeFormScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}*/

class IntakeFormScreen extends StatefulWidget {
  final int appointmentId;
  final int orgnization_id;
  final int member_id;

  final String appointmentType;
  final DateTime startTime;
  final DateTime endTime;
  final String appointmentName;
  final int duration;
  final String attendeeType;

  const IntakeFormScreen({
    super.key,
    required this.appointmentId,
    required this.appointmentType,
    required this.startTime,
    required this.endTime,
    required this.orgnization_id,
    required this.member_id,
    required this.appointmentName,
    required this.duration,
    required this.attendeeType,
  });

  @override
  State<IntakeFormScreen> createState() => _IntakeFormScreenState();
}

class _IntakeFormScreenState extends State<IntakeFormScreen> {
  Map<int, TextEditingController> textControllers = {};
  Map<int, dynamic> userAnswers = {};
  Map<int, String> fileFieldAnswers = {};
  int? meetingId;
  String emailControllertoSend = "";

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  //////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////

  Future<void> createMeetingForBooking(int user_id) async {
    //  final endTimeutc = widget.endTime.toUtc();
    //  final startTimeutc = widget.startTime.toUtc();

    print(
      "📦📦📦📦📦📦widget.endTime 📦📦📦📦📦📦" + widget.endTime.toString(),
    );
    print(
      "📦📦📦📦📦📦widget.startTime 📦📦📦📦📦📦" + widget.startTime.toString(),
    );

    /*
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final endtimetoBackend = formatter.format(endTimeutc);
    final starttimetoBackend = formatter.format(startTimeutc);*/

    final url = Uri.parse(
      '${AppConfig.baseUrl}/api/create-meeting-for-booking',
    );

    final formattedStartTime = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(widget.startTime.toUtc());
    final formattedEndTime = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(widget.endTime.toUtc());

    print("✅✅✅✅formattedStartTime ✅✅✅✅" + formattedStartTime);

    print("✅✅✅✅formattedEndTime ✅✅✅✅" + formattedEndTime);

    final Map<String, dynamic> meetingData = {
      "appointment_id": widget.appointmentId,
      "staff_id": widget.member_id,
      "user_info_id": user_id,
      "organization_id": widget.orgnization_id,
      "start_time": formattedStartTime,
      "end_time": formattedEndTime,
      "timezone": "Asia/Riyadh",
    };

    print("✅✅✅✅✅✅✅✅✅✅✅✅");
    print(meetingData);
    print("✅✅✅✅✅✅✅✅✅✅✅✅");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(meetingData),
      );

      if (response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        setState(() {
          meetingId = decoded['meeting_id'];
        });
        print('✅ الاجتماع تم حفظه بنجاح، Meeting ID: $meetingId');
      } else {
        print('❌ فشل في حفظ الاجتماع: ${response.body}');
      }
    } catch (e) {
      print('⚠️ حصل خطأ: $e');
    }
  }

  ////////////////////////////////////////////////////////////////////////
  List<dynamic> fields = [];
  bool isLoading = true;

  late String timezone = "UTC";

  @override
  void initState() {
    super.initState();
    fetchFields();
  }

  void fetchFields() async {
    final response = await http.get(
      Uri.parse(
        '${AppConfig.baseUrl}/api/custom-fields/${widget.appointmentId}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      data.sort(
        (a, b) =>
            (a['display_order'] as int).compareTo(b['display_order'] as int),
      );

      setState(() {
        fields = data;
        isLoading = false;
      });

      print(
        "🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴fields  " + fields.toString(),
      );
    } else {
      // Handle error
      print("Failed to fetch fields");
    }
  }
  ///////////////////////////////////////////////////////////////////

  Future<void> uploadFileForField(
    int fieldId,
    int userId,
    String pathFile,
  ) async {
    //  int meetingId = 1;
    //  int userId = 1;
    print("♻️♻️♻️♻️userId" + userId.toString());
    final uri = Uri.parse('${AppConfig.baseUrl}/api/upload-file-response');

    final request =
        http.MultipartRequest('POST', uri)
          ..fields['field_id'] = fieldId.toString()
          ..fields['meeting_id'] = meetingId.toString()
          ..fields['user_id'] = userId.toString()
          ..files.add(await http.MultipartFile.fromPath('file', pathFile));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final jsonResp = jsonDecode(respStr);
      final uploadedUrl = jsonResp['file_url'];

      setState(() {
        fileFieldAnswers[fieldId] = uploadedUrl;
      });

      print("📄 تم رفع الملف لحقل $fieldId: $uploadedUrl");
    } else {
      print("❌ فشل رفع الملف");
    }
  }

  //////////////////////////////////////////////////////////////////
  Future<void> submitSingleAnswer({
    required int userId,
    required int fieldId,
    required String responseText,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/custom-field-response');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'meeting_id': meetingId,
        'field_id': fieldId,
        'response_text': responseText,
      }),
    );

    if (response.statusCode == 201) {
      print('✅ تم إرسال إجابة الحقل $fieldId بنجاح');
    } else {
      print('❌ فشل في إرسال الحقل $fieldId: ${response.body}');
    }
  }
  /////////////////////////////////////////////////////////////////////////////////////////////

  Future<int?> submitUserInfo() async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/intake-form-user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'email': emailController.text.trim(),
      }),
    );

    emailControllertoSend = emailController.text.toString();
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['user_info_id'];
    } else {
      print('Failed to create user: ${response.body}');
      return null;
    }
  }

  ///////////////////////////////////////////////////////////////////////////////////////////
  String selectedRadio = 'Choice 1';
  List<String> selectedCheckboxes = ['Choice 1', 'Choice 2'];
  bool saveForNextTime = false;
  bool singleCheckbox = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedPdfFileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Form"), leading: Icon(Icons.assignment)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildFixedTextField(
                "First Name",
                "Your given name",
                controller: firstNameController,
              ),
              buildSeparator(),
              buildFixedTextField(
                "Last Name",
                "Your family name",
                controller: lastNameController,
              ),
              buildSeparator(),
              buildFixedTextField(
                "Email",
                "We'll never share your email",
                controller: emailController,
              ),
              buildSeparator(),

              if (isLoading) CircularProgressIndicator(),
              ...fields.map((field) => buildFieldFromData(field)).toList(),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final userId = await submitUserInfo();
                  //  print("💡💡💡💡💡" + userId.toString());

                  if (userId == null) {
                    print("❌ Failed to create user. Aborting form submission.");
                    return;
                  }

                  await createMeetingForBooking(userId);

                  //print("📦📦📦📦 userId 📦📦📦📦 ${userId.toString()}");
                  /*  print(  "📦📦📦📦 userAnswers 📦📦📦📦 ${userAnswers.toString()}",  );*/

                  for (var entry in userAnswers.entries) {
                    final fieldId = entry.key;
                    final rawValue = entry.value;

                    String stringValue;

                    if (rawValue is DateTime) {
                      stringValue = rawValue.toIso8601String();
                    } else if (rawValue is TimeOfDay) {
                      stringValue = rawValue.format(context);
                    } else {
                      stringValue = rawValue.toString();
                    }

                    await submitSingleAnswer(
                      userId: userId,
                      fieldId: fieldId,
                      responseText: stringValue,
                    );
                  }

                  for (var entry in fileFieldAnswers.entries) {
                    final fieldId = entry.key;
                    /*  print(  "♻️♻️♻️♻️♻️♻️♻️♻️entry.key♻️♻️♻️♻️♻️♻️♻️" +entry.key.toString(),  );
                    print(  "📦📦📦📦📦📦📦📦entry.value📦📦📦📦📦📦📦📦" +entry.value.toString(),  );*/

                    await uploadFileForField(fieldId, userId, entry.value);
                  }

                  print("✅✅✅ تم إرسال كل الإجابات");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BookingConfirmationScreen(
                            appointmentId: widget.appointmentId,
                            appointmentType: widget.appointmentType,
                            startTime: widget.startTime,
                            endTime: widget.endTime,
                            appointmentName: widget.appointmentName,
                            emailController: emailControllertoSend,
                            member_id: widget.member_id,
                            userId: userId,
                            duration: widget.duration,
                            attendeeType: widget.attendeeType,
                            meetingId: meetingId,
                          ),
                    ),
                  );
                },
                child: Text("Submit"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  foregroundColor: AppColors.backgroundColor,
                  backgroundColor: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    int fieldId,
    String label,
    String helpText, {
    bool isMultiline = false,
    IconData? prefixIcon,
  }) {
    if (!textControllers.containsKey(fieldId)) {
      textControllers[fieldId] = TextEditingController();
      textControllers[fieldId]!.addListener(() {
        userAnswers[fieldId] = textControllers[fieldId]!.text;
      });
    }
    final controller = textControllers[fieldId]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          TextFormField(
            controller: controller,
            cursorColor: AppColors.textColorSecond,
            maxLines: isMultiline ? 3 : 1,
            decoration: InputDecoration(
              prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.textColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            helpText,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget buildFixedTextField(
    String label,
    String helpText, {
    bool isMultiline = false,
    IconData? prefixIcon,
    required TextEditingController controller, // 🟢 أضفنا هذا
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          TextFormField(
            controller: controller, // 🟢 هنا
            cursorColor: AppColors.textColorSecond,
            maxLines: isMultiline ? 3 : 1,
            decoration: InputDecoration(
              prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.textColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            helpText,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget buildRadioGroup(int fieldId, String label, List<String> options) {
    if (!userAnswers.containsKey(fieldId)) {
      userAnswers[fieldId] = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        ...options.map(
          (option) => RadioListTile<String>(
            activeColor: AppColors.primaryColor,
            value: option,
            groupValue: userAnswers[fieldId],
            onChanged: (value) {
              setState(() {
                userAnswers[fieldId] = value;
                print(
                  "🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯  choice is $fieldId: $value",
                );
              });
            },
            title: Text(option),
          ),
        ),
      ],
    );
  }

  Widget buildCheckboxGroupWithHelp(
    int fieldId,
    String label,
    List<Map<String, dynamic>> options,
  ) {
    if (!userAnswers.containsKey(fieldId)) {
      userAnswers[fieldId] = <String>[];
    }

    List<String> selectedValues = List<String>.from(userAnswers[fieldId]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...options.map((option) {
          final optionValue = option['option_value'];
          final helpText = option['help_text'] ?? '';

          return CheckboxListTile(
            activeColor: AppColors.primaryColor,
            value: selectedValues.contains(optionValue),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedValues.add(optionValue);
                } else {
                  selectedValues.remove(optionValue);
                }

                userAnswers[fieldId] = selectedValues;

                //  print("✅ تم تحديث قيم checkbox لحقل $fieldId: $selectedValues");
              });
            },
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(optionValue),
                if (helpText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      helpText,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
              ],
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  Widget buildCheckboxField(int fieldId, String label, String helpText) {
    if (!userAnswers.containsKey(fieldId)) {
      userAnswers[fieldId] = false;
    }

    bool isChecked = userAnswers[fieldId] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          activeColor: AppColors.primaryColor,
          value: isChecked,
          onChanged: (value) {
            setState(() {
              userAnswers[fieldId] = value ?? false;
              print(
                "✅ تم تحديث قيمة single checkbox لحقل $fieldId: ${userAnswers[fieldId]}",
              );
            });
          },
          title: Text(label),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            helpText,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget buildDatePickerField(int fieldId, String label, String helpText) {
    DateTime? selectedDate = userAnswers[fieldId];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          GestureDetector(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  selectedDate = pickedDate;
                  userAnswers[fieldId] = pickedDate;
                  print(
                    "📅 تم اختيار تاريخ لحقل $fieldId: ${userAnswers[fieldId]}",
                  );
                });
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                selectedDate != null
                    ? "${selectedDate.month}/${selectedDate.day}/${selectedDate.year}"
                    : "Select a date",
                style: TextStyle(
                  color:
                      selectedDate != null
                          ? Colors.black
                          : Colors.grey.shade600,
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            helpText,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget buildTimePickerField(int fieldId, String label, String helpText) {
    TimeOfDay? selectedTime = userAnswers[fieldId];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          GestureDetector(
            onTap: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: selectedTime ?? TimeOfDay.now(),
              );
              if (pickedTime != null) {
                setState(() {
                  selectedTime = pickedTime;
                  userAnswers[fieldId] = pickedTime;
                  print(
                    "⏰ تم اختيار وقت لحقل $fieldId: ${userAnswers[fieldId]}",
                  );
                });
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                selectedTime != null
                    ? selectedTime.format(context)
                    : "Select a time",
                style: TextStyle(
                  color:
                      selectedTime != null
                          ? Colors.black
                          : Colors.grey.shade600,
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            helpText,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget buildFilePickerField(int fieldId, String label, String helpText) {
    String? fileUrl = fileFieldAnswers[fieldId];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          fileUrl == null
              ? GestureDetector(
                onTap: () async {
                  final XFile? file = await openFile();

                  if (file != null) {
                    setState(() {
                      fileFieldAnswers[fieldId] = file.path;
                    });
                  }
                },

                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_file, size: 30, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          "Click to upload a file to this area.",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      size: 28,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "File uploaded",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tap the X to remove it",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey.shade600),
                      onPressed: () {
                        setState(() {
                          fileFieldAnswers.remove(fieldId);
                        });
                      },
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 4),
          Text(
            helpText,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget buildFieldFromData(dynamic field) {
    String type = field['type'];
    String label = field['label'] ?? "Label";
    String helpText = field['help_text'] ?? "";
    List options = field['options'] ?? [];
    int fieldID = field['field_id'] ?? 0;
    switch (type) {
      case 'text':
        return Column(
          children: [
            buildTextField(fieldID, label, helpText),
            buildSeparator(),
          ],
        );
      case 'textarea':
        return Column(
          children: [
            buildTextField(fieldID, label, helpText, isMultiline: true),
            buildSeparator(),
          ],
        );
      case 'radio':
        return Column(
          children: [
            buildRadioGroup(
              fieldID,
              label,
              options.map<String>((e) => e['option_value']).toList(),
            ),
            buildSeparator(),
          ],
        );

      case 'checkbox':
        if (options.isNotEmpty) {
          return Column(
            children: [
              buildCheckboxGroupWithHelp(
                fieldID,
                label,
                List<Map<String, dynamic>>.from(options),
              ),

              buildSeparator(),
            ],
          );
        } else {
          return Column(
            children: [
              buildCheckboxField(fieldID, label, helpText),
              buildSeparator(),
            ],
          );
        }

      case 'dropdown':
        if (options.isNotEmpty) {
          return Column(
            children: [
              buildCheckboxGroupWithHelp(
                fieldID,
                label,
                List<Map<String, dynamic>>.from(options),
              ),

              buildSeparator(),
            ],
          );
        } else {
          return Column(
            children: [
              buildCheckboxField(fieldID, label, helpText),
              buildSeparator(),
            ],
          );
        }

      case 'place':
        return Column(
          children: [
            buildTextField(fieldID, label, helpText, prefixIcon: Icons.search),
            buildSeparator(),
          ],
        );
      case 'date':
        return Column(
          children: [
            buildDatePickerField(fieldID, label, helpText),
            buildSeparator(),
          ],
        );

      case 'time':
        return Column(
          children: [
            buildTimePickerField(fieldID, label, helpText),
            buildSeparator(),
          ],
        );
      case 'file':
        return Column(
          children: [
            buildFilePickerField(fieldID, label, helpText),
            buildSeparator(),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

  Widget buildSeparator() {
    return Divider(color: AppColors.primaryColor, thickness: 1, height: 32);
  }
}
