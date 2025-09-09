import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorTab2 extends StatefulWidget {
  const DoctorTab2({super.key});

  @override
  State<DoctorTab2> createState() => _DoctorTab2State();
}

class _DoctorTab2State extends State<DoctorTab2> {
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _acceptRequest(String reqId, String clinicId, String clinicName, Map<String, dynamic> req) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(reqId)
          .update({'status': 'accepted'});

      await FirebaseFirestore.instance.collection('applications').add({
        'clinicId': clinicId,
        'clinicName': clinicName,
        'dentistId': currentUser!.uid,
        'dentistName': req['dentistName'] ?? "Unknown dentist",
        'dateAssigned': (req['dateRequired'] as Timestamp?)?.toDate(),
        'status': 'accepted',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request accepted ✅")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _rejectRequest(String reqId) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(reqId)
          .update({'status': 'rejected'});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request rejected ❌")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('dentistId', isEqualTo: currentUser!.uid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
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
                          const Icon(Icons.local_hospital,
                              color: Color(0xFF2193b0)),
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
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => _acceptRequest(
                                reqId, clinicId, clinicName, req),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Accept"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _rejectRequest(reqId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
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
