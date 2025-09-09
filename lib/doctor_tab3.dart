import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorTab3 extends StatelessWidget {
  const DoctorTab3({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text(
          "Not logged in",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // --------- LIST 1: From applications ----------
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('applications')
                  .where('dentistId', isEqualTo: currentUser.uid)
                  .where('status', isEqualTo: 'accepted')
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
                      "No engaged work (applications).",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                }

                final engagements = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: engagements.length,
                  itemBuilder: (context, index) {
                    final app = engagements[index].data() as Map<String, dynamic>;
                    final clinicName = app['clinicName'] ?? "Unknown clinic";
                    final department = app['department'] ?? "N/A";
                    final assignedDate = (app['dateAssigned'] as Timestamp?)?.toDate();

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.work, color: Color(0xFF2193b0)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Clinic: $clinicName",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2193b0),
                                    ),
                                  ),
                                ),
                                const Text(
                                  "ACCEPTED",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text("Department: $department",
                                style: const TextStyle(fontSize: 14, color: Colors.black87)),
                            Text(
                              "Date: ${assignedDate != null ? assignedDate.toLocal().toString().split(' ')[0] : 'Not set'}",
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1, color: Colors.white70),

          // --------- LIST 2: From clinic_posts ----------
          Expanded(
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .get(),
              builder: (context, userSnap) {
                if (userSnap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (!userSnap.hasData || !userSnap.data!.exists) {
                  return const Center(
                    child: Text(
                      "Profile not found.",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                }

                final userData = userSnap.data!.data() as Map<String, dynamic>;
                final doctorName = userData['doctorName'] ?? '';

                if (doctorName.isEmpty) {
                  return const Center(
                    child: Text(
                      "Your profile has no doctor name.",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('clinic_posts')
                      .where('doctorName', isEqualTo: doctorName)
                      .snapshots(),
                  builder: (context, postSnap) {
                    if (postSnap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    if (!postSnap.hasData || postSnap.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No engaged work (clinic posts).",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      );
                    }

                    final posts = postSnap.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final data = posts[index].data() as Map<String, dynamic>;
                        final clinicName = data['clinicName'] ?? 'Unknown clinic';
                        final department = data['department'] ?? 'N/A';
                        final date = (data['date'] as Timestamp?)?.toDate();

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.event_available, color: Color(0xFF2193b0)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Clinic: $clinicName",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2193b0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text("Department: $department",
                                    style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                Text(
                                  "Date: ${date != null ? date.toLocal().toString().split(' ')[0] : 'Not set'}",
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}
