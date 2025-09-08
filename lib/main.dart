import 'package:flutter/material.dart';
import 'package:uc/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(DentalClinicApp());
}

class DentalClinicApp extends StatelessWidget {
  DentalClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUBDENT',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthGate(),
    );
  }
}
