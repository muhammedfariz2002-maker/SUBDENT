import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ChatScreen.dart'; // import the chat screen
//list of all doctors for clinics to view and chat
class ClinicTab5 extends StatelessWidget {
  const ClinicTab5({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('approved', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final dentists = snapshot.data!.docs;

        if (dentists.isEmpty) {
          return const Center(child: Text("No approved dentists found."));
        }

        return ListView.builder(
          itemCount: dentists.length,
          itemBuilder: (context, index) {
            final dentist = dentists[index].data() as Map<String, dynamic>;
            final dentistId = dentists[index].id;
            final dentistName = dentist['doctorName'] ?? "Unknown";
            final department = dentist['department'] ?? "Not specified";
            final experience = dentist['experience'] ?? "Not specified";

            return ListTile(
              title: Text(dentistName),
              subtitle: Text("Dept: $department\nExp: $experience"),
              isThreeLine: true,
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
            );
          },
        );
      },
    );
  }
}
