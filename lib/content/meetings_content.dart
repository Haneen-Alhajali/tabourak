import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tabourak/config/config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:url_launcher/url_launcher.dart'; // For launching Zoom links
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class MeetingsContent extends StatefulWidget {
  @override
  _MeetingsContentState createState() => _MeetingsContentState();
}

class _MeetingsContentState extends State<MeetingsContent> {
  List<dynamic> meetings = [];
  List<dynamic> filteredMeetings = [];
  String selectedFilter = 'Today';
  bool isLoading = true;
  String searchQuery = '';
  int memberID = 1;

  @override
  void initState() {
    super.initState();
    fetchMeetings();
  }

  Future<void> fetchMeetings() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/meetingsShowPage/$memberID'),
      );

      if (response.statusCode == 200) {
        setState(() {
          meetings = json.decode(response.body);
          filterMeetings(selectedFilter);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load meetings');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching meetings: $e');
    }
  }

  void filterMeetings(String filter) {
    setState(() {
      selectedFilter = filter;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      switch (filter) {
        case 'Today':
          filteredMeetings =
              meetings.where((meeting) {
                final meetingDate = DateTime.parse(meeting['date']).toLocal();
                return meetingDate.year == today.year &&
                    meetingDate.month == today.month &&
                    meetingDate.day == today.day;
              }).toList();
          break;
        case 'Tomorrow':
          final tomorrow = today.add(Duration(days: 1));
          filteredMeetings =
              meetings.where((meeting) {
                final meetingDate = DateTime.parse(meeting['date']).toLocal();
                return meetingDate.year == tomorrow.year &&
                    meetingDate.month == tomorrow.month &&
                    meetingDate.day == tomorrow.day;
              }).toList();
          break;
        case 'Next 7 Days':
          final nextWeek = today.add(Duration(days: 7));
          filteredMeetings =
              meetings.where((meeting) {
                final meetingDate = DateTime.parse(meeting['date']).toLocal();
                return meetingDate.isAfter(today.subtract(Duration(days: 1))) &&
                    meetingDate.isBefore(nextWeek.add(Duration(days: 1)));
              }).toList();
          break;
        case 'Next 30 Days':
          final nextMonth = today.add(Duration(days: 30));
          filteredMeetings =
              meetings.where((meeting) {
                final meetingDate = DateTime.parse(meeting['date']).toLocal();
                return meetingDate.isAfter(today.subtract(Duration(days: 1))) &&
                    meetingDate.isBefore(nextMonth.add(Duration(days: 1)));
              }).toList();
          break;
        case 'Past':
          filteredMeetings =
              meetings.where((meeting) {
                final meetingDate = DateTime.parse(meeting['date']).toLocal();
                return meetingDate.isBefore(today);
              }).toList();
          break;
        case 'Upcoming':
        default:
          filteredMeetings =
              meetings.where((meeting) {
                final meetingDate = DateTime.parse(meeting['date']).toLocal();
                return meetingDate.isAfter(today.subtract(Duration(days: 1)));
              }).toList();
          break;
      }

      // Apply search filter if there's a query
      if (searchQuery.isNotEmpty) {
        filteredMeetings =
            filteredMeetings.where((meeting) {
              return meeting['appointment_name'].toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  meeting['user']['name'].toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  );
            }).toList();
      }

      // Sort meetings by date
      filteredMeetings.sort((a, b) {
        return DateTime.parse(a['date']).compareTo(DateTime.parse(b['date']));
      });
    });
  }

  void onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    filterMeetings(selectedFilter);
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////

  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();

      if (!status.isGranted) {
        await openAppSettings();
        return;
      }
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////
  Future<void> downloadCSVFile(int memberId) async {
    try {
      // فقط اطبعي إن الجهاز أندرويد
      if (Platform.isAndroid) {
        print("🔴🔴🔴🔴🔴Platform.isAndroid🔴🔴🔴🔴🔴");
      }

      final url = '${AppConfig.baseUrl}/api/export-by-member/$memberId';

      final directory = Directory('/storage/emulated/0/Download');
      final savePath = '${directory.path}/meeting_data_$memberId.csv';

      print('♻️ dir: $directory');
      print('♻️ savePath: $savePath');

      final dio = Dio();
      await dio.download(url, savePath);

      print('✅ File downloaded to $savePath');
    } catch (e) {
      print('❌ Error downloading file: $e');
    }
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Meetings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            /*  ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.mediumColor,
              ),
              child: Text(
                '+ Schedule Meeting',
                style: TextStyle(color: AppColors.textColor),
              ),
            ),*/
          ],
        ),
        SizedBox(height: 16),

        // Filters and Search
        Row(
          children: [
            // Dropdown Filter
            Container(
              padding: EdgeInsets.only(left: 8, top: 6, bottom: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textColor),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedFilter,
                  items:
                      [
                        {'label': 'Upcoming', 'icon': Icons.calendar_today},
                        {'label': 'Past', 'icon': Icons.history},
                        {'label': 'Today', 'icon': Icons.today},
                        {'label': 'Tomorrow', 'icon': Icons.next_week},
                        {
                          'label': 'Next 7 Days',
                          'icon': Icons.calendar_view_week,
                        },
                        {'label': 'Next 30 Days', 'icon': Icons.calendar_today},
                      ].map((item) {
                        return DropdownMenuItem<String>(
                          value: item['label'] as String,
                          child: Row(
                            children: [
                              Icon(item['icon'] as IconData, size: 18),
                              SizedBox(width: 8),
                              Text(
                                item['label'] as String,
                                style: TextStyle(
                                  color: AppColors.textColorSecond,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      filterMeetings(value);
                    }
                  },
                  isDense: true,
                ),
              ),
            ),
            SizedBox(width: 12),

            // Search Field
            Expanded(
              child: Container(
                height: 40,
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: AppColors.textColorSecond),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: AppColors.textColor,
                    ),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 8,
                    ),
                    isDense: true,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ),

            // Menu Button
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppColors.textColor),
              onSelected: (value) async {
                if (value == 'export') {
                  await requestStoragePermission();

                  await downloadCSVFile(1);
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem<String>(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.download, color: AppColors.textColor),
                          SizedBox(width: 8),
                          Text('Export Meeting Data (CSV)'),
                        ],
                      ),
                    ),
                  ],
            ),

            /*
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppColors.textColor),
              onSelected: (value) {
                if (value == 'export') {
                  // TODO: export functionality
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem<String>(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.download, color: AppColors.textColor),
                          SizedBox(width: 8),
                          Text('Export Meeting Data (CSV)'),
                        ],
                      ),
                    ),
                  ],
            ),*/
          ],
        ),

        SizedBox(height: 6),
        Divider(),
        SizedBox(height: 16),

        if (isLoading)
          Center(child: CircularProgressIndicator())
        else if (filteredMeetings.isEmpty)
          Center(
            child: Column(
              children: [
                Image.asset('images/no-event-bg.png', width: 400),
                SizedBox(height: 16),
                Text(
                  'No meetings found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                Text(
                  'Try removing or adjusting your filters.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textColorSecond,
                  ),
                ),
              ],
            ),
          )
        else
          _buildMeetingsList(),
      ],
    );
  }

  Widget _buildMeetingsList() {
    // Group meetings by date
    Map<String, List<dynamic>> groupedMeetings = {};

    for (var meeting in filteredMeetings) {
      final meetingDate = DateTime.parse(meeting['date']).toLocal();
      // Format the date key as yyyy-MM-dd to ensure proper parsing
      final dateKey =
          "${meetingDate.year}-${meetingDate.month.toString().padLeft(2, '0')}-${meetingDate.day.toString().padLeft(2, '0')}";

      if (!groupedMeetings.containsKey(dateKey)) {
        groupedMeetings[dateKey] = [];
      }
      groupedMeetings[dateKey]!.add(meeting);
    }

    // Sort dates in ascending order
    var sortedDates =
        groupedMeetings.keys.toList()
          ..sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          sortedDates.map((dateKey) {
            final meetingsForDate = groupedMeetings[dateKey]!;
            meetingsForDate.sort(
              (a, b) => DateTime.parse(
                a['start_time'],
              ).compareTo(DateTime.parse(b['start_time'])),
            );

            final Map<String, List<Map<String, dynamic>>> groupedByStartTime =
                {};

            for (var meeting in meetingsForDate) {
              final startTime = meeting['start_time'];
              if (!groupedByStartTime.containsKey(startTime)) {
                groupedByStartTime[startTime] = [];
              }
              groupedByStartTime[startTime]!.add(meeting);
            }

            // Parse the properly formatted dateKey
            final date = DateTime.parse(dateKey);
            final formattedDate =
                "${_getWeekday(date)}\n${_getFormattedDate(date)}";

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 8),
                ...groupedByStartTime.entries.map((entry) {
                  final sameTimeMeetings = entry.value;
                  final mainMeeting = sameTimeMeetings.first;

                  final startTime =
                      DateTime.parse(mainMeeting['start_time']).toLocal();
                  final endTime =
                      DateTime.parse(mainMeeting['end_time']).toLocal();
                  final timeString =
                      "${_formatTime(startTime)} - ${_formatTime(endTime)}";

                  // ✨ نأخذ أول اسم ونجهز كل الـ user ids
                  final firstUser = mainMeeting['user'];

                  final allClients =
                      sameTimeMeetings.map((m) {
                        return {
                          'id': m['user']['id'],
                          'name': m['user']['name'],
                          'email': m['user']['email'],
                        };
                      }).toList();

                  return MeetingCard(
                    time: timeString,
                    appointmentName: mainMeeting['appointment_name'],
                    name: firstUser['name'],
                    showZoomButton: mainMeeting['meeting_type'] == 'video_call',
                    meeting_type: mainMeeting['meeting_type'],
                    meeting_id: mainMeeting['meeting_id'],
                    dataMeeting: mainMeeting['meeting_detail'] ?? 'no link',
                    clientEmail: firstUser['email'],
                    clientId: firstUser['id'],
                    dateMeeting: formattedDate,
                    memberID: memberID,
                    allClients: allClients,
                    onMeetingDeleted: () async {
                      await fetchMeetings();
                      setState(() {});
                    },
                  );
                }).toList(),

                SizedBox(height: 16),
              ],
            );
          }).toList(),
    );
  }

  String _getWeekday(DateTime date) {
    return [
      'SUNDAY',
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
    ][date.weekday % 7];
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}

