import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'MeetingTypesTab.dart'; // Import the MeetingTypesTab file
import 'SettingsTab.dart'; // Import the SettingsTab file

class PagesContent extends StatefulWidget {
  @override
  _PagesContentState createState() => _PagesContentState();
}

class _PagesContentState extends State<PagesContent>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  int meetingTypes = 2;
  int teamMembers = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Row(
  children: [
    CircleAvatar(
      backgroundColor: AppColors.primaryColor,
      child: Text(
        'ش',
        style: TextStyle(color: Colors.white),
      ),
    ),
    SizedBox(width: 8),
    Expanded(
      child: DropdownButton<String>(
        value: 'شهد ياسين',
        icon: Icon(Icons.arrow_drop_down),
        isExpanded: true,
        underline: SizedBox(),
        items: [
          DropdownMenuItem(value: 'شهد ياسين', child: Text('شهد ياسين')),
        ],
        onChanged: (value) {},
      ),
    ),
  ],
),
SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
  'Meet with شهد ياسين',
  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
),
SizedBox(height: 12),

              SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: Builder(
                  builder: (context) {
                    return GestureDetector(
                      onTapDown: (TapDownDetails details) async {
                        final RenderBox overlay =
                            Overlay.of(context).context.findRenderObject()
                                as RenderBox;
                        final selected = await showMenu<String>(
                          context: context,
                          position: RelativeRect.fromRect(
                            details.globalPosition & Size(40, 40),
                            Offset.zero & overlay.size,
                          ),
                          items: [
                            PopupMenuItem<String>(
                              value: 'Publish',
                              child: SizedBox(
                                width:
                                    MediaQuery.of(context).size.width -
                                    32, // 16 left + 16 right padding
                                child: Text(
                                  'Publish',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'Disabled',
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width - 32,
                                child: Text(
                                  'Disabled',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                          elevation: 8,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                        if (selected != null) {
                          if (selected == 'Publish') {
                            print('Published!');
                          } else if (selected == 'Disabled') {
                            print('Disabled selected');
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Publish',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_drop_down, color: Colors.white),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LivePage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    'View Live',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: AppColors.backgroundColor,
          unselectedLabelColor: AppColors.textColor,
          indicator: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          labelPadding: EdgeInsets.symmetric(horizontal: 2),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule),
                  SizedBox(width: 5),
                  Text('Meeting Types', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group),
                  SizedBox(width: 5),
                  Text('Team Members', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 5),
                  Text('Settings', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - 180,
          child: TabBarView(
            controller: _tabController,
            children: [
              Center(child: MeetingTypesTab()),
              Center(
                child: Text('Team Members', style: TextStyle(fontSize: 14)),
              ),
              Center(child: SettingsTab()),
            ],
          ),
        ),
      ],
    );
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
