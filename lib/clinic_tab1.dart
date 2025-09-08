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

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clinic_posts')
            .where('clinicId', isEqualTo: clinicId)
            .where('status', isEqualTo: 'open') // Only fetch open postings
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No openings posted yet.'),
            );
          }

          final openings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: openings.length,
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
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(department),
                  subtitle: Text('Experience: $experience years\nDate: $date'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
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
    );
  }
}
