// lib\content\pages\MeetingDetailsPage.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:tabourak/content/pages/FormFieldApp.dart';
import 'PaymentTabContent.dart';
import 'availability_tab.dart';

class MeetingDetailsPage extends StatefulWidget {
  final String title;
  final String duration;
  final String type;
  final String link;
  final int id;

  const MeetingDetailsPage({
    required this.title,
    required this.duration,
    required this.type,
    required this.link,
    required this.id,
  });

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  String selectedLocation = "place";
  String locationDecision = "host";
  String _publishStatus = 'Published';
  final LayerLink _publishLink = LayerLink();
  OverlayEntry? _publishOverlayEntry;

  late TextEditingController titleController;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController lengthController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  List<Map<String, dynamic>> customFields = [];

  String selectedUnit = "Minutes";
  int selectedColorIndex = 0;

  final List<Color> colorOptions = [
    Color(0xFF1C8B97), Color(0xFF2980B9), Color(0xFF0ED70A),
    Color(0xFF009432), Color(0xFFC40404), Color(0xFFED4C67),
    Color(0xFFFA8A1A), Color(0xFF851EFF), Color(0xFFD980FA),
    Color(0xFFF1C40F), Color(0xFF8A9199),
  ];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    lengthController = TextEditingController(
      text: widget.duration.split(" ")[0],
    );
  }

  void _showPublishDropdown() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    _publishOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + 40,
        child: Material(
          elevation: 4,
          child: Container(
            width: 256,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.mediumColor,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() => _publishStatus = 'Published');
                    _publishOverlayEntry?.remove();
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 20, color: Colors.green),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Published', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Attendees are allowed to schedule new meetings',
                                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1),
                InkWell(
                  onTap: () {
                    setState(() => _publishStatus = 'Disabled');
                    _publishOverlayEntry?.remove();
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.block, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Disabled', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Attendees will be prevented from scheduling new meetings',
                                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(_publishOverlayEntry!);
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
      length: 5,
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.white,
        //   title: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         widget.title,
        //         style: TextStyle(
        //           color: Colors.black,
        //           fontSize: 20,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //       SizedBox(height: 8),
        //       Row(
        //         children: [
        //           CompositedTransformTarget(
        //             link: _publishLink,
        //             child: ElevatedButton(
        //               style: ElevatedButton.styleFrom(
        //                 backgroundColor: AppColors.backgroundColor,
        //                 foregroundColor: AppColors.textColor,
        //                 shape: RoundedRectangleBorder(
        //                   borderRadius: BorderRadius.circular(4),
        //                   side: BorderSide(
        //                     color: AppColors.mediumColor,
        //                     width: 1,
        //                   ),
        //                 ),
        //                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //               ),
        //               onPressed: _showPublishDropdown,
        //               child: Row(
        //                 mainAxisSize: MainAxisSize.min,
        //                 children: [
        //                   Icon(
        //                     _publishStatus == 'Published' ? Icons.visibility : Icons.block,
        //                     size: 16,
        //                     color: _publishStatus == 'Published' ? Colors.green : Colors.red,
        //                   ),
        //                   SizedBox(width: 8),
        //                   Text(_publishStatus),
        //                   SizedBox(width: 8),
        //                   Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textColor),
        //                 ],
        //               ),
        //             ),
        //           ),
        //           SizedBox(width: 8),
        //           ElevatedButton(
        //             onPressed: () {
        //               print("Save Changes pressed");
        //             },
        //             child: Text(
        //               "Save Changes",
        //               style: TextStyle(color: AppColors.backgroundColor),
        //             ),
        //             style: ElevatedButton.styleFrom(
        //               backgroundColor: AppColors.primaryColor,
        //               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        //   bottom: TabBar(
        //     isScrollable: true,
        //     labelColor: AppColors.primaryColor,
        //     unselectedLabelColor: AppColors.textColorSecond,
        //     indicatorColor: AppColors.primaryColor,
        //     labelPadding: EdgeInsets.only(left: 16, right: 16), // Adjusted padding
        //     tabs: [
        //       Tab(text: 'General'),
        //       Tab(text: 'Location'),
        //       Tab(text: 'Availability'),
        //       Tab(text: 'Intake Form'),
        //       Tab(text: 'Payment'),
        //     ],
        //   ),
        // ),

appBar: AppBar(
  backgroundColor: Colors.white,
  toolbarHeight: 100,
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        widget.title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 16),
      Container(
        height: 48,
        child: Row(
          children: [
            CompositedTransformTarget(
              link: _publishLink,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.backgroundColor,
                  foregroundColor: AppColors.textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(
                      color: AppColors.mediumColor,
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: _showPublishDropdown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _publishStatus == 'Published' ? Icons.visibility : Icons.block,
                      size: 16,
                      color: _publishStatus == 'Published' ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(_publishStatus),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textColor),
                  ],
                ),
              ),
            ),
            Spacer(),
            Container(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  print("Save Changes pressed");
                },
                child: Text(
                  "Save Changes",
                  style: TextStyle(
                    color: AppColors.backgroundColor,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
  bottom: PreferredSize(
    preferredSize: Size.fromHeight(48),
    child: Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(left: 0), // No left padding
        child: TabBar(
          isScrollable: true,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.textColorSecond,
          indicatorColor: AppColors.primaryColor,
          labelPadding: EdgeInsets.only(left:10,right: 15), // Only right padding between tabs
          tabAlignment: TabAlignment.start, // Ensure tabs start from left
          tabs: [
            Tab(text: 'General'),
            Tab(text: 'Location'),
            Tab(text: 'Availability'),
            Tab(text: 'Intake Form'),
            Tab(text: 'Payment'),
          ],
        ),
      ),
    ),
  ),
),        body: TabBarView(
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
                        items: ["Minutes", "Hours"]
                            .map((unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                ))
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
                    runSpacing: 8,
                    children: List.generate(colorOptions.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColorIndex = index;
                          });
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colorOptions[index],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: selectedColorIndex == index
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
                    child: selectedLocation == "place"
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
                    child: selectedLocation == "phone"
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
            AvailabilityTab(),
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
            PaymentTabContent(),
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
          color: selected ? const Color.fromARGB(255, 235, 253, 255) : Colors.white,
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

  @override
  void dispose() {
    _publishOverlayEntry?.remove();
    super.dispose();
  }
}







// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:tabourak/content/pages/FormFieldApp.dart';
// import 'PaymentTabContent.dart';
// import 'availability_tab.dart';

// class MeetingDetailsPage extends StatefulWidget {
//   final String title;
//   final String duration;
//   final String type;
//   final String link;
//   final int id;

//   const MeetingDetailsPage({
//     required this.title,
//     required this.duration,
//     required this.type,
//     required this.link,
//     required this.id,
//   });

//   @override
//   State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
// }

// class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
//   String selectedLocation = "place";
//   String locationDecision = "host";
//   String _publishStatus = 'Published';

//   late TextEditingController titleController;
//   TextEditingController descriptionController = TextEditingController();
//   TextEditingController lengthController = TextEditingController();
//   TextEditingController phoneNumberController = TextEditingController();
//   List<Map<String, dynamic>> customFields = [];

//   String selectedUnit = "Minutes";
//   int selectedColorIndex = 0;

//   final List<Color> colorOptions = [
//     Color(0xFF1C8B97), Color(0xFF2980B9), Color(0xFF0ED70A),
//     Color(0xFF009432), Color(0xFFC40404), Color(0xFFED4C67),
//     Color(0xFFFA8A1A), Color(0xFF851EFF), Color(0xFFD980FA),
//     Color(0xFFF1C40F), Color(0xFF8A9199),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     titleController = TextEditingController(text: widget.title);
//     lengthController = TextEditingController(
//       text: widget.duration.split(" ")[0],
//     );
//   }

