import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _currentIndex = 0;

  // --- TAB 1: Pending Approvals (your original code, unchanged)
  Widget _pendingApprovals() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('approved', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data?.docs ?? [];

        if (users.isEmpty) {
          return const Center(child: Text('No users waiting for approval.'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final data = users[index].data() as Map<String, dynamic>;
            final uid = users[index].id;
            final email = data['email'] ?? 'No email';
            final role = data['role'] ?? 'No role';

            return ListTile(
              title: Text(email),
              subtitle: Text('Role: $role'),
              trailing: ElevatedButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .update({'approved': true});
                },
                child: const Text('Approve'),
              ),
            );
          },
        );
      },
    );
  }

  // --- TAB 2: Approved Clinics
  Widget _approvedClinics() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'clinic')
          .where('approved', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final clinics = snapshot.data!.docs;

        if (clinics.isEmpty) {
          return const Center(child: Text("No approved clinics."));
        }

        return ListView.builder(
          itemCount: clinics.length,
          itemBuilder: (context, index) {
            final data = clinics[index].data() as Map<String, dynamic>;
            final uid = clinics[index].id;

            return ListTile(
              leading: const Icon(Icons.local_hospital),
              title: Text(data['clinicName'] ?? 'No name'),
              subtitle: const Text("Clinic"),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  FirebaseFirestore.instance.collection('users').doc(uid).delete();
                },
              ),
            );
          },
        );
      },
    );
    
  }

  // --- TAB 3: Approved Dentists
  Widget _approvedDentists() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('approved', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final dentists = snapshot.data!.docs;

        if (dentists.isEmpty) {
          return const Center(child: Text("No approved dentists."));
        }

        return ListView.builder(
          itemCount: dentists.length,
          itemBuilder: (context, index) {
            final data = dentists[index].data() as Map<String, dynamic>;
            final uid = dentists[index].id;

            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(data['doctorName'] ?? 'No name'),
              subtitle: const Text("Dentist"),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  FirebaseFirestore.instance.collection('users').doc(uid).delete();
                },
              ),
            );
          },
        );
      },
    );
  }

  // --- TAB 4: Openings (UPDATED ONLY THIS TAB)
  Widget _openingsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('clinic_posts') // ✅ correct collection
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final openings = snapshot.data!.docs;

        if (openings.isEmpty) {
          return const Center(child: Text("No openings found."));
        }

        return ListView.builder(
          itemCount: openings.length,
          itemBuilder: (context, index) {
            final data = openings[index].data() as Map<String, dynamic>;
            final openingId = openings[index].id;

            final dateStr = (() {
              final ts = data['date'];
              if (ts is Timestamp) {
                return ts.toDate().toString().split(' ').first; // YYYY-MM-DD
              }
              return '-';
            })();

            return ListTile(
              leading: const Icon(Icons.work),
              title: Text(data['department'] ?? "No department"),
              subtitle: Text(
                "Experience: ${data['experienceRequired'] ?? '-'} years\n"
                "Date: $dateStr\n"
                "Status: ${data['status'] ?? 'Unknown'}",
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('clinic_posts') // ✅ correct collection
                      .doc(openingId) // ✅ correct doc id
                      .delete();
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _pendingApprovals(),
      _approvedClinics(),
      _approvedDentists(),
      _openingsList(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pending), label: "Pending"),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: "Clinics"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Dentists"),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Openings"),
        ],
      ),
    );
  }
}
