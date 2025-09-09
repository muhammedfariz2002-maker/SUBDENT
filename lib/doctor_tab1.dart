import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// list of all open clinic posts for doctors to view and apply
class DoctorTab1 extends StatelessWidget {
  const DoctorTab1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)], // blueish gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clinic_posts')
            .where('status', isEqualTo: 'open') // only show open ones
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No openings available",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final postDoc = posts[index];
              final data = postDoc.data() as Map<String, dynamic>;

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
                      Text(
                        data['department'] ?? 'No Department',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2193b0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Clinic: ${data['clinicName'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      Text(
                        "Experience Required: ${data['experienceRequired'] ?? 'N/A'} years",
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      Text(
                        "Date: ${data['date'] != null ? (data['date'] as Timestamp).toDate().toLocal().toString().split(' ')[0] : 'N/A'}",
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: const Color(0xFF2193b0),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;

                            // fetch doctor details from users collection
                            final doctorSnap = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user?.uid)
                                .get();

                            final doctorData =
                                doctorSnap.data() as Map<String, dynamic>? ?? {};

                            FirebaseFirestore.instance.collection('requests').add({
                              'postId': postDoc.id,
                              'clinicId': data['clinicId'], // make sure this exists in clinic_posts
                              'department': data['department'] ?? '',
                              'doctorId': user?.uid,
                              'doctorName': doctorData['doctorName'] ?? '', // ✅ from Firestore
                              'email': doctorData['email'] ?? user?.email ?? '',
                              'experience': doctorData['experience'] ?? '',
                              'status': 'pending',
                              'createdAt': FieldValue.serverTimestamp(),
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Request sent")),
                            );
                          },
                          child: const Text("Request"),
                        ),
                      ),
                    ],
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
