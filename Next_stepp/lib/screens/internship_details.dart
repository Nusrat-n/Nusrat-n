import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/internship.dart';
import 'apply_internship_page.dart';

class InternshipDetailsPage extends StatelessWidget {
  const InternshipDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final internship = ModalRoute.of(context)!.settings.arguments as Internship;

    return Scaffold(
      appBar: AppBar(
        title: Text("Internship Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              internship.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "${internship.company} • ${internship.location}",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            Chip(
              label: Text(internship.isPaid ? "Paid" : "Unpaid"),
              backgroundColor:
              internship.isPaid ? Colors.green[100] : Colors.grey[300],
              labelStyle: TextStyle(
                color: internship.isPaid ? Colors.green[900] : Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Duration: ${internship.duration}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 24),
            Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  internship.description,
                  style: TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("You must be logged in to apply.")),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApplyInternshipPage(
                      internshipId: internship.id,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("Apply Now", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
