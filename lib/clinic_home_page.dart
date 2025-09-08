import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Post_Requirement_Page.dart';
import 'clinic_tab1.dart';
import 'clinic_tab2.dart';
import 'clinic_tab3.dart';
import 'clinic_tab4.dart';
import 'clinic_tab5.dart';

class ClinicHomePage extends StatefulWidget {
  const ClinicHomePage({super.key});

  @override
  State<ClinicHomePage> createState() => _ClinicHomePageState();
}

class _ClinicHomePageState extends State<ClinicHomePage> {
  int _selectedIndex = 0;
  
  static const List<Widget> _pages = [
    ClinicTab1(),
    ClinicTab2(),
    ClinicTab3(),
    ClinicTab4(),
    ClinicTab5(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Home Page'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Postings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_rounded),
            label: 'Accepted',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Post_Requirement_Page(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}