import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// list of all open clinic posts for doctors to view and apply
class DoctorTab1 extends StatelessWidget {
  const DoctorTab1({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('clinic_posts')
          .where('status', isEqualTo: 'open') // only show open ones
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No openings available"));
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final postDoc = posts[index];
            final data = postDoc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(data['department'] ?? 'No Department'),
                subtitle: Text(
                  'clinicName: ${data['clinicName'] ?? 'N/A'}\n'
                  "Experience: ${data['experienceRequired'] ?? 'N/A'} years\n"
                  "Date: ${data['date'] != null ? (data['date'] as Timestamp).toDate().toLocal().toString().split(' ')[0] : 'N/A'}",
                ),
                trailing: ElevatedButton(
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
            );
          },
        );
      },
    );
  }
}