//   IconData getIconByName(String name) {
//     switch (name) {
//       case 'Text Field': return Icons.text_fields;
//       case 'Paragraph Field': return Icons.notes;
//       case 'Choice Field': return Icons.radio_button_checked;
//       case 'Multiple Choice Field': return Icons.check_circle_outline;
//       case 'Checkbox Field': return Icons.check_box;
//       case 'Place Field': return Icons.place;
//       case 'Date Field': return Icons.date_range;
//       default: return Icons.text_fields;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 5,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(widget.title),
//           backgroundColor: Colors.white,
//           bottom: PreferredSize(
//             preferredSize: Size.fromHeight(48),
//             child: Container(
//               color: Colors.white,
//               child: TabBar(
//                 isScrollable: true,
//                 indicator: UnderlineTabIndicator(
//                   borderSide: BorderSide(
//                     width: 2,
//                     color: AppColors.primaryColor,
//                   ),
//                 ),
//                 labelColor: AppColors.primaryColor,
//                 unselectedLabelColor: Colors.grey,
//                 tabs: [
//                   Tab(text: 'General'),
//                   Tab(text: 'Location'),
//                   Tab(text: 'Availability'),
//                   Tab(text: 'Intake Form'),
//                   Tab(text: 'Payment'),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         body: Column(
//           children: [
//             // Top content with publish and save buttons
//             Container(
//               color: Colors.white,
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       widget.title,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(color: AppColors.mediumColor),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: AppColors.textColor,
//                         elevation: 0,
//                         padding: EdgeInsets.symmetric(horizontal: 12),
//                       ),
//                       onPressed: () {},
//                       child: Row(
//                         children: [
//                           Icon(
//                             _publishStatus == 'Published' 
//                                 ? Icons.visibility 
//                                 : Icons.block,
//                             size: 16,
//                             color: _publishStatus == 'Published' 
//                                 ? Colors.green 
//                                 : Colors.red,
//                           ),
//                           SizedBox(width: 8),
//                           Text(_publishStatus),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   ElevatedButton.icon(
//                     onPressed: () {},
//                     icon: Icon(Icons.save, size: 16, color: Colors.white),
//                     label: Text("Save"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryColor,
//                       padding: EdgeInsets.symmetric(horizontal: 12),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Divider(height: 1),
            
//             // Tab content
//             Expanded(
//               child: TabBarView(
//                 children: [
//                   // General Tab
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: ListView(
//                       children: [
//                         Text(
//                           "Meeting Name",
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(height: 8),
//                         TextField(
//                           controller: titleController,
//                           decoration: InputDecoration(border: OutlineInputBorder()),
//                         ),
//                         SizedBox(height: 16),

//                         Row(
//                           children: [
//                             Text(
//                               "Description",
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(width: 6),
//                             Tooltip(
//                               message: "Write a brief description of the meeting",
//                               child: Icon(Icons.help_outline, size: 18),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 8),
//                         TextField(
//                           controller: descriptionController,
//                           maxLines: 3,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             hintText: 'Add description',
//                           ),
//                         ),
//                         SizedBox(height: 16),

//                         Row(
//                           children: [
//                             Text(
//                               "Length",
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(width: 6),
//                             Tooltip(
//                               message: "How long will the meeting take?",
//                               child: Icon(Icons.help_outline, size: 18),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 controller: lengthController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                   border: OutlineInputBorder(),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 8),
//                             DropdownButton<String>(
//                               value: selectedUnit,
//                               items: ["Minutes", "Hours"]
//                                   .map((unit) => DropdownMenuItem(
//                                         value: unit,
//                                         child: Text(unit),
//                                       ))
//                                   .toList(),
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedUnit = value!;
//                                 });
//                               },
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 16),

