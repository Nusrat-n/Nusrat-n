// lib/screens/my_applications_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/application.dart';

/// Holds both the internship doc data and the student's application
class _AppliedEntry {
  final String internshipId;
  final String title;
  final String company;
  final String location;
  final Application application;

  _AppliedEntry({
    required this.internshipId,
    required this.title,
    required this.company,
    required this.location,
    required this.application,
  });
}

class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({Key? key}) : super(key: key);

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  final _auth = FirebaseAuth.instance;
  late Future<List<_AppliedEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchMyApplications();
  }

  Future<List<_AppliedEntry>> _fetchMyApplications() async {
    final uid = _auth.currentUser!.uid;
    final snap = await FirebaseFirestore.instance
        .collection('internships')
        .get();

    final List<_AppliedEntry> list = [];
    for (final doc in snap.docs) {
      final appDoc = await doc.reference
          .collection('applications')
          .doc(uid)
          .get();
      if (!appDoc.exists) continue;

      final application = Application.fromDoc(appDoc);
      final data = doc.data();
      list.add(_AppliedEntry(
        internshipId: doc.id,
        title: data['title'] ?? '',
        company: data['company'] ?? '',
        location: data['location'] ?? '',
        application: application,
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Applications"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<_AppliedEntry>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final entries = snap.data ?? [];
          if (entries.isEmpty) {
            return Center(child: Text("You haven't applied anywhere yet."));
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (ctx, i) {
              final e = entries[i];
              return ExpansionTile(
                title: Text(e.title,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${e.company} • ${e.location}"),
                childrenPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  Text("Full Name: ${e.application.fullName}"),
                  Text("Email: ${e.application.email}"),
                  Text("Address: ${e.application.address}"),
                  Text("Education: ${e.application.educationalStatus}"),
                  Text(
                      "CGPA: ${e.application.currentCgpa.toStringAsFixed(2)}"),
                  Text("Motivation: ${e.application.motivation}"),
                  if (e.application.linkedin != null)
                    GestureDetector(
                      onTap: () =>
                          launchUrl(Uri.parse(e.application.linkedin!)),
                      child: Text(
                        "LinkedIn Profile",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
