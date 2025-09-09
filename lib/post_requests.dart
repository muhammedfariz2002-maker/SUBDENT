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
        title: const Text(
          "Requests for Post",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('requests')
              .where('postId', isEqualTo: postId)
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
                  "No requests yet",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            final requests = snapshot.data!.docs;

            return ListView.builder(
              itemCount: requests.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final requestDoc = requests[index];
                final data = requestDoc.data() as Map<String, dynamic>;

                final doctorName = data['doctorName'] ?? 'Unknown';
                final email = data['email'] ?? 'No email';
                final experience = data['experience'] ?? 'N/A';
                final status = data['status'] ?? 'pending';

                return Card(
                  color: Colors.white.withOpacity(0.95),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.person, color: Color(0xFF1565C0)),
                    ),
                    title: Text(
                      doctorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    subtitle: Text(
                      "Email: $email\nExperience: $experience years",
                      style: const TextStyle(color: Colors.black87),
                    ),
                    trailing: status == 'pending'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('requests')
                                      .doc(requestDoc.id)
                                      .update({'status': 'accepted'});

                                  FirebaseFirestore.instance
                                      .collection('clinic_posts')
                                      .doc(postId)
                                      .update({
                                    'status': 'closed',
                                    'doctorName': doctorName
                                  });
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('requests')
                                      .doc(requestDoc.id)
                                      .update({'status': 'rejected'});
                                },
                              ),
                            ],
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: status == 'accepted'
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: status == 'accepted'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
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
