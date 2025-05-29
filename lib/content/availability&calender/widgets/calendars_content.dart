// lib\content\availability&calender\widgets\calendars_content.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tabourak/config/config.dart';
import '../../../config/globals.dart';
import 'dart:async';

class CalendarsContent extends StatefulWidget {
  const CalendarsContent({Key? key}) : super(key: key);

  @override
  _CalendarsContentState createState() => _CalendarsContentState();
}

class _CalendarsContentState extends State<CalendarsContent> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;
  int memberID = 0;


  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    initAppLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
  /////////////////////////////////////////////////////////////////////////////

  Future<int?> getUserIdFromToken(String? globalAuthToken) async {
    final url = Uri.parse(
      '${AppConfig.baseUrl}/api/getAuth/get-member-id-aouth',
    );
    print('💡 globalAuthToken' + globalAuthToken.toString());

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'globalAuthToken': globalAuthToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['memberId'];
      } else {
        print('❌ Failed to get user ID. Status code: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('🚨 Error getting user ID: $e');
      return null;
    }
  }

  //////////////////////////////////////////////////////////////////////////////
  Future<void> initAppLinks() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      print('Initial link error: $e');
    }

    _sub = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        print('Deep link stream error: $err');
      },
    );
  }

  /////////////////////////////////////////////////////////////////////////////////
  void _handleDeepLink(Uri uri) {
    if (uri.host == 'zoom-auth-success') {
      final accessToken = uri.queryParameters['access_token'];
      if (accessToken != null) {
        sendTokenToBackend(accessToken);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Zoom connected successfully ✅')),
        );
      }
    }
  }

  //////////////////////////////////////////////////////////////////////////////

  Future<void> sendTokenToBackend(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/zoom/save-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'access_token': token}),
      );
      print("♻️♻️♻️♻️♻️♻️sendTokenToBackend");
      print(response.body);

      if (response.statusCode == 200) {
        print('Token saved successfully');
      } else {
        print('Failed to save token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending token: $e');
    }
  }

  ///////////////////////////////////////////////////////////////////////////
  void startZoomOAuth(BuildContext context) async {
    final userId = await getUserIdFromToken(globalAuthToken);

    final zoomOAuthUrl =
        'https://marketplace.zoom.us/authorize?client_id=dRQS9ByZSUWBKAewqWQ82Q&response_type=code&redirect_uri=http%3A%2F%2F192.168.1.115%3A3000%2Fzoom%2Fcallback&state=${userId}';

    final uri = Uri.parse(zoomOAuthUrl);

    if (await canLaunchUrl(uri)) {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('error when open link')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('error in link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          const Text(
            'Integrations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect your Zoom to generate a unique Zoom link for each new meeting.',
            style: TextStyle(fontSize: 14, color: AppColors.textColorSecond),
          ),
          const SizedBox(height: 24),
          _buildIntegrationsSection(),
          const SizedBox(height: 24),

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
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: AppColors.backgroundColor,
            child: Column(
              children: [
                _buildIntegrationItem(
                  icon: 'images/google_logo.png',
                  title: 'Google',
                  description:
                      'Gmail & Google Workspace (aka GSuite) accounts.',
                  buttonText: 'Test Connection',
                  onPressed: () {},
                ),
                const Divider(height: 1),
                _buildIntegrationItem(
                  icon: 'images/zoom_logo.png',
                  title: 'Zoom',
                  description:
                      'Generate a unique Zoom link for each new meeting.',
                  buttonText: 'Connect',
                  onPressed: () {
                    startZoomOAuth(context);
                  },
                ),
              ],
            ),
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
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(icon, width: 40, height: 40, fit: BoxFit.cover),
          ),
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
            onPressed: onPressed,
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
}
