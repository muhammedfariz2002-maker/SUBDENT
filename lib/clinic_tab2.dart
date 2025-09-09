import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// LIST OF DENTISTS WITH REQUEST BUTTON
class ClinicTab2 extends StatelessWidget {
  const ClinicTab2({super.key});

  // 🔹 Function to show request dialog
  Future<void> _showRequestDialog(
      BuildContext context, String dentistId, String dentistName) async {
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Send Request",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Send request to $dentistName"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      selectedDate == null
                          ? "Pick Date"
                          : "Date: ${selectedDate!.toLocal()}".split(' ')[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF42A5F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: selectedDate == null
                      ? null
                      : () async {
                          final currentUser =
                              FirebaseAuth.instance.currentUser;

                          if (currentUser == null) return;
                          final clinicDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .get();
                          final clinicName =
                              clinicDoc.data()?['clinicName'] ?? 'Unknown Clinic';

                          await FirebaseFirestore.instance
                              .collection('requests')
                              .add({
                            'clinicId': currentUser.uid,
                            'clinicName': clinicName,
                            'dentistId': dentistId,
                            'dentistName': dentistName,
                            'dateRequired': Timestamp.fromDate(selectedDate!),
                            'status': 'pending',
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Request sent successfully ✅"),
                            ),
                          );
                        },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'doctor') // only doctors
            .where('approved', isEqualTo: true) // only approved doctors
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final dentists = snapshot.data!.docs;

          if (dentists.isEmpty) {
            return const Center(
              child: Text(
                "No dentists found.",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: dentists.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final dentist = dentists[index].data() as Map<String, dynamic>;
              final dentistId = dentists[index].id;

              return Card(
                color: Colors.white.withOpacity(0.9),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        radius: 28,
                        child: const Icon(Icons.person,
                            size: 32, color: Color(0xFF1565C0)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dentist['doctorName'] ?? "No name",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dentist['department'] ?? "No department",
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              "${dentist['experience'] ?? '0'} yrs experience",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF42A5F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        onPressed: () {
                          _showRequestDialog(
                            context,
                            dentistId,
                            dentist['doctorName'] ?? "No name",
                          );
                        },
                        child: const Text("Request"),
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
