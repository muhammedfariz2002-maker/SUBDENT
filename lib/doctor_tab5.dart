import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ChatScreen.dart'; // ✅ import your chat screen

// LIST OF CLINICS FOR DOCTORS TO VIEW AND CHAT
class DoctorTab5 extends StatelessWidget {
  const DoctorTab5({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'clinic')
            .where('approved', isEqualTo: true) // ✅ Only show approved clinics
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
                "No clinics available.",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final clinics = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: clinics.length,
            itemBuilder: (context, index) {
              final clinic = clinics[index].data() as Map<String, dynamic>;
              final clinicId = clinics[index].id;
              final clinicName = clinic['clinicName'] ?? "Unknown Clinic";
              final location = clinic['location'] ?? "Not specified";
              final email = clinic['email'] ?? "N/A";

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.local_hospital,
                      color: Color(0xFF2193b0), size: 32),
                  title: Text(
                    clinicName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF2193b0),
                    ),
                  ),
                  subtitle: Text(
                    "Location: $location\nEmail: $email",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chat_bubble_outline,
                      color: Color(0xFF2193b0)),
                  onTap: () {
                    // 👉 Navigate to ChatScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          otherUserId: clinicId,
                          otherUserName: clinicName,
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
