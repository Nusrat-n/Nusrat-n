import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_selector/file_selector.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? email;
  String? role;
  String? resumeUrl;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    setState(() {
      email = user.email;
      role = doc.data()?['role'];
      resumeUrl = doc.data()?['resumeUrl'];
      loading = false;
    });
  }

  Future<void> uploadResume() async {
    final typeGroup = XTypeGroup(label: 'pdf', extensions: ['pdf']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final fileName = file.name;
      final ref = FirebaseStorage.instance.ref().child('resumes/$uid/$fileName');

      try {
        await ref.putData(await file.readAsBytes());
        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'resumeUrl': url,
        });

        setState(() => resumeUrl = url);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resume uploaded successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  void _viewResume() async {
    if (resumeUrl != null && await canLaunchUrl(Uri.parse(resumeUrl!))) {
      await launchUrl(Uri.parse(resumeUrl!), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Resume URL is not valid")),
      );
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Profile")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.account_circle, size: 100, color: Colors.indigo),
            SizedBox(height: 16),
            Text(email ?? '',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            SizedBox(height: 8),
            Chip(
              label: Text(role ?? 'Unknown'),
              backgroundColor: Colors.indigo[50],
              labelStyle: TextStyle(
                  color: Colors.indigo, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 24),

            // Upload Resume
            ElevatedButton.icon(
              onPressed: uploadResume,
              icon: Icon(Icons.upload_file),
              label: Text("Upload Resume (PDF)"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // View Resume if uploaded
            if (resumeUrl != null) ...[
              SizedBox(height: 12),
              Text("Resume uploaded ✔", style: TextStyle(color: Colors.green[700])),
              TextButton.icon(
                onPressed: _viewResume,
                icon: Icon(Icons.picture_as_pdf),
                label: Text("View Resume"),
              ),
            ],

            // Company button
            if (role == 'Company') ...[
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/posted-internships'),
                icon: Icon(Icons.list_alt),
                label: Text("My Posted Internships"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            // Student button
            if (role == 'Student') ...[
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/my-applications'),
                icon: Icon(Icons.work_outline),
                label: Text("My Applications"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            Spacer(),

            // Logout
            ElevatedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout),
              label: Text("Logout"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
