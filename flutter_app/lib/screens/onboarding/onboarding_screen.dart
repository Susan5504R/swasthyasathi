import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _emergencyController = TextEditingController();
  String _language = 'hindi';
  String _state = 'UP';
  bool _isLoading = false;

  void _saveProfile() async {
    final name = _nameController.text.trim();
    final emergency = _emergencyController.text.trim();
    
    if (name.isEmpty) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'language': _language,
          'state': _state,
          'emergency_contact': emergency,
          'font_size': 'medium',
          'created_at': DateTime.now().toIso8601String(),
        }).timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('⚠️ Firestore profile save error (non-blocking): $e');
      }
      
      // Navigate to home regardless of Firestore success (fallback to offline support)
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SwasthyaSathi - Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Apna Profile banayein", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Aapka Naam (Name)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emergencyController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Emergency Mobile Number", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _language,
              decoration: const InputDecoration(labelText: "Bhasha (Language)", border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'hindi', child: Text("Hindi")),
                DropdownMenuItem(value: 'english', child: Text("English")),
                DropdownMenuItem(value: 'hinglish', child: Text("Hinglish")),
              ],
              onChanged: (val) => setState(() => _language = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _state,
              decoration: const InputDecoration(labelText: "Rajya (State)", border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'UP', child: Text("Uttar Pradesh")),
                DropdownMenuItem(value: 'BR', child: Text("Bihar")),
                DropdownMenuItem(value: 'MP', child: Text("Madhya Pradesh")),
              ],
              onChanged: (val) => setState(() => _state = val!),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: _isLoading ? const CircularProgressIndicator() : const Text("Save & Start"),
            ),
          ],
        ),
      ),
    );
  }
}
