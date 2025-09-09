import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ChatScreen.dart'; // import the chat screen

// list of all doctors for clinics to view and chat
class ClinicTab5 extends StatelessWidget {
  const ClinicTab5({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .where('approved', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final dentists = snapshot.data!.docs;

          if (dentists.isEmpty) {
            return const Center(
              child: Text(
                "No approved dentists found.",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: dentists.length,
            itemBuilder: (context, index) {
              final dentist = dentists[index].data() as Map<String, dynamic>;
              final dentistId = dentists[index].id;
              final dentistName = dentist['doctorName'] ?? "Unknown";
              final department = dentist['department'] ?? "Not specified";
              final experience = dentist['experience'] ?? "Not specified";

              return Card(
                color: Colors.white.withOpacity(0.95),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, color: Color(0xFF1565C0)),
                  ),
                  title: Text(
                    dentistName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  subtitle: Text(
                    "Dept: $department\nExp: $experience yrs",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  trailing: const Icon(Icons.chat_bubble_outline,
                      color: Color(0xFF1565C0)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          otherUserId: dentistId,
                          otherUserName: dentistName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
