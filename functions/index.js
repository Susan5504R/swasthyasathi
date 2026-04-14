const functions = require('firebase-functions');

// Listens to uploads to Firebase Storage

exports.onDocumentUpload = functions
  .region('asia-south1')
  .storage.object()
  .onFinalize(async (object) => {
    const filePath = object.name;
    
    // We expect paths like: users/{uid}/documents/{docId}/original.jpg
    // Split: ['users', uid, 'documents', docId, 'original.jpg']
    const parts = filePath.split('/');
    
    if (parts.length < 5 || parts[0] !== 'users' || parts[2] !== 'documents') {
      console.log(`Ignoring file: ${filePath} (not a user discharge document)`);
      return null;
    }

    const uid = parts[1];
    const docId = parts[3];

    // Using Firebase Functions config or standard environment variables
    const CLOUD_RUN_URL = process.env.CLOUD_RUN_URL || 'http://localhost:8080';

    if (!CLOUD_RUN_URL) {
      console.error("CLOUD_RUN_URL is not set.");
      return null;
    }

    console.log(`Triggering processing for user: ${uid}, document: ${docId}`);

    try {
      // Node.js 20 has native fetch
      const response = await fetch(`${CLOUD_RUN_URL}/process`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          uid,
          docId,
          storagePath: filePath
        }),
      });

      if (!response.ok) {
        console.error(`Backend returned ${response.status}: ${response.statusText}`);
      } else {
        console.log(`Successfully triggered Cloud Run for ${docId}`);
      }
    } catch (error) {
      console.error(`Error making request to Cloud Run: ${error}`);
    }


    return null;
  });