class MeetingCard extends StatelessWidget {
  final String time;
  final String appointmentName;
  final String name;
  final bool showZoomButton;
  final String meeting_type;
  final int meeting_id;
  final String dataMeeting;
  final String clientEmail;
  final int clientId;
  final String dateMeeting;
  final int memberID;
  final Function onMeetingDeleted;
  final List<Map<String, dynamic>> allClients;

  const MeetingCard({
    required this.time,
    required this.appointmentName,
    required this.name,
    this.showZoomButton = false,
    required this.meeting_type,
    required this.meeting_id,
    required this.dataMeeting,
    required this.clientEmail,
    required this.clientId,
    required this.dateMeeting,
    required this.memberID,
    required this.onMeetingDeleted,
    required this.allClients,
  });
  ////////////////////////////////////////////////////////////////////////////

  Future<bool> deleteMeetingFromDatabase(int meetingId) async {
    final url = Uri.parse(
      '${AppConfig.baseUrl}/zoom/delete-meeting-from-database',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'meeting_id': meetingId}),
    );

    if (response.statusCode == 200) {
      print('✅ تم الحذف من قاعدة البيانات');
      return true;
    } else {
      print('❌ فشل الحذف: ${response.body}');
      return false;
    }
  }

  ////////////////////////////////////////////////

  Future<void> deleteZoomMeeting(int bookingId, int memberId) async {
    final url = Uri.parse(
      '${AppConfig.baseUrl}/zoom/delete-meeting-by-booking',
    );

    final body = jsonEncode({'booking_id': bookingId, 'member_id': memberId});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Success: ${data['message']}');
      } else {
        final errorData = jsonDecode(response.body);
        print('Error: ${errorData['error']}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textColorSecond),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.mediumColor,
                  child: Text(
                    getInitials(name),
                    style: TextStyle(color: AppColors.textColorSecond),
                  ),
                ),

                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      if (appointmentName.isNotEmpty)
                        Text(
                          appointmentName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textColorSecond,
                          ),
                        ),
                      Text(name, style: TextStyle(color: AppColors.textColor)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color: AppColors.backgroundColor,
                  onSelected: (String value) async {
                    if (value == 'delete') {
                      bool deleted = true;

                      if (meeting_type == 'video_call') {
                        deleteZoomMeeting(meeting_id, memberID);
                      }
                      deleted = await deleteMeetingFromDatabase(meeting_id);
                      if (deleted) {
                        onMeetingDeleted();
                      }
                    } else if (value == 'view') {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (
                                context,
                                animation,
                                secondaryAnimation,
                              ) => MeetingDetailsPage(
                                meetingId: meeting_id,
                                meetingName: appointmentName,
                                meetingTime: time,
                                clientName: name,
                                clientEmail:
                                    clientEmail, // You'll need to get this from your data
                                meetingType: meeting_type,
                                dataMeeting: dataMeeting,
                                clientId: clientId,
                                dateMeeting: dateMeeting,
                                allClients: allClients,
                              ),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            const begin = Offset(1.0, 0.0); // من اليمين
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(
                                Icons.remove_red_eye,
                                color: AppColors.textColor,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'View Details',
                                style: TextStyle(color: AppColors.textColor),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, color: AppColors.textColor),
                              SizedBox(width: 10),
                              Text(
                                'Cancel',
                                style: TextStyle(color: AppColors.textColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            if (showZoomButton) ...[
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: () {
                    launchUrl(Uri.parse(dataMeeting));
                  },
                  icon: Icon(
                    Icons.videocam,
                    size: 18,
                    color: AppColors.primaryColor,
                  ),
                  label: Text('Join Zoom'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundColor,
                    foregroundColor: AppColors.textColor,
                    side: BorderSide(color: AppColors.textColorSecond),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MeetingDetailsPage extends StatefulWidget {
  final int meetingId;
  final String meetingName;
  final String meetingTime;
  final String clientName;
  final String clientEmail;
  final String meetingType;
  final dynamic dataMeeting;
  final int clientId;
  final String dateMeeting;
  final List<Map<String, dynamic>> allClients;

  MeetingDetailsPage({
    required this.meetingId,
    required this.meetingName,
    required this.meetingTime,
    required this.clientName,
    required this.clientEmail,
    required this.meetingType,
    required this.dataMeeting,
    required this.clientId,
    required this.dateMeeting,
    required this.allClients,
  });

  @override
  _MeetingDetailsPageState createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  LatLng? meetingLocation;
  bool isLoading = true;
  List<dynamic> responses = [];
  Map<int, List<dynamic>> userResponses = {};

  @override
  void initState() {
    super.initState();

    if (widget.meetingType == 'in_person') {
      loadCoordinates();
    } else {
      isLoading = false;
    }

    loadAllResponses(); // الجديد
  }

  void loadAllResponses() async {
    for (var user in widget.allClients) {
      try {
        final data = await fetchFormResponses(user['id']);
        setState(() {
          userResponses[user['id']] = data;
        });
      } catch (e) {
        print('❌ Error loading responses for user ${user['id']}: $e');
      }
    }
  }

  /*
  @override
  void initState() {
    super.initState();
    if (widget.meetingType == 'in_person') {
      loadCoordinates();
    } else {
      setState(() {
        isLoading = false;
      });
    }
    loadResponses();
  }*/

  void loadResponses() async {
    try {
      final data = await fetchFormResponses(widget.clientId);
      setState(() {
        responses = data;
      });
    } catch (e) {
      print('Error loading responses: $e');
    }
  }

  Future<List<dynamic>> fetchFormResponses(int userId) async {
    final responsesUrl = Uri.parse(
      '${AppConfig.baseUrl}/api/responses_user_info/$userId',
    );
    final responsesResponse = await http.get(responsesUrl);

    if (responsesResponse.statusCode != 200) {
      throw Exception('Failed to load response data');
    }

    final List<dynamic> responses = jsonDecode(responsesResponse.body);
    return responses;
  }

  Future<void> loadCoordinates() async {
    if (widget.dataMeeting != null) {
      LatLng? coordinates = await getCoordinatesFromAddress(widget.dataMeeting);
      setState(() {
        meetingLocation = coordinates;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildMeetingSpecificContent() {
    switch (widget.meetingType) {
      case 'in_person':
        return Column(
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  widget.dataMeeting ?? 'No location provided',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (meetingLocation != null)
              SizedBox(
                height: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: meetingLocation!,
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId("meeting_location"),
                        position: meetingLocation!,
                      ),
                    },
                    zoomControlsEnabled: false,
                    liteModeEnabled: false,
                  ),
                ),
              )
            else
              Text("Location map not available"),
          ],
        );
      case 'video_call':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Zoom Meeting Link",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: widget.dataMeeting ?? ''),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Zoom link copied to clipboard")),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    //  Icon(Icons.videocam, color: AppColors.textColorSecond),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.dataMeeting ?? 'No Zoom link provided',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                    Icon(Icons.copy, size: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      case 'phone_call':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Phone Number",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: widget.dataMeeting ?? ''),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Phone number copied to clipboard")),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone, color: AppColors.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.dataMeeting ?? 'No phone number provided',
                      ),
                    ),
                    Icon(Icons.copy, size: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meeting Details")),
      backgroundColor: AppColors.backgroundColor,

      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.meetingName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.dateMeeting.toString(),
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.meetingTime,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Dynamic content based on meeting type
                    _buildMeetingSpecificContent(),

                    const SizedBox(height: 24),
                    const Divider(color: Colors.grey, thickness: 1),
                    const Text(
                      "Participants",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // كارد الـ Host
                        Row(
                          children: [
                            CircleAvatar(
                              child: Text(
                                getInitials("You"),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              backgroundColor: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Text("You", style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Host",
                                style: TextStyle(
                                  color: AppColors.backgroundColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // كارد ثابت فيه clientName وclientEmail وresponses
                      /*  buildClientCard(
                          widget.clientName,
                          widget.clientEmail,
                          responses,
                        ),*/

                        const SizedBox(height: 30),

                        // عرض كل الكلاينتس (البقية)
                        ...widget.allClients.map((client) {
                          final clientResponses =
                              userResponses[client['id']] ?? [];
                          return buildClientCard(
                            client['name'],
                            client['email'],
                            clientResponses,
                          );
                        }).toList(),
                      ],
                    ),

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                  ],
                ),
              ),
    );
  }
}









Widget buildClientCard(String name, String email, List responses) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              child: Text(getInitials(name)),
            ),
            title: Text(name),
            subtitle: Text(email),
            trailing: Icon(Icons.more_vert),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 217, 244, 247),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: responses.map<Widget>((item) {
                final label = item['label'] ?? '';
                final answer = item['response_text'] ?? '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        answer.toString(),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ),
  );
}

/*
class MeetingDetailsPage extends StatefulWidget {
  final int meetingId;

  MeetingDetailsPage(this.meetingId);

  @override
  _MeetingDetailsPageState createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  final String meetingType = "In-Person Meeting";
  final String dateTimeRange = "10:00 AM - 10:30 AM, May 6, 2025 (GMT+3)";
  final String locationText = "nablus palestain";
  final String guestName = "shahd yaseen";
  final String guestEmail = "shahdthabityaseen@gmail.com";
  final List<String> labels = ["4:45 PM", "May 22, 2025", "🔄"];

  LatLng? meetingLocation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCoordinates();
  }

  Future<void> loadCoordinates() async {
    LatLng? coordinates = await getCoordinatesFromAddress(locationText);
    setState(() {
      meetingLocation = coordinates;
      isLoading = false;
    });
  }

  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        print("🎨🎨🎨🎨🎨🎨🎨🎨" + location.toString());
        return LatLng(location.latitude, location.longitude);
      }
    } catch (e) {
      print("خطأ في تحديد الموقع: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meeting Details")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meetingType,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateTimeRange,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(locationText, style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (meetingLocation != null)
                      SizedBox(
                        height: 180,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: meetingLocation!,
                              zoom: 14,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId("meeting_location"),
                                position: meetingLocation!,
                              ),
                            },
                            zoomControlsEnabled: false,
                            liteModeEnabled: false,
                          ),
                        ),
                      )
                    else
                      Text("The location could not be determined"),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          child: Text(
                            "ش",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          backgroundColor: Colors.green,
                        ),
                        const SizedBox(width: 10),
                        Text("You", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Host",
                            style: TextStyle(color: Colors.green[800]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: CircleAvatar(child: Text("SY")),
                      title: Text(guestName),
                      subtitle: Text(guestEmail),
                      trailing: Icon(Icons.more_vert),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            labels.map((labelValue) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Label",
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    Text(
                                      labelValue,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
*/
String getInitials(String name) {
  List<String> parts = name.trim().split(' ');
  if (parts.length >= 2) {
    return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
  } else if (parts.length == 1 && parts[0].isNotEmpty) {
    return parts[0][0].toUpperCase();
  } else {
    return '';
  }
}

Future<LatLng?> getCoordinatesFromAddress(String address) async {
  try {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      final location = locations.first;
      return LatLng(location.latitude, location.longitude);
    }
  } catch (e) {
    print("error in location : $e");
  }
  return null;
}

/*
class MeetingDetailsPage extends StatelessWidget {
  final String meetingType = "In-Person Meeting";
  final String dateTimeRange = "10:00 AM - 10:30 AM, May 6, 2025 (GMT+3)";
  final String locationText = "فلسطين، نابلس";
  final LatLng meetingLocation = LatLng(32.2211, 35.2544); // إحداثيات نابلس كمثال
  final String guestName = "shahd yaseen";
  final String guestEmail = "shahdthabityaseen@gmail.com";
  final List<String> labels = ["4:45 PM", "May 22, 2025", "🔄"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meeting Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meetingType,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(dateTimeRange, style: TextStyle(color: Colors.grey[700])),

            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Text(locationText, style: TextStyle(fontSize: 16)),
              ],
            ),

            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: meetingLocation,
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId("meeting_location"),
                      position: meetingLocation,
                    )
                  },
                  zoomControlsEnabled: false,
                  liteModeEnabled: true,
                ),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent),
                  child: const Text("ATTENDEES (1)"),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text("NOTES"),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  child: Text("ش",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  backgroundColor: Colors.green,
                ),
                const SizedBox(width: 10),
                Text("You", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("Host",
                      style: TextStyle(color: Colors.green[800])),
                )
              ],
            ),

            const SizedBox(height: 20),
            ListTile(
              leading: CircleAvatar(child: Text("SY")),
              title: Text(guestName),
              subtitle: Text(guestEmail),
              trailing: Icon(Icons.more_vert),
            ),

            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: labels.map((labelValue) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Label", style: TextStyle(color: Colors.grey[600])),
                        Text(labelValue,
                            style: TextStyle(fontSize: 16, color: Colors.black)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

*/
