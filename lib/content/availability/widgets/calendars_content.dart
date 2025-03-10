import 'package:flutter/material.dart';

class CalendarsContent extends StatelessWidget {
  const CalendarsContent({Key? key}) : super(key: key);

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
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Integrate your calendars to prevent double bookings and have your meetings automatically added.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
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
            color: Colors.black,
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
              const Divider(height: 1, color: Colors.grey),
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
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
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
            color: Colors.black,
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
              const Divider(height: 1, color: Colors.grey),
              _buildBehaviorItem(
                icon: 'images/available_dates.png',
                title: 'Availability Calendars',
                description: 'We\'ll check these calendars for conflicts: royasmine05@gmail.com',
                actionText: 'Change',
              ),
              const Divider(height: 1, color: Colors.grey),
              _buildBehaviorItem(
                icon: 'images/rescheduling.png',
                title: 'Sync Calendar Changes',
                description: 'When you delete/move an event in your calendar, we\'ll cancel/reschedule the corresponding meeting.',
                actionText: 'Toggle',
                isToggle: true,
              ),
              const Divider(height: 1, color: Colors.grey),
              _buildBehaviorItem(
                icon: 'images/calendar_checked.png',
                title: 'Email Invitations',
                description: 'Send an invitation from my calendar to attendees after they schedule a meeting.',
                actionText: 'Toggle',
                isToggle: true,
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
    bool isToggle = false,
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
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (isToggle)
            Switch(
              value: true,
              onChanged: (value) {},
              activeColor: Colors.blue,
            )
          else
            TextButton(
              onPressed: () {},
              child: Text(
                actionText,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}