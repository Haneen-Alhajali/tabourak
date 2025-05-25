// lib\content\members_content.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'invite_members_dialog.dart';

class MembersContent extends StatefulWidget {
  @override
  _MembersContentState createState() => _MembersContentState();
}

class _MembersContentState extends State<MembersContent> {
  int _activeTabIndex = 0;
  List<Map<String, dynamic>> activeMembers = [
    {
      'name': 'Shahd Yaseen',
      'email': 'shadhabit@gmail.com',
      'role': 'Owner',
      'isCurrentUser': true,
      'imageUrl': 'images/img.JPG',
      'status': 'Active',
    },
    {
      'name': 'Another Member',
      'email': 'member@example.com',
      'role': 'Member',
      'isCurrentUser': false,
      'imageUrl': '',
      'status': 'Active',
    },
  ];
  
  List<Map<String, dynamic>> deactivatedMembers = [
    {
      'name': 'Inactive Member',
      'email': 'inactive@example.com',
      'role': 'Member',
      'isCurrentUser': false,
      'imageUrl': '',
      'status': 'Deactivated',
    },
  ];

  void _changeRole(String email, String newRole) {
    setState(() {
      var member = activeMembers.firstWhere(
        (m) => m['email'] == email,
        orElse: () => deactivatedMembers.firstWhere((m) => m['email'] == email),
      );
      member['role'] = newRole;
    });
  }

