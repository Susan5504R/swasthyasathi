import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a document image to Firebase Cloud Storage.
  /// Storage path: /users/{uid}/documents/{docId}/original.jpg
  /// Returns an [UploadTask] so the caller can listen to progress events.
  UploadTask uploadDocument({
    required String uid,
    required String docId,
    required File file,
  }) {
    final storagePath = 'users/$uid/documents/$docId/original.jpg';
    final ref = _storage.ref().child(storagePath);

    // Set metadata so the Cloud Function can identify the file type
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {
        'uid': uid,
        'docId': docId,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );

    return ref.putFile(file, metadata);
  }

  /// Gets the download URL for an uploaded document.
  Future<String> getDownloadUrl({
    required String uid,
    required String docId,
  }) async {
    final storagePath = 'users/$uid/documents/$docId/original.jpg';
    return await _storage.ref().child(storagePath).getDownloadURL();
  }
}
