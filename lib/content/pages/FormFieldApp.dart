import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';

void main() => runApp(FormFieldApp());

class FormFieldApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CreateFormFieldScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CreateFormFieldScreen extends StatefulWidget {
  @override
  _CreateFormFieldScreenState createState() => _CreateFormFieldScreenState();
}

class _CreateFormFieldScreenState extends State<CreateFormFieldScreen> {
  String selectedFieldType = 'Text Field';
  final List<String> fieldTypes = [
    'Text Field',
    'Paragraph Field',
    'Choice Field',
    'Multiple Choice Field',
    'Checkbox Field',
    'Place Field',
    'Date Field',
  ];

  final labelController = TextEditingController();
  final helpTextController = TextEditingController();
  final List<TextEditingController> choiceControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  bool isRequired = false;
  String selectedIconName = 'person';

  IconData _getIcon(String type) {
    switch (type) {
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

  Widget _buildChoicesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        ...choiceControllers.map(
          (controller) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Choice",
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Create Form Field'),
        backgroundColor: AppColors.mediumColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: selectedFieldType,
                decoration: InputDecoration(
                  labelText: 'What type of field should this be?',
                  labelStyle: TextStyle(color: AppColors.textColor),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                items:
                    fieldTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(_getIcon(type), size: 20),
                            SizedBox(width: 8),
                            Text(type),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFieldType = value!;
                    selectedIconName = value;
                  });
                },
              ),
              SizedBox(height: 20),
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  labelText: "Label",
                  border: OutlineInputBorder(),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: isRequired,
                    onChanged: (val) {
                      setState(() {
                        isRequired = val!;
                      });
                    },
                  ),
                  Text("Required (must be populated)"),
                ],
              ),
              TextField(
                controller: helpTextController,
                decoration: InputDecoration(
                  labelText: "Help Text (Optional)",
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
              if (selectedFieldType == 'Choice Field' ||
                  selectedFieldType == 'Multiple Choice Field')
                _buildChoicesInput(),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: AppColors.textColor),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    onPressed: () {
                      final field = {
                        'label': labelController.text,
                        'type': selectedFieldType,
                        'isRequired': isRequired,
                        'icon': selectedIconName,
                      };

                      Navigator.pop(context, field);
                    },

                    child: Text(
                      "Create Form Field",
                      style: TextStyle(color: AppColors.backgroundColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}