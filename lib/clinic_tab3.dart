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
            .collection('clinic_posts')
            .where('clinicId', isEqualTo: currentUser.uid)
            .where('status', isEqualTo: 'closed') // Only closed postings
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
                "No postings yet.",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final data = posts[index].data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp?)?.toDate();

              // 👇 Get accepted dentist’s name from post data
              final dentistName = data['doctorName'] ?? 'Unknown Dentist';

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
                    child: const Icon(Icons.work, color: Color(0xFF1565C0)),
                  ),
                  title: Text(
                    data['department'] ?? 'No Department',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  subtitle: Text(
                    "Experience: ${data['experienceRequired'] ?? 'N/A'} yrs\n"
                    "Date: ${date != null ? date.toLocal().toString().split(' ')[0] : 'Not set'}",
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text(
                          "Accepted Dentist",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
      ),
    );
  }
}
