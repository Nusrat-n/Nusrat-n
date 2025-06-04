import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'applicants_list_page.dart';

class MyPostedInternshipsPage extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;
  MyPostedInternshipsPage({super.key});



  @override
  Widget build(BuildContext context) {
    final internshipsRef = FirebaseFirestore.instance
        .collection('internships')
        .where('postedBy', isEqualTo: user?.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text("My Posted Internships"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: internshipsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text("You haven’t posted any internships yet."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(Icons.work, color: Colors.indigo),
                  title: Text(data['title'] ?? ''),
                  subtitle: Text("${data['company'] ?? ''} • ${data['location'] ?? ''}"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApplicantsListPage(
                        internshipId: docs[index].id,
                        internshipTitle: data['title'] ?? 'Internship',
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
