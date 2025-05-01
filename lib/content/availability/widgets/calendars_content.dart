// lib\content\availability\widgets\calendars_content.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';

class CalendarsContent extends StatefulWidget {
  const CalendarsContent({Key? key}) : super(key: key);

  @override
  _CalendarsContentState createState() => _CalendarsContentState();
}

class _CalendarsContentState extends State<CalendarsContent> {
  bool _isSyncCalendarChanges = true;
  bool _isEmailInvitations = false; 

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          const Text(
            'Calendars',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Integrate your calendars to prevent double bookings and have your meetings automatically added.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textColorSecond,
            ),
          ),
          const SizedBox(height: 24),

          // Integrations Section
          _buildIntegrationsSection(),

          const SizedBox(height: 24),

          // Behavior Section
          _buildBehaviorSection(),
        ],
      ),
    );
  }

  Widget _buildIntegrationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Integrations',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildIntegrationItem(
                icon: 'images/google_logo.png',
                title: 'Google',
                description: 'Gmail & Google Workspace (aka GSuite) accounts.',
                buttonText: 'Test Connection',
              ),
              const Divider(height: 1, color: AppColors.textColorSecond),
              _buildIntegrationItem(
                icon: 'images/office365_logo.png',
                title: 'Office 365 + Outlook',
                description: 'Office 365 Business + Personal, Outlook.com and Hotmail accounts.',
                buttonText: 'Connect',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntegrationItem({
    required String icon,
    required String title,
    required String description,
    required String buttonText,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Image.asset(icon, width: 40, height: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorSecond,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textColorSecond,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Behavior',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildBehaviorItem(
                icon: 'images/calendar_add.png',
                title: 'Meetings Calendar',
                description: 'New meetings will be added to: royasmine05@gmail.com',
                actionText: 'Change',
              ),
              const Divider(height: 1, color: AppColors.textColorSecond),
              _buildBehaviorItem(
                icon: 'images/available_dates.png',
                title: 'Availability Calendars',
                description: 'We\'ll check these calendars for conflicts: royasmine05@gmail.com',
                actionText: 'Change',
              ),
              const Divider(height: 1, color: AppColors.textColorSecond),
              _buildBehaviorItem(
                icon: 'images/rescheduling.png',
                title: 'Sync Calendar Changes',
                description: 'When you delete/move an event in your calendar, we\'ll cancel/reschedule the corresponding meeting.',
                actionText: 'Toggle',
                isToggleSync: true,
                onToggleChanged: (value) {
                  setState(() {
                    _isSyncCalendarChanges = value;
                  });
                },
              ),
              const Divider(height: 1, color: AppColors.textColorSecond),
              _buildBehaviorItem(
                icon: 'images/calendar_checked.png',
                title: 'Email Invitations',
                description: 'Send an invitation from my calendar to attendees after they schedule a meeting.',
                actionText: 'Toggle',
                isToggleEmail: true,
                onToggleChanged: (value) {
                  setState(() {
                    _isEmailInvitations = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

Widget _buildBehaviorItem({
  required String icon,
  required String title,
  required String description,
  required String actionText,
  bool isToggleSync = false,
  bool isToggleEmail = false,
  ValueChanged<bool>? onToggleChanged,
}) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Image.asset(icon, width: 50, height: 50),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textColorSecond,
                ),
              ),
            ],
          ),
        ),
        if (isToggleEmail)
          Switch(
            value: _isEmailInvitations,
            onChanged: (value) {
              setState(() {
                _isEmailInvitations = value;
              });
            },
            activeColor: AppColors.accentColor,
            inactiveThumbColor: AppColors.textColorSecond,
          )
        else if (isToggleSync)
          Switch(
            value: _isSyncCalendarChanges,
            onChanged: (value) {
              setState(() {
                _isSyncCalendarChanges = value;
              });
            },
            activeColor: AppColors.accentColor,
            inactiveThumbColor: AppColors.textColorSecond,
          )
        else
          TextButton(
            onPressed: () {},
            child: Text(
              actionText,
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    ),
  );
}

}
