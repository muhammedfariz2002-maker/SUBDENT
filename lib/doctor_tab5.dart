import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ChatScreen.dart'; // ✅ import your chat screen

// LIST OF CLINICS FOR DOCTORS TO VIEW AND CHAT
class DoctorTab5 extends StatelessWidget {
  const DoctorTab5({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'clinic')
          .where('approved', isEqualTo: true) // ✅ Only show approved clinics
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No clinics available."));
        }

        final clinics = snapshot.data!.docs;

        return ListView.builder(
          itemCount: clinics.length,
          itemBuilder: (context, index) {
            final clinic = clinics[index].data() as Map<String, dynamic>;
            final clinicId = clinics[index].id;
            final clinicName = clinic['clinicName'] ?? "Unknown Clinic";
            final location = clinic['location'] ?? "Not specified";
            final email = clinic['email'] ?? "N/A";

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.green),
                title: Text(
                  clinicName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Location: $location\nEmail: $email"),
                isThreeLine: true,
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
    );
  }
}
