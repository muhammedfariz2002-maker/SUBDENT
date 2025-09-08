import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//list of all requests sent to the logged in doctor to accept or reject
class DoctorTab2 extends StatelessWidget {
  const DoctorTab2({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text("Not logged in"),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('dentistId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'pending')
          //.orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No requests yet."),
          );
        }

        final requests = snapshot.data!.docs;

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index].data() as Map<String, dynamic>;
            final reqId = requests[index].id;

            final clinicId = req['clinicId'] ?? "Unknown clinic";
            final clinicName = req['clinicName'] ?? "Unknown clinic";
            final dateRequired = (req['dateRequired'] as Timestamp?)?.toDate();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.local_hospital),
                title: Text("Clinic: $clinicName"),
                subtitle: Text(
                  "Date: ${dateRequired != null ? dateRequired.toString().split(' ')[0] : 'Not set'}",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Update request status
                        await FirebaseFirestore.instance
                            .collection('requests')
                            .doc(reqId)
                            .update({'status': 'accepted'});

                        // Create application document
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
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text("Accept"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        // Update request status
                        await FirebaseFirestore.instance
                            .collection('requests')
                            .doc(reqId)
                            .update({'status': 'rejected'});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Reject"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
