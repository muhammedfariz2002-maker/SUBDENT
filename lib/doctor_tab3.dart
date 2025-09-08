import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorTab3 extends StatelessWidget {
  const DoctorTab3({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("Not logged in"));
    }

    return Column(
      children: [
        // --------- LIST 1: From applications (unchanged) ----------
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('applications')
                .where('dentistId', isEqualTo: currentUser.uid)
                .where('status', isEqualTo: 'accepted')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No engaged work (applications)."));
              }

              final engagements = snapshot.data!.docs;

              return ListView.builder(
                itemCount: engagements.length,
                itemBuilder: (context, index) {
                  final app = engagements[index].data() as Map<String, dynamic>;
                  final clinicName = app['clinicName'] ?? "Unknown clinic";
                  final department = app['department'] ?? "N/A";
                  final assignedDate = (app['dateAssigned'] as Timestamp?)?.toDate();

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.work),
                      title: Text("Clinic: $clinicName"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Department: $department"),
                          Text(
                            "Date: ${assignedDate != null ? assignedDate.toLocal().toString().split(' ')[0] : 'Not set'}",
                          ),
                        ],
                      ),
                      trailing: const Text(
                        "ACCEPTED",
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        const Divider(height: 1),

        // --------- LIST 2: From clinic_posts (fixed) ----------
        Expanded(
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .get(),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!userSnap.hasData || !userSnap.data!.exists) {
                return const Center(child: Text("Profile not found."));
              }

              final userData = userSnap.data!.data() as Map<String, dynamic>;
              final doctorName = userData['doctorName'] ?? '';

              if (doctorName.isEmpty) {
                return const Center(child: Text("Your profile has no doctor name."));
              }

              // Only filter by doctorName to avoid composite index requirements.
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('clinic_posts')
                    .where('doctorName', isEqualTo: doctorName)
                    .snapshots(),
                builder: (context, postSnap) {
                  if (postSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!postSnap.hasData || postSnap.data!.docs.isEmpty) {
                    return const Center(child: Text("No engaged work (clinic posts)."));
                  }

                  final posts = postSnap.data!.docs;

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final data = posts[index].data() as Map<String, dynamic>;
                      final clinicName = data['clinicName'] ?? 'Unknown clinic';
                      final department = data['department'] ?? 'N/A';
                      final date = (data['date'] as Timestamp?)?.toDate();

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.event_available),
                          title: Text("Clinic: $clinicName"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Department: $department"),
                              Text(
                                "Date: ${date != null ? date.toLocal().toString().split(' ')[0] : 'Not set'}",
                              ),
                            ],
                          ),
                          // status is usually 'closed' once assigned, but we don't rely on it here
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
