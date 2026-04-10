import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';

import '../../services/storage_service.dart';
import '../../services/firestore_service.dart';

/// Screen for capturing or picking a discharge document image,
/// cropping it, compressing it, and uploading to Firebase Storage.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

enum _ScanState { idle, processing, uploading, error }

class _ScanScreenState extends State<ScanScreen> {
  final _picker = ImagePicker();
  final _storageService = StorageService();
  final _firestoreService = FirestoreService();

  _ScanState _state = _ScanState.idle;
  double _uploadProgress = 0.0;
  String _statusMessage = '';
  String? _errorMessage;

  // ── Image capture flows ───────────────────────────────────────────

  Future<void> _captureFromCamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 95,
    );
    if (photo != null) await _processImage(photo);
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );
    if (image != null) await _processImage(image);
  }

  // ── Image processing pipeline ─────────────────────────────────────

  Future<void> _processImage(XFile pickedFile) async {
    try {
      setState(() {
        _state = _ScanState.processing;
        _statusMessage = 'Document crop ho raha hai...';
      });

      // Step 1: Crop with A4 aspect ratio (210:297)
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 210, ratioY: 297),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Document Crop करें',
            toolbarColor: const Color(0xFF5C6BC0),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFF5C6BC0),
            lockAspectRatio: false,
          ),
        ],
      );

      if (croppedFile == null) {
        // User cancelled cropping
        setState(() => _state = _ScanState.idle);
        return;
      }

      // Step 2: Compress to <2MB
      setState(() => _statusMessage = 'File compress ho rahi hai...');

      final tempDir = Directory.systemTemp;
      final targetPath =
          '${tempDir.path}/ss_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        croppedFile.path,
        targetPath,
        quality: 85,
        minWidth: 1200,
        minHeight: 1600,
      );

      // Use compressed file if available, otherwise fall back to cropped file
      final finalFile = File(compressedFile?.path ?? croppedFile.path);

      // Step 3: Upload
      await _uploadDocument(finalFile);
    } catch (e) {
      debugPrint('Image processing error: $e');
      if (mounted) {
        setState(() {
          _state = _ScanState.error;
          _errorMessage = 'Document process nahi ho paya. Dobara koshish karein.';
        });
      }
    }
  }

  // ── Upload to Firebase Storage ────────────────────────────────────

  Future<void> _uploadDocument(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _state = _ScanState.error;
        _errorMessage = 'Login session expired. Kripaya dobara login karein.';
      });
      return;
    }

    final uid = user.uid;
    final docId = _firestoreService.generateDocId(uid);

    setState(() {
      _state = _ScanState.uploading;
      _uploadProgress = 0.0;
      _statusMessage = 'Aapki file upload ho rahi hai...';
    });

    try {
      debugPrint('📤 Starting upload: uid=$uid, docId=$docId');
      debugPrint('📤 File size: ${imageFile.lengthSync()} bytes');

      // Start upload IMMEDIATELY — don't wait for Firestore
      final uploadTask = _storageService.uploadDocument(
        uid: uid,
        docId: docId,
        file: imageFile,
      );

      // Create Firestore tracking record in background (non-blocking)
      // This won't hold up the upload even if Firestore has issues
      _firestoreService
          .createDocumentRecord(uid: uid, docId: docId)
          .timeout(const Duration(seconds: 5))
          .then((_) => debugPrint('✅ Firestore record created'))
          .catchError((e) => debugPrint('⚠️ Firestore record failed (non-blocking): $e'));

      // Listen to upload progress
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final transferred = snapshot.bytesTransferred;
          final total = snapshot.totalBytes;
          debugPrint('📤 Upload progress: $transferred / $total');
          if (mounted && total > 0) {
            setState(() {
              _uploadProgress = transferred / total;
            });
          }
        },
        onError: (error) {
          debugPrint('❌ Upload stream error: $error');
          if (mounted) {
            setState(() {
              _state = _ScanState.error;
              _errorMessage = 'Upload fail ho gaya. Internet check karein.';
            });
          }
        },
      );

      // Wait for upload to complete
      debugPrint('📤 Waiting for upload to finish...');
      await uploadTask;
      debugPrint('✅ Upload complete!');

      // Update Firestore status (also non-blocking)
      _firestoreService
          .updateDocumentStatus(uid: uid, docId: docId, status: 'uploaded')
          .timeout(const Duration(seconds: 5))
          .catchError((e) => debugPrint('⚠️ Status update failed: $e'));

      // Navigate to the processing screen
      if (mounted) {
        context.push('/processing', extra: {'uid': uid, 'docId': docId});
        setState(() => _state = _ScanState.idle);
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      if (mounted) {
        setState(() {
          _state = _ScanState.error;
          _errorMessage = 'Upload fail ho gaya. Dobara koshish karein.\n\nError: $e';
        });
      }
    }
  }

  // ── UI ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Scan'),
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _ScanState.idle:
        return _buildIdleView();
      case _ScanState.processing:
        return _buildProcessingView();
      case _ScanState.uploading:
        return _buildUploadingView();
      case _ScanState.error:
        return _buildErrorView();
    }
  }

  // ── Idle: Camera + Gallery buttons ────────────────────────────────

  Widget _buildIdleView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),

          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5C6BC0), Color(0xFF7E57C2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.document_scanner, size: 48, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'Apna discharge paper scan karein',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Camera se photo lein ya gallery se chunein',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Camera button
          _ActionCard(
            icon: Icons.camera_alt,
            title: '📸 Camera se photo lein',
            subtitle: 'Discharge paper ka photo kheenchein',
            color: const Color(0xFF43A047),
            onTap: _captureFromCamera,
          ),

          const SizedBox(height: 16),

          // Gallery button
          _ActionCard(
            icon: Icons.photo_library,
            title: '🖼️ Gallery se chunein',
            subtitle: 'Pehle se li gayi photo chunein',
            color: const Color(0xFF1E88E5),
            onTap: _pickFromGallery,
          ),

          const SizedBox(height: 32),

          // Help text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Paper seedha rakhein aur poori tarah dikhna chahiye. Acchi roshni mein photo lein.',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Processing: crop/compress spinner ─────────────────────────────

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF5C6BC0),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            _statusMessage,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ── Uploading: progress bar ───────────────────────────────────────

  Widget _buildUploadingView() {
    final percent = (_uploadProgress * 100).toInt();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_upload,
              size: 64,
              color: Color(0xFF5C6BC0),
            ),
            const SizedBox(height: 24),
            Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _uploadProgress,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF5C6BC0)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$percent%',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error: retry option ───────────────────────────────────────────

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Kuch galat ho gaya.',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() => _state = _ScanState.idle),
              icon: const Icon(Icons.refresh),
              label: const Text('Dobara koshish karein'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable action card widget ───────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(60)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
