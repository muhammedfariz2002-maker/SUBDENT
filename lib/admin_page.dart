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

  // --- TAB 1: Pending Approvals
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
          return const Center(
            child: Text('No users waiting for approval.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final data = users[index].data() as Map<String, dynamic>;
            final uid = users[index].id;
            final email = data['email'] ?? 'No email';
            final role = data['role'] ?? 'No role';

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.pending, color: Colors.orange),
                title: Text(email),
                subtitle: Text('Role: $role'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2193b0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .update({'approved': true});
                  },
                  child: const Text('Approve'),
                ),
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
          padding: const EdgeInsets.all(16),
          itemCount: clinics.length,
          itemBuilder: (context, index) {
            final data = clinics[index].data() as Map<String, dynamic>;
            final uid = clinics[index].id;

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.local_hospital,
                    color: Colors.lightBlueAccent),
                title: Text(data['clinicName'] ?? 'No name'),
                subtitle: const Text("Clinic"),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .delete();
                  },
                ),
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
          padding: const EdgeInsets.all(16),
          itemCount: dentists.length,
          itemBuilder: (context, index) {
            final data = dentists[index].data() as Map<String, dynamic>;
            final uid = dentists[index].id;

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.teal),
                title: Text(data['doctorName'] ?? 'No name'),
                subtitle: const Text("Dentist"),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .delete();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- TAB 4: Openings
  Widget _openingsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('clinic_posts').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final openings = snapshot.data!.docs;
        if (openings.isEmpty) {
          return const Center(child: Text("No openings found."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: openings.length,
          itemBuilder: (context, index) {
            final data = openings[index].data() as Map<String, dynamic>;
            final openingId = openings[index].id;

            final dateStr = (() {
              final ts = data['date'];
              if (ts is Timestamp) {
                return ts.toDate().toString().split(' ').first;
              }
              return '-';
            })();

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.work, color: Colors.blueAccent),
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
                        .collection('clinic_posts')
                        .doc(openingId)
                        .delete();
                  },
                ),
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
        title: const Text(
          'SubDent Admin Panel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f7fa), Color(0xFFf1f9ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: tabs[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2193b0),
        unselectedItemColor: Colors.grey,
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
