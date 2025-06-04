import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/internship.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userRole;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        userRole = userDoc.data()?['role'];
        loading = false;
      });
    }
  }

  Future<List<Internship>> fetchInternships() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('internships').get();
    return snapshot.docs
        .map((doc) => Internship.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Loading...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(userRole == 'Company' ? "My Dashboard" : "Internships"),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: userRole == 'Student'
          ? FutureBuilder<List<Internship>>(
        future: fetchInternships(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading internships"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No internships available"));
          }

          final internships = snapshot.data!;
          return ListView.builder(
            itemCount: internships.length,
            itemBuilder: (context, index) {
              final internship = internships[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: ListTile(
                  title: Text(internship.title,
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      "${internship.company} • ${internship.location}"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/details',
                    arguments: internship,
                  ),
                ),
              );
            },
          );
        },
      )
          : Center(
        child: Text(
          "Tap '+' to post a new internship",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButton: userRole == 'Company'
          ? FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/post'),
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add),
      )
          : null,
    );
  }
}
