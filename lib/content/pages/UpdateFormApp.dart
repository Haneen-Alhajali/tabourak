import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tabourak/config/config.dart';

/*
void main() => runApp(
  MaterialApp(
    home: UpdateFormFieldScreen(),
    debugShowCheckedModeBanner: false, //
  ),
);
*/
class UpdateFormFieldScreen extends StatefulWidget {
  final int fieldId;

  UpdateFormFieldScreen({required this.fieldId});

  @override
  _UpdateFormFieldScreenState createState() => _UpdateFormFieldScreenState();
}

class _UpdateFormFieldScreenState extends State<UpdateFormFieldScreen> {
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
  List<TextEditingController> choiceControllers = [];

  bool isRequired = false;
  String selectedIconName = 'person';
  String labelHint = '';
  String helpTextHint = '';
  List<String> optionHints = [];
  @override
  void initState() {
    super.initState();
    _loadFieldDataFromBackend();
  }

  Future<void> _loadFieldDataFromBackend() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/GETcustom-field/${widget.fieldId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          labelHint = data['label'] ?? '';
          helpTextHint = data['help_text'] ?? '';
          isRequired = (data['is_required'] == 1);

          labelController.text = labelHint;
          helpTextController.text = helpTextHint;

          final typeFromBackend = data['type'] ?? 'text';
          selectedFieldType = _formatFieldType(typeFromBackend);

          if (data['options'] != null && data['options'] is List) {
            optionHints =
                (data['options'] as List)
                    .map<String>((opt) => opt['option_value'].toString())
                    .toList();

            choiceControllers =
                optionHints
                    .map((hint) => TextEditingController(text: hint))
                    .toList();
          }
        });
      } else {
        print("Failed to fetch data");
      }
    } catch (e) {
      print("❌ Error loading field data: $e");
    }
  }

  String _mapFieldTypeToBackend(String type) {
    switch (type) {
      case 'Text Field':
        return 'text';
      case 'Paragraph Field':
        return 'textarea';
      case 'Choice Field':
        return 'dropdown';
      case 'Multiple Choice Field':
        return 'radio';
      case 'Checkbox Field':
        return 'checkbox';
      case 'Place Field':
        return 'place';
      case 'Date Field':
        return 'date';
      case 'Time Field':
        return 'time';
      default:
        return 'text';
    }
  }

  String _formatFieldType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return 'Text Field';
      case 'textarea':
        return 'Paragraph Field';
      case 'dropdown':
        return 'Choice Field';
      case 'radio':
        return 'Multiple Choice Field';
      case 'checkbox':
        return 'Checkbox Field';
      case 'place':
        return 'Place Field';
      case 'date':
        return 'Date Field';
      case 'time':
        return 'Time Field';
      default:
        return 'Text Field';
    }
  }

  Widget _buildChoicesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text("Choice Options:", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ...List.generate(optionHints.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextField(controller: choiceControllers[index]),
          );
        }),
      ],
    );
  }

  Future<void> _updateFieldToBackend() async {
    final List<String> options =
        choiceControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

    print("🔴options   $options");

    final Map<String, dynamic> fieldData = {
      "label": labelController.text.trim(),
      "type": _mapFieldTypeToBackend(selectedFieldType),
      "is_required": isRequired,
      "help_text": helpTextController.text.trim(),
      "default_value": options.isNotEmpty ? options.first : null,
      "options": options,
    };
    print("🔴fieldData  $fieldData");

    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/custom-fields/${widget.fieldId}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(fieldData),
      );

      if (response.statusCode == 200) {
        print("🔴response.statusCode" + response.statusCode.toString());

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Field updated successfully.")));
      } else {
        throw Exception("Update failed");
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while updating.")),
      );
    }

      print("💡💡💡done update fff");

  //  Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Icon(Icons.edit, size: 24),
            SizedBox(width: 8),
            Text('Update Form Field'),
          ],
        ),
        backgroundColor: AppColors.mediumColor,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Field Label:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  hintText:
                      labelHint.isNotEmpty
                          ? labelHint
                          : "e.g., What is your favorite color?",
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
                  Text("Required (must be filled)"),
                ],
              ),

              SizedBox(height: 4),
              TextField(
                controller: helpTextController,
                decoration: InputDecoration(
                  hintText: "Write helper text",
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
              if (selectedFieldType == 'Choice Field' ||
                  selectedFieldType == 'Multiple Choice Field' ||
                  selectedFieldType == 'Checkbox Field')
                _buildChoicesInput(),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: AppColors.textColor),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    onPressed: _updateFieldToBackend,
                    child: Text(
                      "Update Field",
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
