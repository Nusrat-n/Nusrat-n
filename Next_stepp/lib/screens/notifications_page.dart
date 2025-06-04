import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> dummyNotifications = [
      {"title": "New Internship Posted", "message": "Check out the new opportunity at PixelTech."},
      {"title": "Application Update", "message": "Your application at DevLaunch has been viewed."},
      {"title": "Reminder", "message": "Don’t miss the deadline for the UI/UX Designer internship."},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: dummyNotifications.length,
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (context, index) {
          final item = dummyNotifications[index];
          return ListTile(
            leading: Icon(Icons.notifications_none, color: Colors.indigo),
            title: Text(item['title'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['message'] ?? ''),
          );
        },
      ),
    );
  }
}
