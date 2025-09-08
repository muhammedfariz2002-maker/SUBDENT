import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//LIST OF ENGAGED WORK BY THE DENTIST
class ClinicTab4 extends StatelessWidget {
  const ClinicTab4({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text("Not logged in"),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('clinicId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'accepted') // Only accepted engagements
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No engaged work yet."),
          );
        }

        final applications = snapshot.data!.docs;

        return ListView.builder(
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final app = applications[index].data() as Map<String, dynamic>;

            final dentistName = app['dentistName'] ?? "Unknown dentist";
            final dateAssigned = (app['dateAssigned'] as Timestamp?)?.toDate();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text("Dentist: $dentistName"),
                subtitle: Text(
                  "Assigned Date: ${dateAssigned != null ? dateAssigned.toString().split(' ')[0] : 'Not set'}",
                ),
              ),
            );
          },
        );
      },
    );
  }
}
