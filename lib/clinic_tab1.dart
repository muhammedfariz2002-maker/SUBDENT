import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'post_requests.dart'; // import your page

// POSTINGS BY THE CLINIC
class ClinicTab1 extends StatelessWidget {
  const ClinicTab1({super.key});

  @override
  Widget build(BuildContext context) {
    final String clinicId = FirebaseAuth.instance.currentUser!.uid;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('clinic_posts')
              .where('clinicId', isEqualTo: clinicId)
              .where('status', isEqualTo: 'open') // Only fetch open postings
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
                  'No openings posted yet.',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            final openings = snapshot.data!.docs;

            return ListView.builder(
              itemCount: openings.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final opening = openings[index];
                final data = opening.data() as Map<String, dynamic>;

                final openingId = opening.id;
                final department = data['department'] ?? 'Unknown department';
                final experience = data['experienceRequired'] ?? 'Not specified';
                final timestamp = data['date'] as Timestamp?;
                final date = timestamp != null
                    ? DateFormat('dd MMM yyyy').format(timestamp.toDate())
                    : 'No date';

                return Card(
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 6,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      department,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Experience: $experience years\nDate: $date',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('clinic_posts')
                            .doc(openingId)
                            .delete();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening deleted')),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostRequestPage(postId: openingId),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
