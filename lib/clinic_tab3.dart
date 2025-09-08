import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// HISTORY OF POSTINGS BY THE CLINIC
class ClinicTab3 extends StatelessWidget {
  const ClinicTab3({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("Not logged in"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('clinic_posts')
          .where('clinicId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'closed') // Only closed postings
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No postings yet."));
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final data = posts[index].data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp?)?.toDate();

            // 👇 Get accepted dentist’s name from post data
            final dentistName = data['doctorName'] ?? 'Unknown Dentist';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.work),
                title: Text(data['department'] ?? 'No Department'),
                subtitle: Text(
                  "Experience: ${data['experienceRequired'] ?? 'N/A'} yrs\n"
                  "Date: ${date != null ? date.toLocal().toString().split(' ')[0] : 'Not set'}",
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Accepted Dentist"),
                      content: Text(dentistName),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text("OK"),
                        ),
                      ],
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
