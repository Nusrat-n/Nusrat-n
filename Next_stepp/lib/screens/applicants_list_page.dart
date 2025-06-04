import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/application.dart';

class ApplicantsListPage extends StatelessWidget {
  final String internshipId;
  final String internshipTitle;

  const ApplicantsListPage({
    Key? key,
    required this.internshipId,
    required this.internshipTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final applicationsRef = FirebaseFirestore.instance
        .collection('internships')
        .doc(internshipId)
        .collection('applications');

    return Scaffold(
      appBar: AppBar(
        title: Text("Applicants - $internshipTitle"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
        applicationsRef.orderBy('appliedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final applicants = snapshot.data!.docs;

          if (applicants.isEmpty) {
            return Center(child: Text("No applicants yet."));
          }

          return ListView.builder(
            itemCount: applicants.length,
            itemBuilder: (context, index) {
              final doc = applicants[index];
              final app = Application.fromDoc(doc);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  leading: Icon(Icons.person_outline, color: Colors.indigo),
                  title: Text(app.fullName,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${app.email}'),
                        Text('Address: ${app.address}'),
                        Text('Education: ${app.educationalStatus}'),
                        Text('CGPA: ${app.currentCgpa.toStringAsFixed(2)}'),
                        Text('Applied on: ${app.appliedAt.toDate().toLocal().toString().split(' ')[0]}'),
                        if (app.linkedin != null) SizedBox(height: 4),
                        if (app.linkedin != null)
                          GestureDetector(
                            onTap: () => launchUrl(Uri.parse(app.linkedin!)),
                            child: Text(
                              'LinkedIn Profile',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
