import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//LIST OF DENTISTS WITH REQUEST BUTTON
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
              title: const Text("Send Request"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Send request to $dentistName"),
                  const SizedBox(height: 10),
                  ElevatedButton(
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
                  onPressed: selectedDate == null
                      ? null
                      : () async {
                          final currentUser =
                              FirebaseAuth.instance.currentUser;

                          if (currentUser == null) return;
                          final clinicDoc=await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .get();
                              final clinicName=clinicDoc.data()?['clinicName'] ?? 'Unknown Clinic';

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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor') // only doctors
          .where('approved', isEqualTo: true) // only approved doctors
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final dentists = snapshot.data!.docs;

        if (dentists.isEmpty) {
          return const Center(child: Text("No dentists found."));
        }

        return ListView.builder(
          itemCount: dentists.length,
          itemBuilder: (context, index) {
            final dentist = dentists[index].data() as Map<String, dynamic>;
            final dentistId = dentists[index].id;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, size: 40),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dentist['doctorName'] ?? "No name",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(dentist['department'] ?? "No department"),
                          Text(
                            "${dentist['experience'] ?? '0'} yrs experience",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
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
    );
  }
}
