import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Post_Requirement_Page extends StatefulWidget {
  const Post_Requirement_Page({super.key});

  @override
  State<Post_Requirement_Page> createState() => _Post_Requirement_PageState();
}

class _Post_Requirement_PageState extends State<Post_Requirement_Page> {
  final departmentController = TextEditingController();
  final experienceController = TextEditingController();
  DateTime? selectedDate;

  void postRequirement() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    if (departmentController.text.isEmpty ||
        selectedDate == null ||
        experienceController.text.isEmpty) {
      return;
    }
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final clinicName=userDoc.data()?['clinicName'] ?? 'Unknown Clinic';

    await FirebaseFirestore.instance.collection('clinic_posts').add({
      'clinicId': uid,
      'clinicName': clinicName,
      'department': departmentController.text,
      'date': selectedDate,
      'experienceRequired': experienceController.text,
      'status': 'open',
    });

    Navigator.pop(context);
  }

  void pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Requirement'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              TextField(controller: departmentController,decoration: InputDecoration(labelText: 'Department'),),
              TextField(
                controller: experienceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Experience Required'),
              ),
              Row(
                children: [
                  Text(selectedDate == null
                      ? 'No date chosen'
                      : selectedDate!.toLocal().toString().split(' ')[0]),
                  TextButton(onPressed: pickDate, child: Text('Pick Date')),
                ],
              ),
              ElevatedButton(onPressed: postRequirement, child: Text('Post')),
            ],
          ),
        ),
      ),
    );
  }
}
