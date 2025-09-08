import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// PAGE TO SHOW REQUESTS FOR A PARTICULAR POST
class PostRequestPage extends StatelessWidget {
  final String postId;

  const PostRequestPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Requests for Post"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('postId', isEqualTo: postId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No requests yet"));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final requestDoc = requests[index];
              final data = requestDoc.data() as Map<String, dynamic>;

              final doctorName = data['doctorName'] ?? 'Unknown';
              final email = data['email'] ?? 'No email';
              final experience = data['experience'] ?? 'N/A';
              final status = data['status'] ?? 'pending';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(doctorName),
                  subtitle: Text("Email: $email\nExperience: $experience years"),
                  trailing: status == 'pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('requests')
                                    .doc(requestDoc.id)
                                    .update({'status': 'accepted'});

                                FirebaseFirestore.instance
                                    .collection('clinic_posts')
                                    .doc(postId)
                                    .update({'status': 'closed',
                                    'doctorName': doctorName});
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('requests')
                                    .doc(requestDoc.id)
                                    .update({'status': 'rejected'});
                              },
                            ),
                          ],
                        )
                      : Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: status == 'accepted'
                                ? Colors.green
                                : Colors.red,
                          ),
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
