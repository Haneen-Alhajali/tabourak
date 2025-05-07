// lib\content\availability\widgets\create_schedule_modal.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

class CreateScheduleModal extends StatefulWidget {
  const CreateScheduleModal({Key? key}) : super(key: key);

  @override
  State<CreateScheduleModal> createState() => _CreateScheduleModalState();
}

class _CreateScheduleModalState extends State<CreateScheduleModal> {
  final TextEditingController _nameController = TextEditingController();
  bool _isDefault = false;
  bool _isShared = false;
  bool _showNicknameError = false;
  String _selectedTimezone = 'Asia/Hebron';
  
  final Map<String, String> _timezoneDisplayNames = {
    'Asia/Hebron': 'Asia / Hebron',
    'America/New_York': 'America / New York',
    'Europe/London': 'Europe / London',
    'Asia/Tokyo': 'Asia / Tokyo',
    'Australia/Sydney': 'Australia / Sydney',
    'Africa/Cairo': 'Africa / Cairo',
    'Asia/Dubai': 'Asia / Dubai',
    'Europe/Paris': 'Europe / Paris',
    'America/Los_Angeles': 'America / Los Angeles',
    'America/Chicago': 'America / Chicago',
  };

  @override
  void initState() {
    super.initState();
    _initializeTimezones();
  }

  Future<void> _initializeTimezones() async {
    tz.initializeTimeZones();
    
    // Set default timezone based on device locale
    try {
      final deviceLocale = WidgetsBinding.instance.window.locale;
      final deviceTimeZone = await _estimateDeviceTimeZone(deviceLocale);
      if (_timezoneDisplayNames.containsKey(deviceTimeZone)) {
        setState(() {
          _selectedTimezone = deviceTimeZone;
        });
      }
    } catch (e) {
      print('Error estimating timezone: $e');
    }
  }

  Future<String> _estimateDeviceTimeZone(Locale locale) async {
    // Simple estimation based on country code
    switch (locale.countryCode) {
      case 'US':
        return 'America/New_York';
      case 'GB':
        return 'Europe/London';
      case 'JP':
        return 'Asia/Tokyo';
      case 'AU':
        return 'Australia/Sydney';
      case 'EG':
        return 'Africa/Cairo';
      case 'AE':
        return 'Asia/Dubai';
      case 'FR':
        return 'Europe/Paris';
      default:
        return 'Asia/Hebron'; // Default fallback
    }
  }

  String _getCurrentTime(String timezone) {
    try {
      final location = tz.getLocation(timezone);
      final now = tz.TZDateTime.now(location);
      return DateFormat.jm().format(now);
    } catch (e) {
      return '--:-- --';
    }
  }

  void _handleCreate() {
    if (_nameController.text.isEmpty) {
      setState(() {
        _showNicknameError = true;
      });
      return;
    }
    Navigator.of(context).pop({
      'name': _nameController.text,
      'timezone': _selectedTimezone,
      'isDefault': _isDefault,
      'isShared': _isShared,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Create Schedule',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nickname field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nickname',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _showNicknameError ? Colors.red : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'e.g. My Weekly Availability',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: _showNicknameError 
                                  ? Colors.red 
                                  : Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: _showNicknameError
                                  ? Colors.red
                                  : AppColors.primaryColor,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Timezone field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Timezone',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Select Timezone',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _timezoneDisplayNames.length,
                                          itemBuilder: (context, index) {
                                            final tzName = _timezoneDisplayNames.keys.elementAt(index);
                                            return ListTile(
                                              leading: Icon(
                                                Icons.language,
                                                color: AppColors.primaryColor,
                                              ),
                                              title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(_timezoneDisplayNames[tzName]!),
                                                  Text(
                                                    _getCurrentTime(tzName),
                                                    style: TextStyle(
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  _selectedTimezone = tzName;
                                                });
                                                Navigator.pop(context);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.language,
                                  color: AppColors.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_timezoneDisplayNames[_selectedTimezone] ?? 'Asia / Hebron'),
                                      Text(
                                        _getCurrentTime(_selectedTimezone),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Default toggle
                    Row(
                      children: [
                        SizedBox(
                          width: 36,
                          height: 20,
                          child: Switch(
                            value: _isDefault,
                            onChanged: (value) {
                              setState(() {
                                _isDefault = value;
                              });
                            },
                            activeColor: AppColors.primaryColor,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Use this schedule for new meeting types'),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Footer with create button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: ElevatedButton(
                onPressed: _handleCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'Create Schedule',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}