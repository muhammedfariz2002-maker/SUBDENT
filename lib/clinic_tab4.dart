import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// LIST OF ENGAGED WORK BY THE DENTIST
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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('clinicId', isEqualTo: currentUser.uid)
            .where('status', isEqualTo: 'accepted') // Only accepted engagements
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No engaged work yet.",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final applications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: applications.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final app = applications[index].data() as Map<String, dynamic>;

              final dentistName = app['dentistName'] ?? "Unknown dentist";
              final dateAssigned =
                  (app['dateAssigned'] as Timestamp?)?.toDate();

              return Card(
                color: Colors.white.withOpacity(0.9),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, color: Color(0xFF1565C0)),
                  ),
                  title: Text(
                    "Dentist: $dentistName",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  subtitle: Text(
                    "Assigned Date: ${dateAssigned != null ? dateAssigned.toString().split(' ')[0] : 'Not set'}",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