  void _toggleStatus(String email, String currentStatus) {
    setState(() {
      if (currentStatus == 'Active') {
        var member = activeMembers.firstWhere((m) => m['email'] == email);
        member['status'] = 'Deactivated';
        deactivatedMembers.add(member);
        activeMembers.removeWhere((m) => m['email'] == email);
      } else {
        var member = deactivatedMembers.firstWhere((m) => m['email'] == email);
        member['status'] = 'Active';
        activeMembers.add(member);
        deactivatedMembers.removeWhere((m) => m['email'] == email);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: Column(
        children: [
          // Header section
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Members",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => InviteMembersDialog(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.lightcolor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16, color: AppColors.lightcolor),
                          SizedBox(width: 6),
                          Text("Invite Members"),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Tabs
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _activeTabIndex = 0),
                      child: _buildTab(
                        "Active (${activeMembers.length})", 
                        _activeTabIndex == 0
                      ),
                    ),
                    SizedBox(width: 24),
                    GestureDetector(
                      onTap: deactivatedMembers.isEmpty 
                          ? null 
                          : () => setState(() => _activeTabIndex = 1),
                      child: _buildTab(
                        "Deactivated (${deactivatedMembers.length})", 
                        _activeTabIndex == 1,
                        isDisabled: deactivatedMembers.isEmpty,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Divider
          Divider(height: 1, color: Colors.grey[300]),
          
          // Members list
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Table header (hidden on small screens)
                    MediaQuery.of(context).size.width > 600 ? _buildTableHeader() : SizedBox(),
                    
                    // Member items based on active tab
                    ...(_activeTabIndex == 0 ? activeMembers : deactivatedMembers).map((member) {
                      return Column(
                        children: [
                          _buildMemberItem(
                            context,
                            name: member['name'],
                            email: member['email'],
                            role: member['role'],
                            isCurrentUser: member['isCurrentUser'],
                            imageUrl: member['imageUrl'],
                            status: member['status'],
                            onChangeRole: (newRole) => _changeRole(member['email'], newRole),
                            onToggleStatus: () => _toggleStatus(member['email'], member['status']),
                          ),
                          Divider(height: 1, color: Colors.grey[300]),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isActive, {bool isDisabled = false}) {
    return Container(
      padding: EdgeInsets.only(bottom: 6),
      decoration: isActive
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primaryColor,
                  width: 3,
                ),
              ),
            )
          : null,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isActive 
              ? AppColors.primaryColor 
              : isDisabled 
                  ? Colors.grey 
                  : AppColors.textColorSecond,
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "MEMBERS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textColorSecond,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "ROLE",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textColorSecond,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "STATUS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textColorSecond,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(
    BuildContext context, {
    required String name,
    required String email,
    required String role,
    required bool isCurrentUser,
    required String imageUrl,
    required String status,
    required Function(String) onChangeRole,
    required Function() onToggleStatus,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: isSmallScreen
          ? _buildMobileMemberItem(
              name, email, role, isCurrentUser, imageUrl, status, onChangeRole, onToggleStatus)
          : _buildDesktopMemberItem(
              name, email, role, isCurrentUser, imageUrl, status, onChangeRole, onToggleStatus),
    );
  }

  Widget _buildMobileMemberItem(
    String name,
    String email,
    String role,
    bool isCurrentUser,
    String imageUrl,
    String status,
    Function(String) onChangeRole,
    Function() onToggleStatus,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: imageUrl.isNotEmpty 
                  ? AssetImage(imageUrl) 
                  : null,
              child: imageUrl.isEmpty 
                  ? Text(name.substring(0, 2).toUpperCase(), 
                      style: TextStyle(color: AppColors.lightcolor))
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name + (isCurrentUser ? " (You)" : ""),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            _buildMoreOptionsButton(isCurrentUser, status, onToggleStatus),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            SizedBox(width: 52),
            _buildRoleDropdown(role, isCurrentUser, onChangeRole),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: status == 'Active' 
                    ? AppColors.primaryColor 
                    : Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.lightcolor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopMemberItem(
    String name,
    String email,
    String role,
    bool isCurrentUser,
    String imageUrl,
    String status,
    Function(String) onChangeRole,
    Function() onToggleStatus,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: imageUrl.isNotEmpty 
                    ? AssetImage(imageUrl) 
                    : null,
                child: imageUrl.isEmpty 
                    ? Text(name.substring(0, 2).toUpperCase(), 
                        style: TextStyle(color: AppColors.lightcolor))
                    : null,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name + (isCurrentUser ? " (You)" : ""),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildRoleDropdown(role, isCurrentUser, onChangeRole),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: status == 'Active' 
                  ? AppColors.primaryColor 
                  : Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.lightcolor,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: _buildMoreOptionsButton(isCurrentUser, status, onToggleStatus),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleDropdown(
    String currentRole, 
    bool isCurrentUser,
    Function(String) onChangeRole,
  ) {
    return PopupMenuButton<String>(
      enabled: !isCurrentUser,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'Member',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Member',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              Text(
                'Can view and edit their scheduling page and their meetings',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textColorSecond,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'Manager',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manager',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              Text(
                'Can view and edit any scheduling page and meetings',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textColorSecond,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'Admin',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              Text(
                'Full control over the account',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textColorSecond,
                ),
              ),
            ],
          ),
        ),
        if (!isCurrentUser) PopupMenuDivider(),
        if (!isCurrentUser) PopupMenuItem(
          value: 'Transfer Ownership',
          child: Text('Transfer Ownership'),
        ),
      ],
      onSelected: (value) {
        if (value != 'Transfer Ownership') {
          onChangeRole(value);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.lightcolor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentRole,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textColor,
              ),
            ),
            if (!isCurrentUser) Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOptionsButton(
    bool isCurrentUser,
    String status,
    Function() onToggleStatus,
  ) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      enabled: !isCurrentUser,
      itemBuilder: (context) => [
        if (status == 'Active')
          PopupMenuItem(
            child: Text('Deactivate'),
            onTap: onToggleStatus,
          ),
        if (status != 'Active')
          PopupMenuItem(
            child: Text('Activate'),
            onTap: onToggleStatus,
          ),
      ],
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';

// class MembersContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           width: double.infinity,
//           padding: EdgeInsets.all(16),
//           color: AppColors.backgroundColor,
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Members",
//                     style: TextStyle(
//                       color: AppColors.textColor,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                     ),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: () {},
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryColor,
//                       foregroundColor: AppColors.lightcolor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     icon: Icon(Icons.add),
//                     label: Text("Invite Members"),
//                   ),
//                 ],
//               ),
//               Divider(height: 1, color: Colors.grey[300]),
//               SizedBox(height: 16),

//               Row(
//                 children: [
//                   _buildTab("Active (1)", true),
//                   _buildTab("Deactivated (0)", false),
//                 ],
//               ),
//               SizedBox(height: 16),
//             ],
//           ),
//         ),

//         Container(
//           width: double.infinity,
//           height: MediaQuery.of(context).size.height * 0.6,
//           padding: EdgeInsets.all(16),
//           child: ListView(
//             children: [
//               _buildMemberCard(
//                 imageUrl: "images/img.JPG",
//                 name: "Shahd Yaseen",
//                 email: "shadhabit@gmail.com",
//                 role: "Owner",
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTab(String title, bool isActive) {
//     return Padding(
//       padding: EdgeInsets.only(right: 16),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: isActive ? AppColors.textColor : AppColors.textColorSecond,
//           decoration: isActive ? TextDecoration.underline : TextDecoration.none,
//         ),
//       ),
//     );
//   }

//   Widget _buildMemberCard({
//     required String imageUrl,
//     required String name,
//     required String email,
//     required String role,
//   }) {
//     return Card(
//       color: AppColors.mediumColor,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       child: Padding(
//         padding: EdgeInsets.all(12),
//         child: Row(
//           children: [
//             CircleAvatar(backgroundImage: AssetImage(imageUrl), radius: 25),
//             SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   Text(email, style: TextStyle(color: AppColors.secondaryColor)),
//                   Text(role, style: TextStyle(color: AppColors.textColorSecond)),
//                 ],
//               ),
//             ),
//             IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
//           ],
//         ),
//       ),
//     );
//   }
// }
