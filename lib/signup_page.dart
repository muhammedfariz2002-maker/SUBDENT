import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final clinicNameController = TextEditingController();
  final locationController = TextEditingController();
  final doctorNameController = TextEditingController();
  final departmentController = TextEditingController();
  final experienceController = TextEditingController();
  String selectedRole = 'doctor';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    clinicNameController.dispose();
    locationController.dispose();
    doctorNameController.dispose();
    departmentController.dispose();
    experienceController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    final uid = userCredential.user!.uid;
    Map<String, dynamic> data = {
      'email': emailController.text.trim(),
      'role': selectedRole,
      'approved': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (selectedRole == 'clinic') {
      data['clinicName'] = clinicNameController.text.trim();
      data['location'] = locationController.text.trim();
    } else {
      data['doctorName'] = doctorNameController.text.trim();
      data['department'] = departmentController.text.trim();
      data['experience'] = experienceController.text.trim();
    }
    await FirebaseFirestore.instance.collection('users').doc(uid).set(data);
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButton<String>(
              value: selectedRole,
              items: const [
                DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                DropdownMenuItem(value: 'clinic', child: Text('Clinic')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedRole = value;
                  });
                }
              },
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (selectedRole == 'clinic') ...[
              TextField(
                controller: clinicNameController,
                decoration: const InputDecoration(labelText: 'Clinic Name'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
            ] else ...[
              TextField(
                controller: doctorNameController,
                decoration: const InputDecoration(labelText: 'Doctor Name'),
              ),
              TextField(
                controller: departmentController,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
              TextField(
                controller: experienceController,
                decoration: const InputDecoration(labelText: 'Experience'),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: signUp,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
