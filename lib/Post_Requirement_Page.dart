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
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final clinicName = userDoc.data()?['clinicName'] ?? 'Unknown Clinic';

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
        title: const Text(
          'Post Requirement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f7fa), Color(0xFFf1f9ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Create New Requirement",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: departmentController,
                      decoration: InputDecoration(
                        labelText: 'Department',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: experienceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Experience Required (in years)',
                        prefixIcon: const Icon(Icons.work_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDate == null
                                ? 'No date chosen'
                                : selectedDate!
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: pickDate,
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Pick Date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: postRequirement,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "Post Requirement",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
