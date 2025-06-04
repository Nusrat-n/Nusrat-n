import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostInternshipPage extends StatefulWidget {
  const PostInternshipPage({super.key});

  @override
  _PostInternshipPageState createState() => _PostInternshipPageState();
}

class _PostInternshipPageState extends State<PostInternshipPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPaid = false;
  bool _loading = false;

  String? _selectedCategory;
  final List<String> _categories = [
    'Engineering',
    'Media',
    'Marketing',
    'Design',
    'Part-time',
  ];

  void _submitInternship() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        setState(() => _loading = false);
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('internships').add({
          'title': _titleController.text.trim(),
          'company': _companyController.text.trim(),
          'location': _locationController.text.trim(),
          'duration': _durationController.text.trim(),
          'description': _descriptionController.text.trim(),
          'isPaid': _isPaid,
          'postedBy': user.uid,
          'postedByEmail': user.email,
          'category': [_selectedCategory], // ✅ Save as list!
          'timestamp': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Internship posted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e')),
        );
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Post Internship")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Fill in internship details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Internship Title'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _companyController,
                decoration: _inputDecoration('Company Name'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration('Location'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _inputDecoration('Category'),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
                validator: (value) => value == null ? 'Category required' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _durationController,
                decoration: _inputDecoration('Duration'),
              ),
              SizedBox(height: 16),

              SwitchListTile(
                title: Text("Paid Internship"),
                value: _isPaid,
                onChanged: (val) => setState(() => _isPaid = val),
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: _inputDecoration('Description'),
              ),
              SizedBox(height: 24),

              _loading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitInternship,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Submit", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
