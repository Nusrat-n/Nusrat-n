// lib/screens/apply_internship_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/application.dart';

class ApplyInternshipPage extends StatefulWidget {
  final String internshipId;
  const ApplyInternshipPage({Key? key, required this.internshipId}) : super(key: key);

  @override
  _ApplyInternshipPageState createState() => _ApplyInternshipPageState();
}

class _ApplyInternshipPageState extends State<ApplyInternshipPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _eduCtrl = TextEditingController();
  final _cgpaCtrl = TextEditingController();
  final _motivationCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    _emailCtrl.text = user.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Apply for Internship')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameCtrl,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(labelText: 'Email'),
                readOnly: true,
              ),
              TextFormField(
                controller: _addressCtrl,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _eduCtrl,
                decoration: InputDecoration(labelText: 'Educational Status'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _cgpaCtrl,
                decoration: InputDecoration(labelText: 'Current CGPA'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _motivationCtrl,
                decoration: InputDecoration(labelText: 'Why do you want this internship?'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _linkedinCtrl,
                decoration: InputDecoration(labelText: 'LinkedIn Profile URL (optional)'),
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitting
                    ? null
                    : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _submitting = true);
                  try {
                    final user = FirebaseAuth.instance.currentUser!;
                    final app = Application(
                      userId: user.uid,
                      fullName: _fullNameCtrl.text.trim(),
                      email: _emailCtrl.text.trim(),
                      address: _addressCtrl.text.trim(),
                      educationalStatus: _eduCtrl.text.trim(),
                      currentCgpa: double.parse(_cgpaCtrl.text),
                      motivation: _motivationCtrl.text.trim(),
                      linkedin: _linkedinCtrl.text.trim().isEmpty
                          ? null
                          : _linkedinCtrl.text.trim(),
                      appliedAt: Timestamp.now(),
                    );
                    await FirebaseFirestore.instance
                        .collection('internships')
                        .doc(widget.internshipId)
                        .collection('applications')
                        .doc(user.uid)
                        .set(app.toMap());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Application submitted!')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  } finally {
                    setState(() => _submitting = false);
                  }
                },
                child: Text(_submitting ? 'Submitting...' : 'Submit Application'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
