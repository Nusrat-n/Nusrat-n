class Internship {
  final String id;
  final String title;
  final String company;
  final String location;
  final String description;
  final bool isPaid;
  final String duration;
  final String postedBy;

  Internship({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.isPaid,
    required this.duration,
    required this.postedBy,
  });

  factory Internship.fromMap(Map<String, dynamic> data, String docId) {
    return Internship(
      id: docId,
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      isPaid: data['isPaid'] ?? false,
      duration: data['duration'] ?? '',
      postedBy: data['postedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'description': description,
      'isPaid': isPaid,
      'duration': duration,
      'postedBy': postedBy,
    };
  }
}
