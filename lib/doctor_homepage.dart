import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Import your doctor tab pages here
import 'doctor_tab1.dart';
import 'doctor_tab2.dart';
import 'doctor_tab3.dart';
import 'doctor_tab4.dart';
import 'doctor_tab5.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DoctorTab1(),
    DoctorTab2(),
    DoctorTab3(),
    //DoctorTab4(),
    DoctorTab5(),
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
        title: const Text(
          'Doctor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)], // blueish gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Logout",
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        elevation: 4,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Posts"),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "Requests"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Schedule"),
            //BottomNavigationBarItem(icon: Icon(Icons.person), label: "Applications"),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          ],
        ),
      ),
    );
  }
}
