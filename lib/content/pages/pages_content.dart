// lib\content\pages\pages_content.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'MeetingTypesTab.dart';
import 'SettingsTab.dart';
import 'package:flutter/services.dart'; // For Clipboard

class PagesContent extends StatefulWidget {
  @override
  _PagesContentState createState() => _PagesContentState();
}

class _PagesContentState extends State<PagesContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showPublishMenu = false;
  String _publishStatus = 'Published';
  final LayerLink _publishLink = LayerLink();
  OverlayEntry? _publishOverlayEntry;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: 'https://your-meeting-link.com'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile dropdown section
            Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Container(
                width: double.infinity,
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.mediumColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.primaryColor,
                      child: Text(
                        'ش',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: 'شهد ياسين',
                        icon: Icon(Icons.arrow_drop_down, size: 20, color: AppColors.textColor),
                        isExpanded: true,
                        underline: SizedBox(),
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 14,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'شهد ياسين',
                            child: Text('شهد ياسين'),
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Divider
            Divider(height: 1, thickness: 1, color: AppColors.mediumColor),
            SizedBox(height: 16),
            
            // Title
            Text(
              'Meet with شهد ياسين',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 16),
            
            // Buttons Row
            Column(
              children: [
                // Publish Status Button
                CompositedTransformTarget(
                  link: _publishLink,
                  child: SizedBox(
                    width: double.infinity,
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
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _showPublishDropdown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                ),
                SizedBox(height: 12),
                // View Live and Copy Link buttons
                Row(
                  children: [
                    // View Live Button
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(4),
                          ),
                          border: Border.all(
                            color: AppColors.mediumColor,
                            width: 1,
                          ),
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            foregroundColor: AppColors.textColor,
                          ),
                          onPressed: () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => LivePage()),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.open_in_new, size: 16, color: Colors.pink),
                              SizedBox(width: 8),
                              Text('View Live'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Copy Link Button
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                        border: Border.all(
                          color: AppColors.mediumColor,
                          width: 1,
                        ),
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          foregroundColor: AppColors.textColor,
                        ),
                        onPressed: _copyLink,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.link, size: 16, color: Colors.pink),
                            SizedBox(width: 8),
                            Text('Copy Link'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),
            
            Container(
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 2,  // Increased from 2 to 3 for thicker underline
                    color: AppColors.primaryColor,
                  ),
                ),
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: AppColors.textColorSecond,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule, size: 20),
                        SizedBox(width: 8),  // Space between icon and text
                        Text('Meeting Types'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.settings, size: 20),
                        SizedBox(width: 8),  // Space between icon and text
                        Text('Settings'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab content (unchanged)
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: TabBarView(
                controller: _tabController,
                children: [
                  MeetingTypesTab(),
                  SettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _publishOverlayEntry?.remove();
    _tabController.dispose();
    super.dispose();
  }
}

class LivePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Page')),
      body: Center(child: Text('This is the live page')),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'MeetingTypesTab.dart';
// import 'SettingsTab.dart';
// import 'package:flutter/services.dart'; // For Clipboard

// class PagesContent extends StatefulWidget {
//   @override
//   _PagesContentState createState() => _PagesContentState();
// }

// class _PagesContentState extends State<PagesContent>
//     with SingleTickerProviderStateMixin {
//   TabController? _tabController;
//   bool _showPublishMenu = false;
//   String _publishStatus = 'Published';
//   final LayerLink _publishLink = LayerLink();
//   OverlayEntry? _publishOverlayEntry;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   void _showPublishDropdown() {
//     final RenderBox renderBox = context.findRenderObject() as RenderBox;
//     final Offset offset = renderBox.localToGlobal(Offset.zero);

//     _publishOverlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         left: offset.dx,
//         top: offset.dy + 40,
//         child: Material(
//           elevation: 4,
//           child: Container(
//             width: 256,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(4),
//               border: Border.all(
//                 color: AppColors.mediumColor,
//                 width: 1,
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Published option
//                 InkWell(
//                   onTap: () {
//                     setState(() {
//                       _publishStatus = 'Published';
//                       _showPublishMenu = false;
//                     });
//                     _publishOverlayEntry?.remove();
//                   },
//                   child: Container(
//                     padding: EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.visibility,
//                           size: 20,
//                           color: Colors.green,
//                         ),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Published',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               Text(
//                                 'Attendees are allowed to schedule new meetings',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Divider(height: 1),
//                 // Disabled option
//                 InkWell(
//                   onTap: () {
//                     setState(() {
//                       _publishStatus = 'Disabled';
//                       _showPublishMenu = false;
//                     });
//                     _publishOverlayEntry?.remove();
//                   },
//                   child: Container(
//                     padding: EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.block,
//                           size: 20,
//                           color: Colors.red,
//                         ),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Disabled',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               Text(
//                                 'Attendees will be prevented from scheduling new meetings',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );

//     Overlay.of(context)?.insert(_publishOverlayEntry!);
//   }

//   void _copyLink() {
//     Clipboard.setData(ClipboardData(text: 'https://your-meeting-link.com'));
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Link copied to clipboard')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ConstrainedBox(
//       constraints: BoxConstraints(
//         minHeight: MediaQuery.of(context).size.height,
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Profile dropdown section
//             Container(
//               margin: EdgeInsets.only(bottom: 16),
//               child: Container(
//                 width: double.infinity,
//                 height: 40,
//                 padding: EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: AppColors.backgroundColor,
//                   borderRadius: BorderRadius.circular(4),
//                   border: Border.all(
//                     color: AppColors.mediumColor,
//                     width: 1,
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 10,
//                       backgroundColor: AppColors.primaryColor,
//                       child: Text(
//                         'ش',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     Expanded(
//                       child: DropdownButton<String>(
//                         value: 'شهد ياسين',
//                         icon: Icon(Icons.arrow_drop_down, size: 20, color: AppColors.textColor),
//                         isExpanded: true,
//                         underline: SizedBox(),
//                         style: TextStyle(
//                           color: AppColors.textColor,
//                           fontSize: 14,
//                         ),
//                         items: [
//                           DropdownMenuItem(
//                             value: 'شهد ياسين',
//                             child: Text('شهد ياسين'),
//                           ),
//                         ],
//                         onChanged: (value) {},
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             // Divider
//             Container(
//               margin: EdgeInsets.only(bottom: 16),
//               child: Divider(
//                 height: 1,
//                 thickness: 1,
//                 color: AppColors.mediumColor,
//               ),
//             ),
            
//             // Title
//             Padding(
//               padding: EdgeInsets.only(bottom: 16),
//               child: Text(
//                 'Meet with شهد ياسين',
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.textColor,
//                 ),
//               ),
//             ),
            
//             // Buttons Row
//             Container(
//               margin: EdgeInsets.only(bottom: 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Publish Status Button
//                   CompositedTransformTarget(
//                     link: _publishLink,
//                     child: SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.backgroundColor,
//                           foregroundColor: AppColors.textColor,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(4),
//                             side: BorderSide(
//                               color: AppColors.mediumColor,
//                               width: 1,
//                             ),
//                           ),
//                           padding: EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         onPressed: () {
//                           if (_showPublishMenu) {
//                             _publishOverlayEntry?.remove();
//                             setState(() {
//                               _showPublishMenu = false;
//                             });
//                           } else {
//                             _showPublishDropdown();
//                             setState(() {
//                               _showPublishMenu = true;
//                             });
//                           }
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               _publishStatus == 'Published' 
//                                   ? Icons.visibility 
//                                   : Icons.block,
//                               size: 16,
//                               color: _publishStatus == 'Published' 
//                                   ? Colors.green 
//                                   : Colors.red,
//                             ),
//                             SizedBox(width: 8),
//                             Text(_publishStatus),
//                             SizedBox(width: 8),
//                             Icon(
//                               Icons.arrow_drop_down,
//                               size: 16,
//                               color: AppColors.textColor,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 12),
//                   // View Live and Copy Link buttons
//                   Row(
//                     children: [
//                       // View Live Button
//                       Expanded(
//                         child: Container(
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: AppColors.backgroundColor,
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(4),
//                               bottomLeft: Radius.circular(4),
//                             ),
//                             border: Border.all(
//                               color: AppColors.mediumColor,
//                               width: 1,
//                             ),
//                           ),
//                           child: TextButton(
//                             style: TextButton.styleFrom(
//                               padding: EdgeInsets.symmetric(horizontal: 16),
//                               foregroundColor: AppColors.textColor,
//                             ),
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => LivePage()),
//                               );
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.open_in_new,
//                                   size: 16,
//                                   color: Colors.pink,
//                                 ),
//                                 SizedBox(width: 8),
//                                 Text('View Live'),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       // Copy Link Button
//                       Container(
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: AppColors.backgroundColor,
//                           borderRadius: BorderRadius.only(
//                             topRight: Radius.circular(4),
//                             bottomRight: Radius.circular(4),
//                           ),
//                           border: Border.all(
//                             color: AppColors.mediumColor,
//                             width: 1,
//                           ),
//                         ),
//                         child: TextButton(
//                           style: TextButton.styleFrom(
//                             padding: EdgeInsets.symmetric(horizontal: 16),
//                             foregroundColor: AppColors.textColor,
//                           ),
//                           onPressed: _copyLink,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.link,
//                                 size: 16,
//                                 color: Colors.pink,
//                               ),
//                               SizedBox(width: 8),
//                               Text('Copy Link'),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
            
