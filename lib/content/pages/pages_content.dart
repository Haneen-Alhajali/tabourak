// lib\content\pages\pages_content.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'MeetingTypesTab.dart';
import 'SettingsTab.dart';
import 'package:flutter/services.dart';
import 'package:tabourak/config/snackbar_helper.dart';

class PagesContent extends StatefulWidget {
  @override
  _PagesContentState createState() => _PagesContentState();
}

class _PagesContentState extends State<PagesContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _publishStatus = 'Published';
  final LayerLink _publishLink = LayerLink();
  OverlayEntry? _publishOverlayEntry;
  String _selectedPage = 'haneen radad';
  final List<String> _pageOptions = ['team page test', 'haneen radad', 'hanee alhajali'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _showPageSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: AppColors.mediumColor,
              width: 1,
            ),
          ),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team Pages Section
                Container(
                  height: 48,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Team Pages',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                _buildDialogItem('team page test'),
                Container(
                  height: 56,
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryColor, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: InkWell(
                    onTap: () {
                      // Handle create new team page
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 20, color: AppColors.primaryColor),
                        SizedBox(width: 12),
                        Text(
                          'Create New Team Page',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Divider
                Container(
                  height: 16,
                  child: Divider(height: 1, color: AppColors.mediumColor, thickness: 1),
                ),
                // Individual Pages Section
                Container(
                  height: 48,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Individual Pages',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                _buildDialogItem('haneen radad'),
                _buildDialogItem('hanee alhajali'),
                SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogItem(String value) {
    bool isSelected = value == _selectedPage;
    Widget leading;
    
    if (value == 'haneen radad' || value == 'hanee alhajali') {
      leading = CircleAvatar(
        radius: 16,
        backgroundColor: isSelected ? AppColors.primaryColor : Colors.grey[300],
        child: Text(
          'H',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      leading = Icon(Icons.people_outline, size: 24, color: AppColors.textColor);
    }

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPage = value;
        });
        Navigator.of(context).pop();
      },
      child: Container(
        height: 56,
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              )
            : null,
        margin: isSelected
            ? EdgeInsets.symmetric(horizontal: 8)
            : null,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            leading,
            SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primaryColor : AppColors.textColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, size: 24, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedItem() {
    Widget leading;
    if (_selectedPage == 'haneen radad' || _selectedPage == 'hanee alhajali') {
      leading = CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.primaryColor,
        child: Text(
          'H',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      leading = Icon(Icons.people_outline, size: 24, color: AppColors.textColor);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          leading,
          SizedBox(width: 12),
          Text(
            _selectedPage,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor,
            ),
          ),
          Spacer(),
          Icon(Icons.arrow_drop_down, size: 24, color: AppColors.textColor),
        ],
      ),
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

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: 'https://your-meeting-link.com'));
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Link copied to clipboard')),
    // );
    SnackbarHelper.showInfo(context, 'Link copied to clipboard');

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
            // Page selector using dialog
            Container(
              margin: EdgeInsets.only(bottom: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.mediumColor, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: _showPageSelectionDialog,
                child: _buildSelectedItem(),
              ),
            ),
            
            Divider(height: 1, thickness: 1, color: AppColors.mediumColor),
            SizedBox(height: 16),
            
            Text(
              'Meet with $_selectedPage',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 16),
            
            Column(
              children: [
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
                Row(
                  children: [
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
                    width: 2,
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
                        SizedBox(width: 8),
                        Text('Meeting Types'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.settings, size: 20),
                        SizedBox(width: 8),
                        Text('Settings'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
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
//   late TabController _tabController;
//   bool _showPublishMenu = false;
//   String _publishStatus = 'Published';
//   final LayerLink _publishLink = LayerLink();
//   OverlayEntry? _publishOverlayEntry;
//   String _selectedPage = 'haneen radad'; // Changed to haneen radad as default

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
//                 InkWell(
//                   onTap: () {
//                     setState(() => _publishStatus = 'Published');
//                     _publishOverlayEntry?.remove();
//                   },
//                   child: Container(
//                     padding: EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Icon(Icons.visibility, size: 20, color: Colors.green),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Published', style: TextStyle(fontWeight: FontWeight.bold)),
//                               Text('Attendees are allowed to schedule new meetings',
//                                   style: TextStyle(fontSize: 12, color: Colors.grey)),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Divider(height: 1),
//                 InkWell(
//                   onTap: () {
//                     setState(() => _publishStatus = 'Disabled');
//                     _publishOverlayEntry?.remove();
//                   },
//                   child: Container(
//                     padding: EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Icon(Icons.block, size: 20, color: Colors.red),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Disabled', style: TextStyle(fontWeight: FontWeight.bold)),
//                               Text('Attendees will be prevented from scheduling new meetings',
//                                   style: TextStyle(fontSize: 12, color: Colors.grey)),
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
//             // Dropdown menu with selected item in header
//             Container(
//               margin: EdgeInsets.only(bottom: 16),
//               width: double.infinity, // Full width
//               decoration: BoxDecoration(
//                 border: Border.all(color: AppColors.mediumColor, width: 1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   value: _selectedPage,
//                   isExpanded: true,
//                   icon: Icon(Icons.arrow_drop_down, size: 24, color: AppColors.textColor),
//                   style: TextStyle(
//                     color: AppColors.textColor,
//                     fontSize: 16,
//                   ),
//                   dropdownColor: Colors.white,
//                   // selectedItemBuilder: (BuildContext context) {
//                   //   return ['team page test', 'haneen radad', 'hanee alhajali'].map((value) {
//                   //     bool isSelected = value == _selectedPage;
                      
//                   //     if (value == 'haneen radad') {
//                   //       return Container(
//                   //         padding: EdgeInsets.symmetric(horizontal: 16),
//                   //         child: Row(
//                   //           children: [
//                   //             CircleAvatar(
//                   //               radius: 16,
//                   //               backgroundColor: isSelected ? AppColors.primaryColor : Colors.grey[300],
//                   //               child: Text(
//                   //                 'H',
//                   //                 style: TextStyle(
//                   //                   color: Colors.white,
//                   //                   fontSize: 16,
//                   //                   fontWeight: FontWeight.bold,
//                   //                 ),
//                   //               ),
//                   //             ),
//                   //             SizedBox(width: 12),
//                   //             Text(
//                   //               'haneen radad',
//                   //               style: TextStyle(
//                   //                 fontSize: 16,
//                   //                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                   //                 color: isSelected ? AppColors.primaryColor : AppColors.textColor,
//                   //               ),
//                   //             ),
//                   //             if (isSelected) ...[
//                   //               Spacer(),
//                   //               Icon(Icons.check, size: 24, color: AppColors.primaryColor),
//                   //             ],
//                   //           ],
//                   //         ),
//                   //       );
//                   //     } else if (value == 'hanee alhajali') {
//                   //       return Container(
//                   //         padding: EdgeInsets.symmetric(horizontal: 16),
//                   //         child: Row(
//                   //           children: [
//                   //             CircleAvatar(
//                   //               radius: 16,
//                   //               backgroundColor: isSelected ? AppColors.primaryColor : Colors.grey[300],
//                   //               child: Text(
//                   //                 'H',
//                   //                 style: TextStyle(
//                   //                   color: Colors.white,
//                   //                   fontSize: 16,
//                   //                   fontWeight: FontWeight.bold,
//                   //                 ),
//                   //               ),
//                   //             ),
//                   //             SizedBox(width: 12),
//                   //             Text(
//                   //               'hanee alhajali',
//                   //               style: TextStyle(
//                   //                 fontSize: 16,
//                   //                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                   //                 color: isSelected ? AppColors.primaryColor : AppColors.textColor,
//                   //               ),
//                   //             ),
//                   //             if (isSelected) ...[
//                   //               Spacer(),
//                   //               Icon(Icons.check, size: 24, color: AppColors.primaryColor),
//                   //             ],
//                   //           ],
//                   //         ),
//                   //       );
//                   //     } else {
//                   //       return Container(
//                   //         padding: EdgeInsets.symmetric(horizontal: 16),
//                   //         child: Row(
//                   //           children: [
//                   //             Icon(Icons.people_outline, size: 24, color: AppColors.textColor),
//                   //             SizedBox(width: 12),
//                   //             Text(
//                   //               'team page test',
//                   //               style: TextStyle(fontSize: 16),
//                   //             ),
//                   //           ],
//                   //         ),
//                   //       );
//                   //     }
//                   //   }).toList();
//                   // },
// selectedItemBuilder: (BuildContext context) {
//   return [
//     'team page test', 
//     'haneen radad', 
//     'hanee alhajali'
//   ].map((value) {
//     bool isSelected = value == _selectedPage;
    
//     Widget avatarOrIcon;
//     if (value == 'haneen radad' || value == 'hanee alhajali') {
//       avatarOrIcon = CircleAvatar(
//         radius: 16,
//         backgroundColor: isSelected ? AppColors.primaryColor : Colors.grey[300],
//         child: Text(
//           'H',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       );
//     } else {
//       avatarOrIcon = Icon(Icons.people_outline, size: 24, color: AppColors.textColor);
//     }

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           avatarOrIcon,
//           SizedBox(width: 12),
//           Text(
//             value, // Use the value directly
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//               color: isSelected ? AppColors.primaryColor : AppColors.textColor,
//             ),
//           ),
//           if (isSelected) ...[
//             Spacer(),
//             Icon(Icons.check, size: 24, color: AppColors.primaryColor),
//           ],
//         ],
//       ),
//     );
//   }).toList();
// },                  
//                   items: [
//                     // Team Pages Section
//                     DropdownMenuItem<String>(
//                       value: 'team_pages_header',
//                       enabled: false,
//                       child: Container(
//                         height: 48,
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             'Team Pages',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     DropdownMenuItem(
//                       value: 'team page test',
//                       child: Container(
//                         height: 56,
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: Row(
//                           children: [
//                             Icon(Icons.people_outline, size: 24, color: AppColors.textColor),
//                             SizedBox(width: 16),
//                             Text(
//                               'team page test',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     DropdownMenuItem(
//                       value: 'create_new',
//                       child: Container(
//                         height: 56,
//                         margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: AppColors.primaryColor, width: 1),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         padding: EdgeInsets.symmetric(horizontal: 12),
//                         child: Row(
//                           children: [
//                             Icon(Icons.add, size: 20, color: AppColors.primaryColor),
//                             SizedBox(width: 12),
//                             Text(
//                               'Create New Team Page',
//                               style: TextStyle(
//                                 color: AppColors.primaryColor,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     // Divider
//                     DropdownMenuItem<String>(
//                       value: 'divider',
//                       enabled: false,
//                       child: Container(
//                         height: 16,
//                         child: Divider(height: 1, color: AppColors.mediumColor, thickness: 1),
//                       ),
//                     ),
//                     // Individual Pages Section
//                     DropdownMenuItem<String>(
//                       value: 'individual_pages_header',
//                       enabled: false,
//                       child: Container(
//                         height: 48,
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             'Individual Pages',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     DropdownMenuItem(
//                       value: 'haneen radad',
//                       child: Container(
//                         height: 56,
//                         decoration: _selectedPage == 'haneen radad' 
//                             ? BoxDecoration(
//                                 color: AppColors.primaryColor.withOpacity(0.08),
//                                 borderRadius: BorderRadius.circular(6),
//                               )
//                             : null,
//                         margin: _selectedPage == 'haneen radad'
//                             ? EdgeInsets.symmetric(horizontal: 8)
//                             : null,
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 16,
//                               backgroundColor: _selectedPage == 'haneen radad' 
//                                   ? AppColors.primaryColor 
//                                   : Colors.grey[300],
//                               child: Text(
//                                 'H',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 16),
//                             Text(
//                               'haneen radad',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: _selectedPage == 'haneen radad'
//                                     ? AppColors.primaryColor
//                                     : AppColors.textColor,
//                                 fontWeight: _selectedPage == 'haneen radad'
//                                     ? FontWeight.w600
//                                     : FontWeight.normal,
//                               ),
//                             ),
//                             if (_selectedPage == 'haneen radad') ...[
//                               Spacer(),
//                               Icon(Icons.check, size: 24, color: AppColors.primaryColor),
//                             ],
//                           ],
//                         ),
//                       ),
//                     ),
//                     DropdownMenuItem(
//                       value: 'hanee alhajali',
//                       child: Container(
//                         height: 56,
//                         decoration: _selectedPage == 'hanee alhajali'
//                             ? BoxDecoration(
//                                 color: AppColors.primaryColor.withOpacity(0.08),
//                                 borderRadius: BorderRadius.circular(6),
//                               )
//                             : null,
//                         margin: _selectedPage == 'hanee alhajali'
//                             ? EdgeInsets.symmetric(horizontal: 8)
//                             : null,
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 16,
//                               backgroundColor: _selectedPage == 'hanee alhajali'
//                                   ? AppColors.primaryColor
//                                   : Colors.grey[300],
//                               child: Text(
//                                 'H',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 16),
//                             Text(
//                               'hanee alhajali',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: _selectedPage == 'hanee alhajali'
//                                     ? AppColors.primaryColor
//                                     : AppColors.textColor,
//                                 fontWeight: _selectedPage == 'hanee alhajali'
//                                     ? FontWeight.w600
//                                     : FontWeight.normal,
//                               ),
//                             ),
//                             if (_selectedPage == 'hanee alhajali') ...[
//                               Spacer(),
//                               Icon(Icons.check, size: 24, color: AppColors.primaryColor),
//                             ],
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                   onChanged: (value) {
//                     if (value == 'create_new') {
//                       // Handle create new team page
//                     } else if (value != null && ![
//                       'team_pages_header', 
//                       'divider', 
//                       'individual_pages_header'
//                     ].contains(value)) {
//                       setState(() {
//                         _selectedPage = value;
//                       });
//                     }
//                   },
//                 ),
//               ),
//             ),
            
//             Divider(height: 1, thickness: 1, color: AppColors.mediumColor),
//             SizedBox(height: 16),
            
//             Text(
//               'Meet with $_selectedPage', // Updated to use the selected page name
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textColor,
//               ),
//             ),
//             SizedBox(height: 16),
            
//             Column(
//               children: [
//                 CompositedTransformTarget(
//                   link: _publishLink,
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.backgroundColor,
//                         foregroundColor: AppColors.textColor,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(4),
//                           side: BorderSide(
//                             color: AppColors.mediumColor,
//                             width: 1,
//                           ),
//                         ),
//                         padding: EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       onPressed: _showPublishDropdown,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             _publishStatus == 'Published' ? Icons.visibility : Icons.block,
//                             size: 16,
//                             color: _publishStatus == 'Published' ? Colors.green : Colors.red,
//                           ),
//                           SizedBox(width: 8),
//                           Text(_publishStatus),
//                           SizedBox(width: 8),
//                           Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textColor),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Container(
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: AppColors.backgroundColor,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(4),
//                             bottomLeft: Radius.circular(4),
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
//                           onPressed: () => Navigator.push(
//                             context, 
//                             MaterialPageRoute(builder: (context) => LivePage()),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.open_in_new, size: 16, color: Colors.pink),
//                               SizedBox(width: 8),
//                               Text('View Live'),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: AppColors.backgroundColor,
//                         borderRadius: BorderRadius.only(
//                           topRight: Radius.circular(4),
//                           bottomRight: Radius.circular(4),
//                         ),
//                         border: Border.all(
//                           color: AppColors.mediumColor,
//                           width: 1,
//                         ),
//                       ),
//                       child: TextButton(
//                         style: TextButton.styleFrom(
//                           padding: EdgeInsets.symmetric(horizontal: 16),
//                           foregroundColor: AppColors.textColor,
//                         ),
//                         onPressed: _copyLink,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.link, size: 16, color: Colors.pink),
//                             SizedBox(width: 8),
//                             Text('Copy Link'),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 24),
            
//             Container(
//               child: TabBar(
//                 controller: _tabController,
//                 isScrollable: false,
//                 indicator: UnderlineTabIndicator(
//                   borderSide: BorderSide(
//                     width: 2,
//                     color: AppColors.primaryColor,
//                   ),
//                 ),
//                 labelColor: AppColors.primaryColor,
//                 unselectedLabelColor: AppColors.textColorSecond,
//                 labelStyle: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 unselectedLabelStyle: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.normal,
//                 ),
//                 tabs: [
//                   Tab(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.schedule, size: 20),
//                         SizedBox(width: 8),
//                         Text('Meeting Types'),
//                       ],
//                     ),
//                   ),
//                   Tab(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.settings, size: 20),
//                         SizedBox(width: 8),
//                         Text('Settings'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
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
//     _tabController.dispose();
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






// lib\content\pages\pages_content.dart
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
//   late TabController _tabController;
//   bool _showPublishMenu = false;
//   String _publishStatus = 'Published';
//   final LayerLink _publishLink = LayerLink();
//   OverlayEntry? _publishOverlayEntry;
//   String _selectedPage = 'hanee alhajali';

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
//                 InkWell(
//                   onTap: () {
//                     setState(() => _publishStatus = 'Published');
//                     _publishOverlayEntry?.remove();
//                   },
//                   child: Container(
//                     padding: EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Icon(Icons.visibility, size: 20, color: Colors.green),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Published', style: TextStyle(fontWeight: FontWeight.bold)),
//                               Text('Attendees are allowed to schedule new meetings',
//                                   style: TextStyle(fontSize: 12, color: Colors.grey)),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Divider(height: 1),
//                 InkWell(
//                   onTap: () {
//                     setState(() => _publishStatus = 'Disabled');
//                     _publishOverlayEntry?.remove();
//                   },
//                   child: Container(
//                     padding: EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Icon(Icons.block, size: 20, color: Colors.red),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Disabled', style: TextStyle(fontWeight: FontWeight.bold)),
//                               Text('Attendees will be prevented from scheduling new meetings',
//                                   style: TextStyle(fontSize: 12, color: Colors.grey)),
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
//             // Dropdown menu with selected item in header
//             Container(
//               margin: EdgeInsets.only(bottom: 16),
//               width: double.infinity, // Full width
//               decoration: BoxDecoration(
//                 border: Border.all(color: AppColors.mediumColor, width: 1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   value: _selectedPage,
//                   isExpanded: true,
//                   icon: Icon(Icons.arrow_drop_down, size: 24, color: AppColors.textColor),
//                   style: TextStyle(
//                     color: AppColors.textColor,
//                     fontSize: 16,
//                   ),
//                   dropdownColor: Colors.white,
// selectedItemBuilder: (BuildContext context) {
//   return ['team page test', 'haneen radad', 'hanee alhajali'].map((value) {
//     if (value == 'hanee alhajali') {
//       return Container(
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 16,
//               backgroundColor: AppColors.primaryColor,
//               child: Text(
//                 'H',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SizedBox(width: 12),
//             Text(
//               'hanee alhajali',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       );
//     } else if (value == 'haneen radad') {
//       return Container(
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 16,
//               backgroundColor: Colors.grey[300],
//               child: Text(
//                 'H',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SizedBox(width: 12),
//             Text(
//               'haneen radad',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       );
//     } else {
//       return Container(
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         child: Row(
//           children: [
//             Icon(Icons.people_outline, size: 24, color: AppColors.textColor),
//             SizedBox(width: 12),
//             Text(
//               'team page test',
//               style: TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       );
//     }
//   }).toList();
// },
//                  items: [
//                     // Team Pages Section
//                     DropdownMenuItem<String>(
//                       value: 'team_pages_header',
//                       enabled: false,
//                       child: Container(
//                         height: 48,
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             'Team Pages',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     DropdownMenuItem(
//                       value: 'team page test',
//                       child: Container(
//                         height: 56,
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: Row(
//                           children: [
//                             Icon(Icons.people_outline, size: 24, color: AppColors.textColor),
//                             SizedBox(width: 16),
//                             Text(
//                               'team page test',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     DropdownMenuItem(
//                       value: 'create_new',
//                       child: Container(
//                         height: 56,
//                         margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: AppColors.primaryColor, width: 1),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         padding: EdgeInsets.symmetric(horizontal: 12),
//                         child: Row(
//                           children: [
//                             Icon(Icons.add, size: 20, color: AppColors.primaryColor),
//                             SizedBox(width: 12),
//                             Text(
//                               'Create New Team Page',
//                               style: TextStyle(
//                                 color: AppColors.primaryColor,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     // Divider
//                     DropdownMenuItem<String>(
//                       value: 'divider',
//                       enabled: false,
//                       child: Container(
//                         height: 16,
//                         child: Divider(height: 1, color: AppColors.mediumColor, thickness: 1),
//                       ),
//                     ),
//                     // Individual Pages Section
//                     DropdownMenuItem<String>(
//                       value: 'individual_pages_header',
//                       enabled: false,
//                       child: Container(
//                         height: 48,
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             'Individual Pages',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     DropdownMenuItem(
//                       value: 'haneen radad',
//                       child: Container(
//                         height: 56,
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 16,
//                               backgroundColor: Colors.grey[300],
//                               child: Text(
//                                 'H',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 16),
//                             Text(
//                               'haneen radad',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     DropdownMenuItem(
//                       value: 'hanee alhajali',
//                       child: Container(
//                         height: 56,
//                         decoration: BoxDecoration(
//                           color: AppColors.primaryColor.withOpacity(0.08),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         margin: EdgeInsets.symmetric(horizontal: 8),
//                         padding: EdgeInsets.symmetric(horizontal: 8),
//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 16,
//                               backgroundColor: AppColors.primaryColor,
//                               child: Text(
//                                 'H',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 16),
//                             Text(
//                               'hanee alhajali',
//                               style: TextStyle(
//                                 color: AppColors.primaryColor,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             Spacer(),
//                             Icon(Icons.check, size: 24, color: AppColors.primaryColor),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                   onChanged: (value) {
//                     if (value == 'create_new') {
//                       // Handle create new team page
//                     } else if (value != null && ![
//                       'team_pages_header', 
//                       'divider', 
//                       'individual_pages_header'
//                     ].contains(value)) {
//                       setState(() {
//                         _selectedPage = value;
//                       });
//                     }
//                   },
//                 ),
//               ),
//             ),
            
//             // Rest of your content remains the same...
//             Divider(height: 1, thickness: 1, color: AppColors.mediumColor),
//             SizedBox(height: 16),
            
//             Text(
//               'Meet with hanee alhajali',
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textColor,
//               ),
//             ),
//             SizedBox(height: 16),
            
//             Column(
//               children: [
//                 CompositedTransformTarget(
//                   link: _publishLink,
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.backgroundColor,
//                         foregroundColor: AppColors.textColor,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(4),
//                           side: BorderSide(
//                             color: AppColors.mediumColor,
//                             width: 1,
//                           ),
//                         ),
//                         padding: EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       onPressed: _showPublishDropdown,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             _publishStatus == 'Published' ? Icons.visibility : Icons.block,
//                             size: 16,
//                             color: _publishStatus == 'Published' ? Colors.green : Colors.red,
//                           ),
//                           SizedBox(width: 8),
//                           Text(_publishStatus),
//                           SizedBox(width: 8),
//                           Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textColor),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Container(
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: AppColors.backgroundColor,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(4),
//                             bottomLeft: Radius.circular(4),
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
//                           onPressed: () => Navigator.push(
//                             context, 
//                             MaterialPageRoute(builder: (context) => LivePage()),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.open_in_new, size: 16, color: Colors.pink),
//                               SizedBox(width: 8),
//                               Text('View Live'),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: AppColors.backgroundColor,
//                         borderRadius: BorderRadius.only(
//                           topRight: Radius.circular(4),
//                           bottomRight: Radius.circular(4),
//                         ),
//                         border: Border.all(
//                           color: AppColors.mediumColor,
//                           width: 1,
//                         ),
//                       ),
//                       child: TextButton(
//                         style: TextButton.styleFrom(
//                           padding: EdgeInsets.symmetric(horizontal: 16),
//                           foregroundColor: AppColors.textColor,
//                         ),
//                         onPressed: _copyLink,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.link, size: 16, color: Colors.pink),
//                             SizedBox(width: 8),
//                             Text('Copy Link'),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 24),
            
//             Container(
//               child: TabBar(
//                 controller: _tabController,
//                 isScrollable: false,
//                 indicator: UnderlineTabIndicator(
//                   borderSide: BorderSide(
//                     width: 2,
//                     color: AppColors.primaryColor,
//                   ),
//                 ),
//                 labelColor: AppColors.primaryColor,
//                 unselectedLabelColor: AppColors.textColorSecond,
//                 labelStyle: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 unselectedLabelStyle: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.normal,
//                 ),
//                 tabs: [
//                   Tab(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.schedule, size: 20),
//                         SizedBox(width: 8),
//                         Text('Meeting Types'),
//                       ],
//                     ),
//                   ),
//                   Tab(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.settings, size: 20),
//                         SizedBox(width: 8),
//                         Text('Settings'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
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
//     _tabController.dispose();
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
// import 'package:flutter/services.dart'; // For Clipboard

// class PagesContent extends StatefulWidget {
//   @override
//   _PagesContentState createState() => _PagesContentState();
// }

// class _PagesContentState extends State<PagesContent>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool _showPublishMenu = false;
//   String _publishStatus = 'Published';
//   final LayerLink _publishLink = LayerLink();
//   OverlayEntry? _publishOverlayEntry;
//   String _selectedPage = 'hanee alhajali';

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
//                 InkWell(
//                   onTap: () {
//                     setState(() => _publishStatus = 'Published');
//                     _publishOverlayEntry?.remove();
//                   },
//                   child: Container(
//                     padding: EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Icon(Icons.visibility, size: 20, color: Colors.green),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Published', style: TextStyle(fontWeight: FontWeight.bold)),
//                               Text('Attendees are allowed to schedule new meetings',
//                                   style: TextStyle(fontSize: 12, color: Colors.grey)),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Divider(height: 1),
//                 InkWell(
//                   onTap: () {
//                     setState(() => _publishStatus = 'Disabled');
//                     _publishOverlayEntry?.remove();
//                   },
//                   child: Container(
//                     padding: EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Icon(Icons.block, size: 20, color: Colors.red),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Disabled', style: TextStyle(fontWeight: FontWeight.bold)),
//                               Text('Attendees will be prevented from scheduling new meetings',
//                                   style: TextStyle(fontSize: 12, color: Colors.grey)),
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
//             // Updated Dropdown Menu
// Container(
//   margin: EdgeInsets.only(bottom: 16),
//   width: 240, // Reduced width
//   decoration: BoxDecoration(
//     border: Border.all(color: AppColors.mediumColor, width: 1),
//     borderRadius: BorderRadius.circular(8),
//   ),
//   child: DropdownButtonHideUnderline(
//     child: DropdownButton<String>(
//       value: _selectedPage,
//       isExpanded: true,
//       icon: Icon(Icons.arrow_drop_down, size: 20, color: AppColors.textColor),
//       style: TextStyle(
//         color: AppColors.textColor,
//         fontSize: 14,
//       ),
//       dropdownColor: Colors.white,
//       // Remove itemHeight or set it to at least kMinInteractiveDimension (48.0)
//       // itemHeight: 48.0, // Uncomment this if you need fixed height
//       selectedItemBuilder: (context) => [
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 12),
//           height: 48.0, // Ensure minimum height for the selected item
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 12,
//                 backgroundColor: AppColors.primaryColor,
//                 child: Text(
//                   'H',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//               SizedBox(width: 8),
//               Text(
//                 'hanee alhajali',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//       items: [
//         // Team Pages Section
//         DropdownMenuItem<String>(
//           value: 'team_pages_header',
//           enabled: false,
//           child: Container(
//             height: 48.0, // Ensure minimum height
//             padding: EdgeInsets.symmetric(horizontal: 12),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Team Pages',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         DropdownMenuItem(
//           value: 'team page test',
//           child: Container(
//             height: 48.0, // Ensure minimum height
//             padding: EdgeInsets.symmetric(horizontal: 12),
//             child: Row(
//               children: [
//                 Icon(Icons.people_outline, size: 18, color: AppColors.textColor),
//                 SizedBox(width: 8),
//                 Text('team page test'),
//               ],
//             ),
//           ),
//         ),
//         DropdownMenuItem(
//           value: 'create_new',
//           child: Container(
//             height: 48.0, // Ensure minimum height
//             margin: EdgeInsets.symmetric(horizontal: 8),
//             child: Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: AppColors.mediumColor, width: 1),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 8),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.add, size: 16, color: AppColors.primaryColor),
//                   SizedBox(width: 4),
//                   Text(
//                     'Create New Team Page',
//                     style: TextStyle(
//                       color: AppColors.primaryColor,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         // Divider - must also meet height requirements
//         DropdownMenuItem<String>(
//           value: 'divider',
//           enabled: false,
//           child: Container(
//             height: 48.0, // Ensure minimum height
//             child: Divider(height: 1, color: AppColors.mediumColor, thickness: 1),
//           ),
//         ),
//         // Individual Pages Section
//         DropdownMenuItem<String>(
//           value: 'individual_pages_header',
//           enabled: false,
//           child: Container(
//             height: 48.0, // Ensure minimum height
//             padding: EdgeInsets.symmetric(horizontal: 12),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Individual Pages',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         DropdownMenuItem(
//           value: 'haneen radad',
//           child: Container(
//             height: 48.0, // Ensure minimum height
//             padding: EdgeInsets.symmetric(horizontal: 12),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 12,
//                   backgroundColor: Colors.grey[300],
//                   child: Text(
//                     'H',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 Text('haneen radad'),
//               ],
//             ),
//           ),
//         ),
//         DropdownMenuItem(
//           value: 'hanee alhajali',
//           child: Container(
//             height: 48.0, // Ensure minimum height
//             decoration: BoxDecoration(
//               color: AppColors.primaryColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(4),
//             ),
//             margin: EdgeInsets.symmetric(horizontal: 8),
//             padding: EdgeInsets.symmetric(horizontal: 4),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 12,
//                   backgroundColor: AppColors.primaryColor,
//                   child: Text(
//                     'H',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 Text(
//                   'hanee alhajali',
//                   style: TextStyle(
//                     color: AppColors.primaryColor,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Spacer(),
//                 Icon(Icons.check, size: 16, color: AppColors.primaryColor),
//               ],
//             ),
//           ),
//         ),
//       ],
//       onChanged: (value) {
//         if (value == 'create_new') {
//           // Handle create new team page
//         } else if (value != null && ![
//           'team_pages_header', 
//           'divider', 
//           'individual_pages_header'
//         ].contains(value)) {
//           setState(() {
//             _selectedPage = value;
//           });
//         }
//       },
//     ),
//   ),
// ),           
//             // Divider
//             Divider(height: 1, thickness: 1, color: AppColors.mediumColor),
//             SizedBox(height: 16),
            
//             // Title
//             Text(
//               'Meet with hanee alhajali',
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textColor,
//               ),
//             ),
//             SizedBox(height: 16),
            
//             // Buttons Row
//             Column(
//               children: [
//                 // Publish Status Button
//                 CompositedTransformTarget(
//                   link: _publishLink,
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.backgroundColor,
//                         foregroundColor: AppColors.textColor,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(4),
//                           side: BorderSide(
//                             color: AppColors.mediumColor,
//                             width: 1,
//                           ),
//                         ),
//                         padding: EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       onPressed: _showPublishDropdown,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             _publishStatus == 'Published' ? Icons.visibility : Icons.block,
//                             size: 16,
//                             color: _publishStatus == 'Published' ? Colors.green : Colors.red,
//                           ),
//                           SizedBox(width: 8),
//                           Text(_publishStatus),
//                           SizedBox(width: 8),
//                           Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textColor),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 // View Live and Copy Link buttons
//                 Row(
//                   children: [
//                     // View Live Button
//                     Expanded(
//                       child: Container(
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: AppColors.backgroundColor,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(4),
//                             bottomLeft: Radius.circular(4),
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
//                           onPressed: () => Navigator.push(
//                             context, 
//                             MaterialPageRoute(builder: (context) => LivePage()),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.open_in_new, size: 16, color: Colors.pink),
//                               SizedBox(width: 8),
//                               Text('View Live'),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Copy Link Button
//                     Container(
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: AppColors.backgroundColor,
//                         borderRadius: BorderRadius.only(
//                           topRight: Radius.circular(4),
//                           bottomRight: Radius.circular(4),
//                         ),
//                         border: Border.all(
//                           color: AppColors.mediumColor,
//                           width: 1,
//                         ),
//                       ),
//                       child: TextButton(
//                         style: TextButton.styleFrom(
//                           padding: EdgeInsets.symmetric(horizontal: 16),
//                           foregroundColor: AppColors.textColor,
//                         ),
//                         onPressed: _copyLink,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.link, size: 16, color: Colors.pink),
//                             SizedBox(width: 8),
//                             Text('Copy Link'),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 24),
            
//             Container(
//               child: TabBar(
//                 controller: _tabController,
//                 isScrollable: false,
//                 indicator: UnderlineTabIndicator(
//                   borderSide: BorderSide(
//                     width: 2,
//                     color: AppColors.primaryColor,
//                   ),
//                 ),
//                 labelColor: AppColors.primaryColor,
//                 unselectedLabelColor: AppColors.textColorSecond,
//                 labelStyle: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 unselectedLabelStyle: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.normal,
//                 ),
//                 tabs: [
//                   Tab(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.schedule, size: 20),
//                         SizedBox(width: 8),
//                         Text('Meeting Types'),
//                       ],
//                     ),
//                   ),
//                   Tab(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.settings, size: 20),
//                         SizedBox(width: 8),
//                         Text('Settings'),
//                       ],
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
//     _tabController.dispose();
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
// import 'package:flutter/services.dart'; // For Clipboard

// class PagesContent extends StatefulWidget {
//   @override
//   _PagesContentState createState() => _PagesContentState();
// }

// class _PagesContentState extends State<PagesContent>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
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
//                 InkWell(
//                   onTap: () {
//                     setState(() => _publishStatus = 'Published');
//                     _publishOverlayEntry?.remove();
//                   },
//                   child: Container(
//                     padding: EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Icon(Icons.visibility, size: 20, color: Colors.green),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Published', style: TextStyle(fontWeight: FontWeight.bold)),
//                               Text('Attendees are allowed to schedule new meetings',
//                                   style: TextStyle(fontSize: 12, color: Colors.grey)),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Divider(height: 1),
//                 InkWell(
//                   onTap: () {
//                     setState(() => _publishStatus = 'Disabled');
//                     _publishOverlayEntry?.remove();
//                   },
//                   child: Container(
//                     padding: EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Icon(Icons.block, size: 20, color: Colors.red),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Disabled', style: TextStyle(fontWeight: FontWeight.bold)),
//                               Text('Attendees will be prevented from scheduling new meetings',
//                                   style: TextStyle(fontSize: 12, color: Colors.grey)),
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
//             Divider(height: 1, thickness: 1, color: AppColors.mediumColor),
//             SizedBox(height: 16),
            
//             // Title
//             Text(
//               'Meet with شهد ياسين',
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textColor,
//               ),
//             ),
//             SizedBox(height: 16),
            
//             // Buttons Row
//             Column(
//               children: [
//                 // Publish Status Button
//                 CompositedTransformTarget(
//                   link: _publishLink,
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.backgroundColor,
//                         foregroundColor: AppColors.textColor,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(4),
//                           side: BorderSide(
//                             color: AppColors.mediumColor,
//                             width: 1,
//                           ),
//                         ),
//                         padding: EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       onPressed: _showPublishDropdown,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             _publishStatus == 'Published' ? Icons.visibility : Icons.block,
//                             size: 16,
//                             color: _publishStatus == 'Published' ? Colors.green : Colors.red,
//                           ),
//                           SizedBox(width: 8),
//                           Text(_publishStatus),
//                           SizedBox(width: 8),
//                           Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textColor),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 // View Live and Copy Link buttons
//                 Row(
//                   children: [
//                     // View Live Button
//                     Expanded(
//                       child: Container(
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: AppColors.backgroundColor,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(4),
//                             bottomLeft: Radius.circular(4),
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
//                           onPressed: () => Navigator.push(
//                             context, 
//                             MaterialPageRoute(builder: (context) => LivePage()),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.open_in_new, size: 16, color: Colors.pink),
//                               SizedBox(width: 8),
//                               Text('View Live'),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Copy Link Button
//                     Container(
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: AppColors.backgroundColor,
//                         borderRadius: BorderRadius.only(
//                           topRight: Radius.circular(4),
//                           bottomRight: Radius.circular(4),
//                         ),
//                         border: Border.all(
//                           color: AppColors.mediumColor,
//                           width: 1,
//                         ),
//                       ),
//                       child: TextButton(
//                         style: TextButton.styleFrom(
//                           padding: EdgeInsets.symmetric(horizontal: 16),
//                           foregroundColor: AppColors.textColor,
//                         ),
//                         onPressed: _copyLink,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.link, size: 16, color: Colors.pink),
//                             SizedBox(width: 8),
//                             Text('Copy Link'),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 24),
            
//             Container(
//               child: TabBar(
//                 controller: _tabController,
//                 isScrollable: false,
//                 indicator: UnderlineTabIndicator(
//                   borderSide: BorderSide(
//                     width: 2,  // Increased from 2 to 3 for thicker underline
//                     color: AppColors.primaryColor,
//                   ),
//                 ),
//                 labelColor: AppColors.primaryColor,
//                 unselectedLabelColor: AppColors.textColorSecond,
//                 labelStyle: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 unselectedLabelStyle: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.normal,
//                 ),
//                 tabs: [
//                   Tab(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.schedule, size: 20),
//                         SizedBox(width: 8),  // Space between icon and text
//                         Text('Meeting Types'),
//                       ],
//                     ),
//                   ),
//                   Tab(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.settings, size: 20),
//                         SizedBox(width: 8),  // Space between icon and text
//                         Text('Settings'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             // Tab content (unchanged)
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
//     _tabController.dispose();
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