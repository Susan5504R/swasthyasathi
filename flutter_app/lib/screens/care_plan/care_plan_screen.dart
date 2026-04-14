import 'package:flutter/material.dart';

class CarePlanScreen extends StatelessWidget {
  final String docId;

  const CarePlanScreen({super.key, required this.docId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aapka Care Plan'),
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medical_services_outlined, size: 64, color: Color(0xFF5C6BC0)),
            const SizedBox(height: 16),
            Text(
              'Care plan taiyaar hai!\nDocument ID: $docId',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Detail view agli phase mein aayega.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