//             // Tab bar
//             Container(
//               margin: EdgeInsets.only(bottom: 16),
//               child: TabBar(
//                 controller: _tabController,
//                 isScrollable: false,
//                 labelColor: AppColors.backgroundColor,
//                 unselectedLabelColor: AppColors.textColor,
//                 indicator: BoxDecoration(
//                   color: AppColors.primaryColor,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 labelPadding: EdgeInsets.symmetric(horizontal: 2),
//                 tabs: [
//                   Tab(
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.schedule, size: 16),
//                           SizedBox(width: 5),
//                           Text('Meeting Types', style: TextStyle(fontSize: 12)),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Tab(
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.settings, size: 16),
//                           SizedBox(width: 5),
//                           Text('Settings', style: TextStyle(fontSize: 12)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             // Tab content
//             Container(
//               height: MediaQuery.of(context).size.height * 0.6,
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   MeetingTypesTab(),
//                   SettingsTab(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _publishOverlayEntry?.remove();
//     super.dispose();
//   }
// }

// class LivePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Live Page')),
//       body: Center(child: Text('This is the live page')),
//     );
//   }
// }

// // lib\content\pages\pages_content.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'MeetingTypesTab.dart';
// import 'SettingsTab.dart';

// class PagesContent extends StatefulWidget {
//   @override
//   _PagesContentState createState() => _PagesContentState();
// }

