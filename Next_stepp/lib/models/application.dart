// lib/models/application.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Application {
  final String userId;
  final String fullName;
  final String email;
  final String address;
  final String educationalStatus;
  final double currentCgpa;
  final String motivation;
  final String? linkedin;
  final Timestamp appliedAt;

  Application({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.address,
    required this.educationalStatus,
    required this.currentCgpa,
    required this.motivation,
    this.linkedin,
    required this.appliedAt,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'fullName': fullName,
    'email': email,
    'address': address,
    'educationalStatus': educationalStatus,
    'currentCgpa': currentCgpa,
    'motivation': motivation,
    'linkedin': linkedin,
    'appliedAt': appliedAt,
  };

  factory Application.fromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Application(
      userId: data['userId'] as String,
      fullName: data['fullName'] as String,
      email: data['email'] as String,
      address: data['address'] as String,
      educationalStatus: data['educationalStatus'] as String,
      currentCgpa: (data['currentCgpa'] as num).toDouble(),
      motivation: data['motivation'] as String,
      linkedin: data['linkedin'] as String?,
      appliedAt: data['appliedAt'] as Timestamp,
    );
  }
}
