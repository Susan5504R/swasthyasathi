import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../services/firestore_service.dart';

/// Screen that listens to Firestore in real-time for document processing
/// status updates. Automatically navigates to the care plan when processing
/// completes, or shows an error if it fails.
class ProcessingScreen extends StatefulWidget {
  final String uid;
  final String docId;

  const ProcessingScreen({
    super.key,
    required this.uid,
    required this.docId,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Maps processing status codes to user-friendly Hindi messages.
  String _statusToHindi(String? status) {
    switch (status) {
      case 'uploading':
        return 'File upload ho rahi hai...';
      case 'uploaded':
        return 'File mil gayi. Processing shuru ho rahi hai...';
      case 'processing':
        return 'Aapka document padha ja raha hai...';
      case 'extracting':
        return 'Dawai aur jaankari nikali ja rahi hai...';
      case 'translating':
        return 'Hindi mein translate ho raha hai...';
      case 'done':
        return 'Taiyaar hai! Care plan ban gaya.';
      case 'failed':
        return 'Kuch galat ho gaya.';
      default:
        return 'Processing ho rahi hai...';
    }
  }

  /// Returns a progress value (0.0 to 1.0) based on status for the stepper.
  double _statusToProgress(String? status) {
    switch (status) {
      case 'uploading':
        return 0.1;
      case 'uploaded':
        return 0.25;
      case 'processing':
        return 0.4;
      case 'extracting':
        return 0.6;
      case 'translating':
        return 0.8;
      case 'done':
        return 1.0;
      default:
        return 0.15;
    }
  }

  void _showErrorDialog(String? errorReason) {
    final message = errorReason == 'low_confidence'
        ? 'Yeh document clearly nahi dikh raha. Dobara scan karein — acchi roshni mein, seedha rakhein.'
        : errorReason == 'extraction_failed'
            ? 'Document se jaankari nahi nikal payi. Kripaya ek aur baar try karein.'
            : 'Processing mein dikkat aayi. Kripaya dobara koshish karein.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop(); // Go back to scan screen
            },
            child: const Text('Dobara Scan Karein'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing'),
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestoreService.documentStatusStream(
          uid: widget.uid,
          docId: widget.docId,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState('Firestore connection error.');
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final status = data?['processing_status'] as String?;
          final errorReason = data?['error_reason'] as String?;

          // Auto-navigate to care plan when processing is done
          if (status == 'done') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Care plan taiyaar hai!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Navigate to care plan screen, passing the docId
                context.push('/care-plan', extra: widget.docId);
              }
            });
          }

          // Show error dialog on failure
          if (status == 'failed') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _showErrorDialog(errorReason);
            });
          }

          return _buildProcessingView(status);
        },
      ),
    );
  }

  Widget _buildProcessingView(String? status) {
    final progress = _statusToProgress(status);
    final hindiStatus = _statusToHindi(status);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated pulse icon
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C6BC0).withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.description,
                      size: 56,
                      color: Color(0xFF5C6BC0),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Status text
            Text(
              hindiStatus,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF5C6BC0)),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 40),

            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF5C6BC0)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI aapka document padh raha hai. Isme 10-15 second lag sakte hain.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Wapas jaayein'),
          ),
        ],
      ),
    );
  }
}