// class _PagesContentState extends State<PagesContent>
//     with SingleTickerProviderStateMixin {
//   TabController? _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   int meetingTypes = 2;
//   int teamMembers = 1;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [

//         Row(
//   children: [
//     CircleAvatar(
//       backgroundColor: AppColors.primaryColor,
//       child: Text(
//         'ش',
//         style: TextStyle(color: Colors.white),
//       ),
//     ),
//     SizedBox(width: 8),
//     Expanded(
//       child: DropdownButton<String>(
//         value: 'شهد ياسين',
//         icon: Icon(Icons.arrow_drop_down),
//         isExpanded: true,
//         underline: SizedBox(),
//         items: [
//           DropdownMenuItem(value: 'شهد ياسين', child: Text('شهد ياسين')),
//         ],
//         onChanged: (value) {},
//       ),
//     ),
//   ],
// ),
// SizedBox(height: 10),

//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//             Text(
//   'Meet with شهد ياسين',
//   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// ),
// SizedBox(height: 12),

//               SizedBox(height: 12),

//               SizedBox(
//                 width: double.infinity,
//                 child: Builder(
//                   builder: (context) {
//                     return GestureDetector(
//                       onTapDown: (TapDownDetails details) async {
//                         final RenderBox overlay =
//                             Overlay.of(context).context.findRenderObject()
//                                 as RenderBox;
//                         final selected = await showMenu<String>(
//                           context: context,
//                           position: RelativeRect.fromRect(
//                             details.globalPosition & Size(40, 40),
//                             Offset.zero & overlay.size,
//                           ),
//                           items: [
//                             PopupMenuItem<String>(
//                               value: 'Publish',
//                               child: SizedBox(
//                                 width:
//                                     MediaQuery.of(context).size.width -
//                                     32, // 16 left + 16 right padding
//                                 child: Text(
//                                   'Publish',
//                                   style: TextStyle(fontSize: 16),
//                                 ),
//                               ),
//                             ),
//                             PopupMenuItem<String>(
//                               value: 'Disabled',
//                               child: SizedBox(
//                                 width: MediaQuery.of(context).size.width - 32,
//                                 child: Text(
//                                   'Disabled',
//                                   style: TextStyle(fontSize: 16),
//                                 ),
//                               ),
//                             ),
//                           ],
//                           elevation: 8,
//                           color: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         );
//                         if (selected != null) {
//                           if (selected == 'Publish') {
//                             print('Published!');
//                           } else if (selected == 'Disabled') {
//                             print('Disabled selected');
//                           }
//                         }
//                       },
//                       child: Container(
//                         padding: EdgeInsets.symmetric(vertical: 14),
//                         decoration: BoxDecoration(
//                           color: AppColors.primaryColor,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         alignment: Alignment.center,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Publish',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             SizedBox(width: 6),
//                             Icon(Icons.arrow_drop_down, color: Colors.white),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               SizedBox(height: 12),

