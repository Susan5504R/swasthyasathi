import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Document tracking ─────────────────────────────────────────────

  /// Creates a document record in Firestore before upload starts.
  /// Path: documents/{uid}/docs/{docId}
  Future<void> createDocumentRecord({
    required String uid,
    required String docId,
  }) async {
    await _db
        .collection('documents')
        .doc(uid)
        .collection('docs')
        .doc(docId)
        .set({
      'processing_status': 'uploading',
      'created_at': FieldValue.serverTimestamp(),
      'uid': uid,
    });
  }

  /// Updates the processing status of a document.
  Future<void> updateDocumentStatus({
    required String uid,
    required String docId,
    required String status,
    Map<String, dynamic>? extraFields,
  }) async {
    final updateData = <String, dynamic>{
      'processing_status': status,
    };
    if (extraFields != null) {
      updateData.addAll(extraFields);
    }

    await _db
        .collection('documents')
        .doc(uid)
        .collection('docs')
        .doc(docId)
        .update(updateData);
  }

  /// Returns a real-time stream of the document's snapshot.
  /// Used by the processing screen to watch for status changes.
  Stream<DocumentSnapshot> documentStatusStream({
    required String uid,
    required String docId,
  }) {
    return _db
        .collection('documents')
        .doc(uid)
        .collection('docs')
        .doc(docId)
        .snapshots();
  }

  /// Generates a unique Firestore document ID for a new upload.
  String generateDocId(String uid) {
    return _db
        .collection('documents')
        .doc(uid)
        .collection('docs')
        .doc()
        .id;
  }

  // ── User profile ──────────────────────────────────────────────────

  /// Checks if a user profile exists in Firestore.
  Future<bool> userProfileExists(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists;
  }
}
