const functions = require('firebase-functions');

// Listens to uploads to Firebase Storage

exports.onDocumentUpload = functions
  .region('asia-south1')
  .storage.object()
  .onFinalize(async (object) => {
    const filePath = object.name;
    
    // Check if the uploaded file is in a 'documents' path.
    // We expect paths like: users/{uid}/documents/{docId}/original.jpg
    if (!filePath.includes('/documents/')) {
        console.log(`Skipping file: ${filePath}`);
        return null;
    }

    console.log(`New document uploaded: ${filePath}`);

    try {
        const parts = filePath.split('/');
        // Find indices of users and documents for robustness
        const uidIndex = parts.indexOf('users') + 1;
        const docIdIndex = parts.indexOf('documents') + 1;
        
        if (uidIndex === 0 || docIdIndex === 0 || uidIndex >= parts.length || docIdIndex >= parts.length) {
            console.error('Invalid file path structure for UID/docId extraction.');
            return null;
        }

        const uid = parts[uidIndex];
        const docId = parts[docIdIndex];

        // Retrieve the Cloud Run URL from Firebase Functions configuration, 
        // fallback to process.env for local or flexible setups.
        const CLOUD_RUN_URL = functions.config().cloudrun?.url || process.env.CLOUD_RUN_URL || 'http://localhost:8080';

        if (!CLOUD_RUN_URL) {
            console.error('CLOUD_RUN_URL is not set. Please set it using: firebase functions:config:set cloudrun.url="..."');
            return null;
        }

        console.log(`Triggering processing for user: ${uid}, document: ${docId} at ${CLOUD_RUN_URL}/process`);

        // Node.js 20 has native fetch
        const response = await fetch(`${CLOUD_RUN_URL}/process`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                uid: uid, 
                docId: docId, 
                storagePath: filePath 
            }),
        });

        if (!response.ok) {
            const errorText = await response.text();
            console.error(`Failed to trigger backend. Status: ${response.status}, Error: ${errorText}`);
        } else {
            console.log(`Backend triggered successfully for ${docId}`);
        }
        
    } catch (error) {
        console.error('Error triggering backend processing:', error);
    }


    return null;
  });