//               SizedBox(
//                 width: double.infinity,
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => LivePage()),
//                     );
//                   },
//                   style: TextButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 14),
//                     backgroundColor: Colors.transparent,
//                   ),
//                   child: Text(
//                     'View Live',
//                     style: TextStyle(
//                       fontSize: 16,
//                       decoration: TextDecoration.underline,
//                       color: AppColors.primaryColor,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         TabBar(
//           controller: _tabController,
//           isScrollable: false,
//           labelColor: AppColors.backgroundColor,
//           unselectedLabelColor: AppColors.textColor,
//           indicator: BoxDecoration(
//             color: AppColors.primaryColor,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           labelPadding: EdgeInsets.symmetric(horizontal: 2),
//           tabs: [
//             Tab(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.schedule),
//                   SizedBox(width: 5),
//                   Text('Meeting Types', style: TextStyle(fontSize: 12)),
//                 ],
//               ),
//             ),
//             Tab(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.group),
//                   SizedBox(width: 5),
//                   Text('Team Members', style: TextStyle(fontSize: 12)),
//                 ],
//               ),
//             ),
//             Tab(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.settings),
//                   SizedBox(width: 5),
//                   Text('Settings', style: TextStyle(fontSize: 12)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         SizedBox(
//           height: MediaQuery.of(context).size.height - 180,
//           child: TabBarView(
//             controller: _tabController,
//             children: [
//               Center(child: MeetingTypesTab()),
//               Center(
//                 child: Text('Team Members', style: TextStyle(fontSize: 14)),
//               ),
//               Center(child: SettingsTab()),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class LivePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Live Page')),
//       body: Center(child: Text('This is the live page')),
//     );
//   }
// }