//                         Text("Color", style: TextStyle(fontWeight: FontWeight.bold)),
//                         SizedBox(height: 8),
//                         Wrap(
//                           spacing: 8,
//                           runSpacing: 8,
//                           children: List.generate(colorOptions.length, (index) {
//                             return GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   selectedColorIndex = index;
//                                 });
//                               },
//                               child: Container(
//                                 width: 28,
//                                 height: 28,
//                                 decoration: BoxDecoration(
//                                   color: colorOptions[index],
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                                 child: selectedColorIndex == index
//                                     ? Icon(
//                                         Icons.check,
//                                         size: 16,
//                                         color: Colors.white,
//                                       )
//                                     : null,
//                               ),
//                             );
//                           }),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Location Tab
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         locationOption(
//                           icon: Icons.home,
//                           title: "We'll meet at a place",
//                           selected: selectedLocation == "place",
//                           onTap: () => setState(() => selectedLocation = "place"),
//                           child: selectedLocation == "place"
//                               ? Column(
//                                   children: [
//                                     RadioListTile(
//                                       title: Text("I'll decide where we meet:"),
//                                       value: "host",
//                                       groupValue: locationDecision,
//                                       onChanged: (val) {
//                                         setState(() {
//                                           locationDecision = val!;
//                                         });
//                                       },
//                                     ),
//                                     if (locationDecision == "host")
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 16,
//                                         ),
//                                         child: TextField(
//                                           decoration: InputDecoration(
//                                             hintText: "Enter address",
//                                             prefixIcon: Icon(Icons.location_on),
//                                             border: OutlineInputBorder(),
//                                           ),
//                                         ),
//                                       ),
//                                     RadioListTile(
//                                       title: Text(
//                                         "Attendee will decide where we meet",
//                                       ),
//                                       subtitle: Text(
//                                         "A questionnaire field will be added to collect their location.",
//                                       ),
//                                       value: "attendee",
//                                       groupValue: locationDecision,
//                                       onChanged: (val) {
//                                         setState(() {
//                                           locationDecision = val!;
//                                         });
//                                       },
//                                     ),
//                                   ],
//                                 )
//                               : null,
//                         ),
//                         SizedBox(height: 12),

//                         locationOption(
//                           icon: Icons.phone,
//                           title: "We'll meet on a phone call",
//                           selected: selectedLocation == "phone",
//                           onTap: () => setState(() => selectedLocation = "phone"),
//                           child: selectedLocation == "phone"
//                               ? Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 16,
//                                   ),
//                                   child: TextField(
//                                     controller: phoneNumberController,
//                                     keyboardType: TextInputType.phone,
//                                     decoration: InputDecoration(
//                                       hintText: "Enter phone number",
//                                       prefixIcon: Icon(Icons.phone),
//                                       border: OutlineInputBorder(),
//                                     ),
//                                   ),
//                                 )
//                               : null,
//                         ),

//                         SizedBox(height: 12),

//                         locationOption(
//                           icon: Icons.videocam,
//                           title: "Meet on a web conference",
//                           selected: selectedLocation == "web",
//                           onTap: () => setState(() => selectedLocation = "web"),
//                         ),
//                       ],
//                     ),
//                   ),

//                   AvailabilityTab(),

//                   // Intake Form Tab
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         intakeFieldTile(
//                           icon: Icons.person_outline,
//                           title: "First & Last Name",
//                           subtitle: "Collected automatically",
//                         ),
//                         SizedBox(height: 12),
//                         intakeFieldTile(
//                           icon: Icons.alternate_email,
//                           title: "Email Address",
//                           subtitle: "Collected automatically",
//                         ),

//                         ...customFields.map((field) {
//                           return Card(
//                             color: Colors.white,
//                             child: ListTile(
//                               leading: Icon(getIconByName(field['icon'])),
//                               title: Text(field['label']),
//                               trailing: IconButton(
//                                 icon: Icon(Icons.close),
//                                 onPressed: () {
//                                   setState(() {
//                                     customFields.remove(field);
//                                   });
//                                 },
//                               ),
//                             ),
//                           );
//                         }).toList(),

//                         SizedBox(height: 16),
//                         GestureDetector(
//                           onTap: () async {
//                             final newField = await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => CreateFormFieldScreen(),
//                               ),
//                             );

//                             if (newField != null) {
//                               setState(() {
//                                 customFields.add(newField);
//                               });
//                             }
//                           },
//                           child: Text(
//                             "+ Add Another Question",
//                             style: TextStyle(
//                               color: AppColors.accentColor,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   PaymentTabContent(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget locationOption({
//     required IconData icon,
//     required String title,
//     required bool selected,
//     required VoidCallback onTap,
//     Widget? child,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: selected ? AppColors.secondaryColor : Colors.grey.shade300,
//           ),
//           borderRadius: BorderRadius.circular(10),
//           color: selected
//               ? const Color.fromARGB(255, 235, 253, 255)
//               : Colors.white,
//         ),
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   icon,
//                   color: selected ? AppColors.secondaryColor : Colors.black,
//                 ),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 if (selected)
//                   Icon(Icons.check_circle, color: AppColors.secondaryColor),
//               ],
//             ),
//             if (child != null) SizedBox(height: 8),
//             if (child != null) child,
//           ],
//         ),
//       ),
//     );
//   }

//   Widget intakeFieldTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//         boxShadow: [
//           BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
//         ],
//       ),
//       child: ListTile(
//         leading: Icon(icon, color: Colors.grey.shade700),
//         title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text(subtitle),
//       ),
//     );
//   }
// }