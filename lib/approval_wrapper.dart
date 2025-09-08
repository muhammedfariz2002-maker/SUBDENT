import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'clinic_home_page.dart';
import 'doctor_homepage.dart';
import 'login_page.dart';

class ApprovalWrapper extends StatelessWidget {
  const ApprovalWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const LoginPage();

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error loading profile')),
          );
        }

        final doc = snapshot.data;
        final data = (doc?.data() as Map?)?.cast<String, dynamic>() ?? {};
        final approved = data['approved'] as bool? ?? false;
        final role = data['role'] as String? ?? '';
        if (!approved) {
          return Scaffold(
            appBar: AppBar(title: Text('Approval status bar'),
            actions: [
              IconButton(onPressed: ()async{
                await FirebaseAuth.instance.signOut();
              },
                  icon: Icon(Icons.logout))
                  
            ],),
            body: Center(child: Text('Waiting for approval')),
          );
        }

        if (role == "doctor") {
          return const DoctorHomePage();
        } else if (role == "clinic") {
          return const ClinicHomePage();
        }
        else{
          return const Scaffold(body: Center(child: Text("not valid role"),),);
        }
      },
    );
  }
}
