import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// list of all requests sent to the logged in doctor to accept or reject
class DoctorTab2 extends StatelessWidget {
  const DoctorTab2({super.key});

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
          colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)], // blueish gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('dentistId', isEqualTo: currentUser.uid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No requests yet.",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index].data() as Map<String, dynamic>;
              final reqId = requests[index].id;

              final clinicId = req['clinicId'] ?? "Unknown clinic";
              final clinicName = req['clinicName'] ?? "Unknown clinic";
              final dateRequired = (req['dateRequired'] as Timestamp?)?.toDate();

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
                          const Icon(Icons.local_hospital, color: Color(0xFF2193b0)),
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
                      Text(
                        "Date Required: ${dateRequired != null ? dateRequired.toString().split(' ')[0] : 'Not set'}",
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('requests')
                                  .doc(reqId)
                                  .update({'status': 'accepted'});

                              await FirebaseFirestore.instance
                                  .collection('applications')
                                  .add({
                                'clinicId': clinicId,
                                'clinicName': clinicName,
                                'dentistId': currentUser.uid,
                                'dentistName': req['dentistName'] ?? "Unknown dentist",
                                'dateAssigned': dateRequired,
                                'status': 'accepted',
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Request accepted")),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Accept"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('requests')
                                  .doc(reqId)
                                  .update({'status': 'rejected'});

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Request rejected")),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Reject"),
                          ),
                        ],
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
