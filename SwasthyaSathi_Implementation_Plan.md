# SwasthyaSathi — Developer Implementation Plan
### AI Copilot for Post-Hospital Care Paperwork | Google Solution Challenge 2025

---

## 1. Project Overview

SwasthyaSathi is a Flutter-based AI application that decodes Indian hospital discharge summaries into simple, actionable Hindi care plans for low-income caregivers. The app targets semi-literate families in tier-2 and tier-3 Indian cities — people who walk out of hospitals holding discharge papers they cannot read, in a language they don't fully understand, with medicine schedules they cannot follow. The core pipeline uses Google Document AI for layout-aware OCR, Gemini 1.5 Flash for structured medical extraction and Hindi translation, and Firebase for auth, storage, and real-time sync. A successful build is a working Android app where a caregiver can photograph a real discharge paper from GSVM or LLR Hospital in Kanpur and receive a complete, readable Hindi care plan — with medication reminders, a chatbot for questions, and a government scheme eligibility guide — in under 15 seconds, accessible offline after first load.

---

## 2. Recommended Tech Stack

### Frontend

| Tool | Pros | Cons | Pricing | Best For | Verdict |
|------|------|------|---------|----------|---------|
| **Flutter (Dart)** | Single codebase Android + iOS, native Devanagari rendering, offline support, Google Solution Challenge winner pattern | Dart learning curve, larger APK size | Free | Cross-platform mobile with offline | ✅ **USE THIS** |
| React Native | JavaScript ecosystem, large community | Poor Devanagari font handling, weaker offline story | Free | JS-heavy teams | Skip |
| Kotlin Native Android | Smallest APK, best Android performance | No iOS, 2x development time | Free | Android-only MVPs | Skip |

**Verdict**: Flutter. Every Google Solution Challenge winning app (ATTI, Alpha Eye, Spoon Share) used Flutter. It has proven Devanagari rendering, offline Firestore persistence, and the camera/FCM integrations you need out of the box.

### Backend

| Tool | Pros | Cons | Pricing | Best For | Verdict |
|------|------|------|---------|----------|---------|
| **Python FastAPI on Cloud Run** | Stateless, auto-scales 0→N, free tier generous, easy Google SDK integration | Cold start latency (~1–2s) on first request | Free tier: 2M requests/month, 360K vCPU-sec/month | Scalable serverless AI backends | ✅ **USE THIS** |
| Node.js Cloud Run | Faster cold starts | Less mature ML libraries | Same | JS teams | Skip |
| Firebase Cloud Functions | Zero infra management | 9-minute timeout, weaker AI library support | Free tier generous | Simple triggers only | Use for triggers only, not main AI pipeline |
| Google App Engine | Managed, auto-scaling | Higher cost, less control | $0.05/vCPU-hr | Always-on services | Skip |

**Verdict**: FastAPI on Cloud Run for the AI pipeline. Judges specifically reward stateless containerised backends for scalability scoring.

### AI / ML

| Tool | Pros | Cons | Pricing | Best For | Verdict |
|------|------|------|---------|----------|---------|
| **Gemini 1.5 Flash** | Fast (1–3s), cheap, sufficient accuracy for extraction + translation | Not as capable as Pro on complex reasoning | ~$0.075/1M input tokens | High-volume structured extraction | ✅ **USE THIS** |
| Gemini 1.5 Pro | Best accuracy | 5–10x more expensive, slower | ~$3.50/1M input tokens | Complex reasoning | Overkill for this use case |
| GPT-4o | Excellent quality | Not a Google product — loses points in Google Solution Challenge | ~$2.50/1M input tokens | OpenAI ecosystem | Skip |

| Tool | Pros | Cons | Pricing | Best For | Verdict |
|------|------|------|---------|----------|---------|
| **Google Document AI (Form Parser)** | Layout-aware, handles multi-column Indian hospital formats, confidence scoring, mixed Hindi+English | Regional pricing, slower than raw Vision API | ~$1.50/1K pages | Structured document OCR | ✅ **USE THIS** |
| Gemini Vision (direct) | One API call | Less accurate on multi-column layouts, no confidence scoring | Included with Gemini | Simple document reading | Use as fallback only |
| Google Cloud Vision API | Fast, cheaper | Not layout-aware, poor multi-column support | ~$1.50/1K units | Simple image text extraction | Skip |

### Database

| Tool | Pros | Cons | Pricing | Best For | Verdict |
|------|------|------|---------|----------|---------|
| **Cloud Firestore** | Offline persistence (critical!), real-time sync, serverless, scales automatically | NoSQL — complex queries harder | Free: 50K reads/day, 20K writes/day | Real-time offline-first mobile apps | ✅ **USE THIS** |
| Firebase Realtime DB | Simpler JSON structure | No offline per-document persistence, harder to query | Free: 1 GB storage | Simple real-time apps | Skip |
| PostgreSQL (Cloud SQL) | Powerful queries, relational | No offline, much more expensive, requires connection pooling | ~$7/month minimum | Complex relational data | Skip |

### Auth / Notifications / Storage

All Firebase services — no meaningful alternatives for Google Solution Challenge: Firebase Auth (Phone OTP), Firebase Cloud Storage, Firebase Cloud Messaging, Firebase Analytics, Firebase Crashlytics, Firebase Remote Config.

### Maps

| Tool | Pros | Cons | Pricing | Best For | Verdict |
|------|------|------|---------|----------|---------|
| **Google Maps Platform** | Best India coverage, PHC/CSC data, bonus points in GSC | Costs money beyond free tier | $200/month free credit | India location services | ✅ **USE THIS** |
| OpenStreetMap / Mapbox | Free | Poor rural India POI data for PHC/CSC | Free | Cost-sensitive projects | Skip |

### Final Recommended Stack

| Category | Choice | Why |
|----------|--------|-----|
| Frontend | Flutter 3.x (Dart) | Cross-platform, Devanagari, offline, GSC winner pattern |
| Backend | Python 3.12 + FastAPI on Cloud Run | Stateless, scalable, Google SDK support |
| Database | Cloud Firestore | Offline persistence is non-negotiable |
| File Storage | Firebase Cloud Storage | Integrated with Security Rules |
| Auth | Firebase Auth (Phone OTP) | No email needed — right for this demographic |
| AI Extraction | Gemini 1.5 Flash | Fast, cheap, sufficient |
| OCR | Google Document AI Form Parser | Layout-aware, confidence scoring |
| Notifications | Firebase Cloud Messaging + Cloud Scheduler | Free, reliable Hindi push notifications |
| Voice In | Google Cloud Speech-to-Text (hi_IN) | Devanagari output, proven Hindi accuracy |
| Voice Out | Google Cloud Text-to-Speech (hi-IN-Wavenet-A) | Natural Hindi TTS |
| Maps | Google Maps Platform (Places + Directions API) | Best India PHC/CSC coverage |
| CI/CD | GitHub + Cloud Build | Auto-deploy on push to main |
| Monitoring | Cloud Monitoring + Logging | Latency graphs for submission |
| Feature Flags | Firebase Remote Config | Toggle features without app update |

---

## 3. Prerequisites

Complete everything in this section before writing a single line of application code.

### Accounts to Create

- [ ] Google Account (personal or team) — used for all Google/Firebase consoles
- [ ] Firebase Console account at `console.firebase.google.com`
- [ ] Google Cloud Console account at `console.cloud.google.com`
- [ ] GitHub account for repository hosting
- [ ] Google Play Developer account ($25 one-time) — needed for eventual submission, not required for development

### Google Cloud Project Setup

- [ ] Create a new Google Cloud project named `swasthyasathi` at `console.cloud.google.com`
- [ ] Note your `PROJECT_ID` — you'll use it in every config file
- [ ] Enable billing on the project (required for Document AI, Maps, Cloud Run)
- [ ] Enable these APIs in Cloud Console → APIs & Services → Enable APIs:
  - [ ] Cloud Document AI API
  - [ ] Gemini API (Generative Language API)
  - [ ] Cloud Speech-to-Text API
  - [ ] Cloud Text-to-Speech API
  - [ ] Maps JavaScript API
  - [ ] Places API
  - [ ] Directions API
  - [ ] Cloud Run API
  - [ ] Cloud Build API
  - [ ] Secret Manager API
  - [ ] Cloud Scheduler API
  - [ ] Cloud Logging API
  - [ ] Cloud Monitoring API

### Firebase Project Setup

- [ ] Go to `console.firebase.google.com` → Add project → select the Google Cloud project `swasthyasathi` created above (this links them)
- [ ] Enable these Firebase services:
  - [ ] Authentication → Phone provider → enable
  - [ ] Firestore Database → create in `asia-south1` region → start in test mode (you'll lock it down in Phase 1)
  - [ ] Storage → create in `asia-south1`
  - [ ] Cloud Messaging (auto-enabled)
  - [ ] Analytics (enable)
  - [ ] Crashlytics (enable)
  - [ ] Remote Config (enable)
  - [ ] App Check (enable — use Play Integrity for production)
- [ ] Add Android app to Firebase project → download `google-services.json`
- [ ] Add iOS app if targeting iOS → download `GoogleService-Info.plist`

### Document AI Processor

- [ ] Go to Cloud Console → Document AI → Create Processor
- [ ] Select "Form Parser" processor type
- [ ] Region: `us` (not `eu` — the Python SDK defaults to us and switching region requires extra config)
- [ ] Note the `PROCESSOR_ID` from the processor details page

### API Keys and Secrets

- [ ] Create a Gemini API key at `aistudio.google.com/app/apikey`
- [ ] Create a Maps API key at Cloud Console → APIs & Services → Credentials → Create API Key
  - Restrict the Maps key to: Maps SDK for Android, Places API, Directions API
- [ ] Store ALL keys in Google Secret Manager (never hardcode):
  ```bash
  echo -n "your-gemini-key" | gcloud secrets create gemini-api-key --data-file=-
  echo -n "your-maps-key" | gcloud secrets create maps-api-key --data-file=-
  ```

### Software to Install (Local Machine)

- [ ] Flutter SDK 3.22+ — `flutter.dev/docs/get-started/install`
- [ ] Dart SDK (bundled with Flutter)
- [ ] Android Studio + Android SDK (API Level 21+, target API 34)
- [ ] VS Code + Flutter extension (optional but recommended)
- [ ] Python 3.12 — `python.org/downloads`
- [ ] Docker Desktop — `docs.docker.com/get-docker`
- [ ] Google Cloud SDK (`gcloud` CLI) — `cloud.google.com/sdk/docs/install`
- [ ] Node.js 20 LTS — for Firebase CLI
- [ ] Firebase CLI: `npm install -g firebase-tools` then `firebase login`

### Local Environment Verification

Run these to confirm setup is correct before starting:
```bash
flutter doctor          # All green except Web if not needed
gcloud auth login
gcloud config set project swasthyasathi
firebase projects:list  # Should show your project
docker --version        # Should return a version
python3 --version       # Should be 3.12.x
```

### Repository Setup

- [ ] Create GitHub repository: `swasthyasathi` — set to Public (required for submission)
- [ ] Clone locally: `git clone https://github.com/your-team/swasthyasathi`
- [ ] Create project structure:
  ```
  swasthyasathi/
  ├── flutter_app/          # Flutter frontend
  ├── backend/              # Python FastAPI Cloud Run backend
  ├── functions/            # Firebase Cloud Functions (Node.js)
  ├── firestore/            # Security rules and indexes
  ├── cloudbuild.yaml       # CI/CD config
  ├── architecture.png      # Architecture diagram for submission
  ├── sample_discharge.jpg  # Anonymised sample for judges to test
  └── README.md             # Submission README
  ```
- [ ] Create `.gitignore` at root — must exclude: `google-services.json`, `GoogleService-Info.plist`, `.env`, `*.key`, `service-account.json`
- [ ] Create `.env.example` with placeholder values for all secrets

---

## 4. Implementation Phases

---

## Phase 1: Project Setup & Architecture
**Goal:** All services connected, skeleton apps running, CI/CD pipeline live.
**Estimated Time:** 2–3 days
**Builds on:** Standalone — this is the foundation everything else requires.

### What We're Building
A working Flutter skeleton that connects to Firebase, a FastAPI backend that deploys to Cloud Run and returns a health check, and an automated CI/CD pipeline so every push to `main` deploys the backend automatically. No features yet — just proven connectivity between all systems.

---

### Sub-Phase 1.1 — Flutter App Skeleton

**What:** Create the Flutter project with the correct folder structure and all packages installed.

**How:**
- [ ] Run `flutter create flutter_app --org com.swasthyasathi` inside the repo
- [ ] Open `flutter_app/pubspec.yaml` and add all required dependencies:
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    # Firebase
    firebase_core: ^3.0.0
    firebase_auth: ^5.0.0
    cloud_firestore: ^5.0.0
    firebase_storage: ^12.0.0
    firebase_messaging: ^15.0.0
    firebase_analytics: ^11.0.0
    firebase_crashlytics: ^4.0.0
    firebase_remote_config: ^5.0.0
    # Camera & file handling
    camera: ^0.11.0
    file_picker: ^8.0.0
    image_picker: ^1.0.0
    image_cropper: ^8.0.0
    # Google services
    google_maps_flutter: ^2.0.0
    speech_to_text: ^7.0.0
    # State & navigation
    provider: ^6.0.0
    go_router: ^14.0.0
    # UI utilities
    flutter_local_notifications: ^18.0.0
    cached_network_image: ^3.0.0
    intl: ^0.19.0
    pdf: ^3.0.0
    share_plus: ^10.0.0
    url_launcher: ^6.0.0
    connectivity_plus: ^6.0.0
    http: ^1.0.0
  ```
- [ ] Run `flutter pub get` — resolve any version conflicts before continuing
- [ ] Create folder structure inside `lib/`:
  ```
  lib/
  ├── main.dart
  ├── app.dart                    # MaterialApp + GoRouter setup
  ├── models/
  │   ├── care_plan.dart
  │   ├── medicine.dart
  │   ├── user_profile.dart
  │   └── reminder.dart
  ├── screens/
  │   ├── splash_screen.dart
  │   ├── auth/
  │   │   ├── phone_login_screen.dart
  │   │   └── otp_verify_screen.dart
  │   ├── onboarding/
  │   │   └── onboarding_screen.dart
  │   ├── home/
  │   │   └── home_screen.dart
  │   ├── scan/
  │   │   └── scan_screen.dart
  │   ├── care_plan/
  │   │   └── care_plan_screen.dart
  │   ├── chat/
  │   │   └── chat_screen.dart
  │   ├── scheme/
  │   │   └── scheme_screen.dart
  │   ├── reminders/
  │   │   └── reminders_screen.dart
  │   └── history/
  │       └── history_screen.dart
  ├── services/
  │   ├── auth_service.dart
  │   ├── firestore_service.dart
  │   ├── storage_service.dart
  │   ├── api_service.dart
  │   └── notification_service.dart
  └── widgets/
      ├── medicine_card.dart
      ├── danger_signs_card.dart
      └── loading_widget.dart
  ```
- [ ] Copy `google-services.json` into `flutter_app/android/app/`
- [ ] Add `classpath 'com.google.gms:google-services:4.4.0'` to `android/build.gradle`
- [ ] Add `apply plugin: 'com.google.gms.google-services'` to `android/app/build.gradle`
- [ ] Initialise Firebase in `main.dart`:
  ```dart
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    // Enable Firestore offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    runApp(const MyApp());
  }
  ```
- [ ] Run `flutter run` — confirm app launches on Android emulator without crash

**End Goal:** Flutter app launches on Android, connects to Firebase without errors, and the console shows no missing `google-services.json` errors.

---

### Sub-Phase 1.2 — Python FastAPI Backend on Cloud Run

**What:** A containerised FastAPI app with a `/health` endpoint that deploys to Cloud Run.

**How:**
- [ ] Inside `backend/`, create `main.py`:
  ```python
  from fastapi import FastAPI
  app = FastAPI()

  @app.get("/health")
  def health():
      return {"status": "ok", "service": "swasthyasathi-api"}
  ```
- [ ] Create `backend/requirements.txt`:
  ```
  fastapi==0.115.0
  uvicorn==0.32.0
  google-cloud-documentai==3.0.0
  google-generativeai==0.8.0
  google-cloud-speech==2.0.0
  google-cloud-texttospeech==2.0.0
  firebase-admin==6.0.0
  google-cloud-firestore==2.0.0
  google-cloud-storage==2.0.0
  pydantic==2.0.0
  python-multipart==0.0.9
  httpx==0.27.0
  ```
- [ ] Create `backend/Dockerfile`:
  ```dockerfile
  FROM python:3.12-slim
  WORKDIR /app
  COPY requirements.txt .
  RUN pip install --no-cache-dir -r requirements.txt
  COPY . .
  CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
  ```
- [ ] Test locally: `docker build -t swasthyasathi-api . && docker run -p 8080:8080 swasthyasathi-api`
- [ ] Verify: `curl http://localhost:8080/health` returns `{"status": "ok"}`
- [ ] Deploy to Cloud Run manually first time:
  ```bash
  cd backend
  gcloud builds submit --tag gcr.io/swasthyasathi/swasthyasathi-api
  gcloud run deploy swasthyasathi-api \
    --image gcr.io/swasthyasathi/swasthyasathi-api \
    --region asia-south1 \
    --platform managed \
    --allow-unauthenticated \
    --memory 512Mi \
    --max-instances 10
  ```
- [ ] Note the Cloud Run URL — you'll set it in Flutter's `api_service.dart` as `CLOUD_RUN_BASE_URL`

**End Goal:** `curl https://your-cloud-run-url/health` returns 200 from a public URL.

---

### Sub-Phase 1.3 — CI/CD Pipeline

**What:** GitHub push to `main` automatically builds and deploys the backend to Cloud Run.

**How:**
- [ ] Create `cloudbuild.yaml` at repo root:
  ```yaml
  steps:
    - name: 'gcr.io/cloud-builders/docker'
      args: ['build', '-t', 'gcr.io/$PROJECT_ID/swasthyasathi-api', './backend']
    - name: 'gcr.io/cloud-builders/docker'
      args: ['push', 'gcr.io/$PROJECT_ID/swasthyasathi-api']
    - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
      args:
        - 'run'
        - 'deploy'
        - 'swasthyasathi-api'
        - '--image=gcr.io/$PROJECT_ID/swasthyasathi-api'
        - '--region=asia-south1'
        - '--platform=managed'
  ```
- [ ] In Cloud Console → Cloud Build → Triggers → Create trigger:
  - Source: your GitHub repo
  - Branch: `^main$`
  - Build config: Cloud Build configuration file → `/cloudbuild.yaml`
- [ ] Grant Cloud Build service account the Cloud Run Admin and Service Account User roles in IAM
- [ ] Push a dummy commit to `main` and verify Cloud Build runs and deployment succeeds

**End Goal:** Every push to `main` automatically redeploys the backend — no manual `gcloud run deploy` needed.

---

### Sub-Phase 1.4 — Firestore Security Rules

**What:** Lock down Firestore and Cloud Storage so users can only access their own data.

**How:**
- [ ] Create `firestore/firestore.rules`:
  ```javascript
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /users/{uid} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
      match /care_plans/{uid}/{docId} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
      match /documents/{uid}/{docId} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
      match /reminders/{uid}/{reminderId} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
      match /scheme_rules/{schemeId} {
        allow read: if request.auth != null;
        allow write: if false;
      }
    }
  }
  ```
- [ ] Create `firestore/storage.rules`:
  ```javascript
  rules_version = '2';
  service firebase.storage {
    match /b/{bucket}/o {
      match /users/{uid}/documents/{allPaths=**} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
    }
  }
  ```
- [ ] Deploy rules: `firebase deploy --only firestore:rules,storage`

**End Goal:** Unauthenticated requests to Firestore and Storage are rejected. Authenticated users can only read/write their own documents.

---

### Phase 1 End Goal
A Flutter app that launches and connects to Firebase. A Cloud Run backend that returns a 200 health check. A CI/CD pipeline that redeploys on every push to `main`. Firestore and Storage locked down with security rules. The repo is clean, `.gitignore` is correct, no secrets are committed.

---

## Phase 2: Authentication & Document Upload
**Goal:** Users can log in with phone OTP, complete onboarding, and upload a discharge document that appears in Firebase Cloud Storage.
**Estimated Time:** 3–4 days
**Builds on:** Phase 1

### What We're Building
The complete authentication flow (phone → OTP → onboarding → home), a camera capture screen with crop overlay, gallery/file picker support, image compression, Cloud Storage upload with progress, and a Firestore document record created on upload. A Firebase Cloud Function watches Storage and triggers the backend. The user sees a real-time "Processing..." status via Firestore listener.

---

### Sub-Phase 2.1 — Phone OTP Authentication

**What:** Phone number entry → OTP verify → Firestore user profile creation → onboarding flow.

**How:**
- [ ] In Firebase Console → Authentication → Sign-in method → Phone → Enable
- [ ] Create `lib/services/auth_service.dart` with `sendOTP()` and `verifyOTP()` methods:
  ```dart
  // auth_service.dart
  Future<void> sendOTP(String phoneNumber, Function(String) onCodeSent) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      verificationCompleted: (credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (e) => throw e,
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential> verifyOTP(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
  ```
- [ ] Create `lib/screens/auth/phone_login_screen.dart` — Hindi UI: "Apna mobile number dalein", large number keyboard, "OTP bhejein" button
- [ ] Create `lib/screens/auth/otp_verify_screen.dart` — 6-digit OTP input, 60-second resend timer, "Verify karein" button
- [ ] After successful login, check Firestore `users/{uid}` — if no profile exists, redirect to onboarding; if profile exists, go to Home
- [ ] Create `lib/screens/onboarding/onboarding_screen.dart` — collect: name, language preference (Hindi/English/Hinglish), state (UP dropdown), emergency contact number
- [ ] On onboarding complete, write to Firestore `users/{uid}`:
  ```json
  {
    "name": "Ramkali Devi",
    "language": "hindi",
    "state": "UP",
    "emergency_contact": "9876543210",
    "font_size": "medium",
    "created_at": "timestamp"
  }
  ```
- [ ] Use `GoRouter` with auth guard — redirect unauthenticated users to `/login`

**End Goal:** A real phone number receives an OTP SMS, user enters it, profile is created in Firestore, and the app navigates to Home.

---

### Sub-Phase 2.2 — Document Capture & Upload

**What:** Camera screen with crop overlay, gallery picker, image compression, Cloud Storage upload with progress indicator.

**How:**
- [ ] Create `lib/screens/scan/scan_screen.dart` with two primary actions:
  - Camera button → opens camera preview using `camera` package
  - Gallery button → opens file picker using `file_picker` (supports JPG, PNG, PDF)
- [ ] After capture, open `image_cropper` with aspect ratio lock (A4 ratio: 210:297) — shows crop overlay
- [ ] After crop, compress image to < 2MB using `flutter_image_compress`:
  ```dart
  final compressed = await FlutterImageCompress.compressAndGetFile(
    cropResult.path,
    outputPath,
    quality: 85,
    minWidth: 1200,
    minHeight: 1600,
  );
  ```
- [ ] Create a Firestore document in `documents/{uid}/{docId}` before upload starts:
  ```json
  {
    "processing_status": "uploading",
    "created_at": "timestamp",
    "uid": "user_uid"
  }
  ```
- [ ] Upload to Firebase Cloud Storage at `/users/{uid}/documents/{docId}/original.jpg` with progress:
  ```dart
  final uploadTask = storageRef.putFile(imageFile);
  uploadTask.snapshotEvents.listen((event) {
    final progress = event.bytesTransferred / event.totalBytes;
    setState(() => _uploadProgress = progress);
  });
  ```
- [ ] Show Hindi upload progress: "Aapki file upload ho rahi hai..." with a linear progress bar
- [ ] On upload complete, navigate to a "Processing" screen that listens to `documents/{uid}/{docId}` in real-time

**End Goal:** User photographs a discharge paper, crops it, and the file appears in Firebase Cloud Storage while the app shows a real upload progress bar.

---

### Sub-Phase 2.3 — Storage Trigger & Processing Status

**What:** Firebase Cloud Function that fires when a new file is uploaded and calls the Cloud Run backend. Flutter listens to Firestore for real-time status updates.

**How:**
- [ ] Create `functions/index.js` — Node.js Cloud Function:
  ```javascript
  const functions = require('firebase-functions');
  const fetch = require('node-fetch');

  exports.onDocumentUpload = functions
    .region('asia-south1')
    .storage.object()
    .onFinalize(async (object) => {
      if (!object.name.includes('/documents/')) return;

      const parts = object.name.split('/');
      const uid = parts[1];
      const docId = parts[3];

      const CLOUD_RUN_URL = process.env.CLOUD_RUN_URL;

      await fetch(`${CLOUD_RUN_URL}/process`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ uid, docId, storagePath: object.name }),
      });
    });
  ```
- [ ] Set `CLOUD_RUN_URL` environment variable in Firebase Functions config:
  ```bash
  firebase functions:config:set cloudrun.url="https://your-cloud-run-url"
  ```
- [ ] Deploy: `firebase deploy --only functions`
- [ ] Create the Processing screen in Flutter — use `StreamBuilder` on `documents/{uid}/{docId}`:
  ```dart
  StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
      .collection('documents').doc(uid).collection('docs').doc(docId)
      .snapshots(),
    builder: (context, snapshot) {
      final status = snapshot.data?['processing_status'];
      if (status == 'done') Navigator.pushNamed(context, '/care-plan', arguments: docId);
      if (status == 'failed') showErrorDialog(context, snapshot.data?['error_reason']);
      return ProcessingSpinnerWidget(status: status);
    },
  )
  ```
- [ ] The `/process` Cloud Run endpoint (stub for now) should update `processing_status` to `"processing"` immediately on receipt

**End Goal:** Upload completes → Cloud Function fires → Cloud Run receives the call → Firestore document updates to `processing` → Flutter shows a real-time status spinner (no refresh needed).

---

### Phase 2 End Goal
A user can log in with their phone number using OTP, complete onboarding, photograph or upload a discharge paper, see it upload with a progress bar, and see the processing status update in real-time via Firestore. The document is safely in Cloud Storage. Authentication is working end-to-end.

---

## Phase 3: Core AI Pipeline (Document AI + Gemini)
**Goal:** A Cloud Storage upload triggers the full AI pipeline — Document AI OCR → confidence check → Gemini extraction → Gemini Hindi translation → Hindi care plan written to Firestore.
**Estimated Time:** 4–5 days (**This phase commonly runs over — budget extra time**)
**Builds on:** Phase 2

### What We're Building
The heart of SwasthyaSathi. The `/process` FastAPI endpoint downloads the uploaded image, runs it through Google Document AI, checks OCR confidence, calls Gemini twice (extraction then Hindi rewrite), validates with Pydantic, and writes the structured Hindi care plan to Firestore. The target is end-to-end processing in under 15 seconds on a real discharge paper.

---

### Sub-Phase 3.1 — Document AI OCR Integration

**What:** Cloud Run downloads the uploaded image from Storage and runs Google Document AI on it.

**How:**
- [ ] Add the `/process` POST endpoint to `backend/main.py`:
  ```python
  from fastapi import FastAPI, HTTPException
  from pydantic import BaseModel
  import firebase_admin
  from firebase_admin import credentials, firestore, storage as fb_storage
  from google.cloud import documentai

  app = FastAPI()
  firebase_admin.initialize_app()

  class ProcessRequest(BaseModel):
      uid: str
      docId: str
      storagePath: str

  @app.post("/process")
  async def process_document(req: ProcessRequest):
      # Update status to processing
      db = firestore.client()
      doc_ref = db.collection('documents').document(req.uid).collection('docs').document(req.docId)
      doc_ref.update({"processing_status": "processing"})
      # ... pipeline continues
  ```
- [ ] Download image from Cloud Storage in the endpoint:
  ```python
  bucket = fb_storage.bucket()
  blob = bucket.blob(req.storagePath)
  image_bytes = blob.download_as_bytes()
  mime_type = blob.content_type or "image/jpeg"
  ```
- [ ] Create `backend/services/document_ai_service.py`:
  ```python
  from google.cloud import documentai
  import os

  PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT")
  PROCESSOR_ID = os.environ.get("DOCUMENT_AI_PROCESSOR_ID")

  def process_document(image_bytes: bytes, mime_type: str) -> tuple[str, float]:
      client = documentai.DocumentProcessorServiceClient()
      processor_name = f"projects/{PROJECT_ID}/locations/us/processors/{PROCESSOR_ID}"

      raw_document = documentai.RawDocument(content=image_bytes, mime_type=mime_type)
      request = documentai.ProcessRequest(name=processor_name, raw_document=raw_document)

      result = client.process_document(request=request)
      document = result.document

      full_text = document.text
      confidences = [
          token.layout.confidence
          for page in document.pages
          for token in page.tokens
      ]
      avg_confidence = sum(confidences) / len(confidences) if confidences else 0.0

      return full_text, avg_confidence
  ```
- [ ] Add confidence threshold check in `/process`:
  ```python
  raw_text, avg_confidence = process_document(image_bytes, mime_type)

  CONFIDENCE_THRESHOLD = float(os.environ.get("OCR_CONFIDENCE_THRESHOLD", "0.70"))
  if avg_confidence < CONFIDENCE_THRESHOLD:
      doc_ref.update({
          "processing_status": "failed",
          "error_reason": "low_confidence",
          "avg_confidence": avg_confidence
      })
      return {"status": "failed", "reason": "low_confidence", "confidence": avg_confidence}
  ```
- [ ] Log OCR confidence to Cloud Logging:
  ```python
  import google.cloud.logging
  logging_client = google.cloud.logging.Client()
  logger = logging_client.logger("swasthyasathi-pipeline")
  logger.log_struct({"event": "ocr_complete", "doc_id": req.docId, "confidence": avg_confidence})
  ```
- [ ] Store `DOCUMENT_AI_PROCESSOR_ID` and `OCR_CONFIDENCE_THRESHOLD` in Cloud Run environment variables or Secret Manager
- [ ] Test the OCR step with a real discharge paper image — print `raw_text` and verify it contains medicine names and dosages

**End Goal:** Upload triggers the pipeline, Document AI extracts text, and if confidence is below 0.70, Firestore gets `processing_status: "failed"` with `error_reason: "low_confidence"`. Flutter displays "Yeh document clearly nahi dikh raha. Dobara scan karein."

---

### Sub-Phase 3.2 — Gemini Call 1: Medical Entity Extraction

**What:** Pass raw OCR text through Gemini 1.5 Flash to extract structured medical JSON.

**How:**
- [ ] Create `backend/services/gemini_service.py`:
  ```python
  import google.generativeai as genai
  import json, os

  genai.configure(api_key=os.environ.get("GEMINI_API_KEY"))
  model = genai.GenerativeModel("gemini-1.5-flash")

  EXTRACTION_PROMPT = """
  SYSTEM:
  You are a medical data extractor for Indian hospital documents.
  Extract information from the OCR text below and return ONLY a JSON object.
  Do not add explanations, markdown formatting, or code blocks.
  If a field is not found in the text, use null for strings or [] for arrays.

  Return EXACTLY this JSON structure:
  {
    "hospital_name": "string or null",
    "document_date": "YYYY-MM-DD or null",
    "diagnosis": ["diagnosis1"],
    "medicines": [{
      "name": "string",
      "dose": "string",
      "frequency": "string",
      "duration": "string",
      "with_food": true,
      "timing": ["morning", "afternoon", "night"],
      "special_instructions": "string or null"
    }],
    "follow_up_date": "YYYY-MM-DD or null",
    "follow_up_location": "string or null",
    "danger_signs": ["string"],
    "diet_restrictions": ["string"],
    "tests_needed": ["string"],
    "activity_restrictions": ["string"]
  }

  OCR TEXT FROM HOSPITAL DOCUMENT:
  {raw_ocr_text}
  """

  def extract_medical_entities(raw_text: str) -> dict:
      prompt = EXTRACTION_PROMPT.replace("{raw_ocr_text}", raw_text)
      response = model.generate_content(prompt)
      response_text = response.text.strip()
      # Strip any markdown code blocks if Gemini adds them despite instructions
      if response_text.startswith("```"):
          response_text = response_text.split("```")[1]
          if response_text.startswith("json"):
              response_text = response_text[4:]
      return json.loads(response_text)
  ```
- [ ] Create Pydantic models in `backend/models.py` to validate the extraction output:
  ```python
  from pydantic import BaseModel
  from typing import Optional, List

  class Medicine(BaseModel):
      name: str
      dose: Optional[str] = None
      frequency: Optional[str] = None
      duration: Optional[str] = None
      with_food: Optional[bool] = None
      timing: List[str] = []
      special_instructions: Optional[str] = None

  class CarePlan(BaseModel):
      hospital_name: Optional[str] = None
      document_date: Optional[str] = None
      diagnosis: List[str] = []
      medicines: List[Medicine] = []
      follow_up_date: Optional[str] = None
      follow_up_location: Optional[str] = None
      danger_signs: List[str] = []
      diet_restrictions: List[str] = []
      tests_needed: List[str] = []
      activity_restrictions: List[str] = []
  ```
- [ ] In the `/process` endpoint, after OCR, call `extract_medical_entities(raw_text)`, then validate with Pydantic: `care_plan = CarePlan(**extracted_json)`
- [ ] Handle JSON parse failures gracefully — if Gemini returns invalid JSON, log the raw response and update Firestore with `processing_status: "failed"`, `error_reason: "extraction_failed"`
- [ ] Test with 5 real discharge papers — check that all medicine names, dosages, and timing are correctly extracted

**End Goal:** The pipeline extracts a valid, Pydantic-validated JSON object from any real discharge paper in under 4 seconds.

---

### Sub-Phase 3.3 — Gemini Call 2: Hindi Care Plan Generation

**What:** Pass the extracted JSON through Gemini again to rewrite all text fields in simple Hindi.

**How:**
- [ ] Add `translate_to_hindi()` function in `gemini_service.py`:
  ```python
  HINDI_PROMPT = """
  SYSTEM:
  You are a health educator helping low-income families in India.
  Convert the medical JSON below into simple Hindi explanations.

  RULES:
  - Use Class 5 reading level. Short sentences. No medical jargon.
  - For each medicine: explain kab lena hai, kitna lena hai, khane se pehle ya baad.
  - For danger signs: always prefix with "Yeh dikhne par TURANT doctor ke paas jaayein:"
  - For diagnosis: explain what the condition means in simple terms.
  - Keep the EXACT same JSON structure — just replace all string values with Hindi text.
  - Do not add any fields. Do not remove any fields.
  - Return ONLY the JSON object. No markdown, no explanation.

  EXTRACTED MEDICAL JSON:
  {extracted_json}
  """

  def translate_to_hindi(extracted_json: dict) -> dict:
      prompt = HINDI_PROMPT.replace("{extracted_json}", json.dumps(extracted_json, ensure_ascii=False))
      response = model.generate_content(prompt)
      response_text = response.text.strip()
      if response_text.startswith("```"):
          response_text = response_text.split("```")[1][4:] if response_text[3:7] == "json" else response_text.split("```")[1]
      return json.loads(response_text)
  ```
- [ ] In the `/process` endpoint, after extraction: `hindi_care_plan = translate_to_hindi(care_plan.model_dump())`
- [ ] Validate the Hindi output with the same Pydantic model
- [ ] Write the Hindi care plan to Firestore at `care_plans/{uid}/{docId}`:
  ```python
  db.collection('care_plans').document(req.uid).collection('plans').document(req.docId).set({
      **hindi_care_plan.model_dump(),
      "created_at": firestore.SERVER_TIMESTAMP,
      "uid": req.uid,
      "doc_id": req.docId,
  })
  ```
- [ ] Update `documents/{uid}/{docId}` to `processing_status: "done"`:
  ```python
  doc_ref.update({
      "processing_status": "done",
      "care_plan_id": req.docId,
      "processing_time_seconds": elapsed_time,
  })
  ```
- [ ] Log total pipeline latency to Cloud Monitoring:
  ```python
  logger.log_struct({"event": "pipeline_complete", "doc_id": req.docId, "latency_seconds": elapsed_time})
  ```
- [ ] Test full end-to-end with 10 real discharge papers — verify all medicine names are in Hindi, danger signs are correctly prefixed, and the structure matches the Pydantic model

**End Goal:** Scanning a real discharge paper from GSVM or LLR Hospital in Kanpur produces a complete Hindi care plan in Firestore within 15 seconds. Flutter's real-time listener fires and the user navigates to the care plan screen automatically.

---

### Phase 3 End Goal
The complete AI pipeline is working. Upload a discharge paper → Document AI extracts text → confidence check passes → Gemini extracts structured JSON → Gemini rewrites in Hindi → Firestore contains a complete Hindi care plan. Flutter's status screen detects the update and automatically navigates the user to the care plan. Pipeline latency is logged to Cloud Monitoring.

---

## Phase 4: Care Plan UI & Medication Reminders
**Goal:** The Hindi care plan displays with a beautiful, accessible UI. Medication reminders are auto-generated and fire as FCM notifications on schedule.
**Estimated Time:** 4–5 days
**Builds on:** Phase 3

### What We're Building
The care plan screen with morning/afternoon/night tabs, medicine cards with visual icons, a red danger signs card with emergency contact button, a follow-up countdown, a TTS read-aloud button, and PDF export. The reminders pipeline: Cloud Scheduler jobs created per medicine per timing slot, FCM notifications in Hindi, and an adherence log.

---

### Sub-Phase 4.1 — Care Plan Screen UI

**What:** The main care plan view that reads from Firestore and renders in Hindi with accessibility features.

**How:**
- [ ] Create `lib/screens/care_plan/care_plan_screen.dart` — reads from `care_plans/{uid}/{docId}` in Firestore
- [ ] Top of screen: hospital name + document date in Hindi format using `intl` package (`DateFormat.yMMMMd('hi')`)
- [ ] Danger Signs card — always shown first, red background (`Color(0xFFB71C1C)`):
  ```dart
  Card(
    color: Colors.red[900],
    child: Column(
      children: [
        Icon(Icons.warning, color: Colors.white),
        Text('खतरे के लक्षण', style: TextStyle(color: Colors.white, fontSize: 18)),
        ...dangerSigns.map((sign) => Text('• $sign', style: TextStyle(color: Colors.white))),
        ElevatedButton.icon(
          onPressed: () => launchUrl(Uri.parse('tel:$emergencyContact')),
          icon: Icon(Icons.phone),
          label: Text('Emergency Contact'),
        ),
      ],
    ),
  )
  ```
- [ ] Tab bar: सुबह (Morning) / दोपहर (Afternoon) / रात (Night) — each tab filters medicines by `timing` array
- [ ] Create `lib/widgets/medicine_card.dart`:
  - Medicine type icon: pill → `Icons.medication`, liquid → custom SVG, injection → `Icons.vaccines`
  - Hindi name (large text, bold), dose, with-food indicator (🍽️ / ⚡ empty stomach), duration
  - Minimum touch target 48×48dp on all interactive elements
  - Read-aloud 🔊 icon button per card
- [ ] Follow-up date section:
  ```dart
  final daysUntil = followUpDate.difference(DateTime.now()).inDays;
  Text('अगली appointment: $formattedDate'),
  Text('$daysUntil दिन बाकी — $followUpLocation'),
  ```
- [ ] Diet restrictions and tests needed — bulleted list in Hindi
- [ ] Bottom action bar: "💬 सवाल पूछें" (navigates to Chat) and "📤 Share" (triggers PDF export)
- [ ] TTS 🔊 button in the AppBar reads the full care plan via the `/tts` Cloud Run endpoint
- [ ] Test offline mode: disable WiFi, navigate to the care plan — it must load from Firestore local cache

**End Goal:** The care plan screen renders the full Hindi care plan with a red danger signs card, tabbed medicine timeline with icons, follow-up countdown, and works offline after first load.

---

### Sub-Phase 4.2 — TTS Read-Aloud & PDF Export

**What:** Read-aloud button calls Cloud Run TTS endpoint and plays Hindi audio. Share button exports care plan as PDF.

**How:**
- [ ] Add `/tts` endpoint to Cloud Run:
  ```python
  from google.cloud import texttospeech
  from fastapi.responses import Response

  @app.post("/tts")
  async def synthesize_speech(text: str):
      client = texttospeech.TextToSpeechClient()
      synthesis_input = texttospeech.SynthesisInput(text=text)
      voice = texttospeech.VoiceSelectionParams(
          language_code="hi-IN",
          name="hi-IN-Wavenet-A",
          ssml_gender=texttospeech.SsmlVoiceGender.FEMALE
      )
      audio_config = texttospeech.AudioConfig(
          audio_encoding=texttospeech.AudioEncoding.MP3
      )
      response = client.synthesize_speech(input=synthesis_input, voice=voice, audio_config=audio_config)
      return Response(content=response.audio_content, media_type="audio/mpeg")
  ```
- [ ] In Flutter, call `/tts` with the section text and play MP3 using `just_audio` package
- [ ] Add `just_audio: ^0.9.0` to `pubspec.yaml`
- [ ] Create PDF export using the `pdf` package — generates a formatted Hindi care plan with medicine table, danger signs, and follow-up date
- [ ] Use `share_plus` to share the PDF file to WhatsApp or save to gallery

**End Goal:** Tap 🔊 → Hindi audio plays within 2 seconds. Tap Share → PDF is generated and shareable via WhatsApp.

---

### Sub-Phase 4.3 — Medication Reminders Pipeline

**What:** Auto-generate Cloud Scheduler jobs from the care plan medicines. FCM sends Hindi notifications at scheduled times.

**How:**
- [ ] Add Cloud Scheduler reminder generation to the `/process` endpoint (called after Firestore write):
  ```python
  from google.cloud import scheduler_v1

  TIMING_MAP = {"morning": "8", "afternoon": "13", "night": "21"}

  def schedule_reminders(care_plan: dict, uid: str, doc_id: str, fcm_token: str):
      client = scheduler_v1.CloudSchedulerClient()
      parent = f"projects/{PROJECT_ID}/locations/asia-south1"

      for i, medicine in enumerate(care_plan['medicines']):
          for timing in medicine['timing']:
              hour = TIMING_MAP.get(timing, "8")
              job_id = f"reminder-{uid[:8]}-{doc_id[:8]}-{i}-{timing}"
              job = {
                  "name": f"{parent}/jobs/{job_id}",
                  "schedule": f"0 {hour} * * *",
                  "time_zone": "Asia/Kolkata",
                  "http_target": {
                      "uri": f"{CLOUD_RUN_URL}/send-reminder",
                      "http_method": scheduler_v1.HttpMethod.POST,
                      "body": json.dumps({
                          "fcm_token": fcm_token,
                          "medicine_name": medicine.get('name', ''),
                          "instruction": medicine.get('special_instructions', ''),
                          "timing": timing
                      }).encode()
                  }
              }
              try:
                  client.create_job(parent=parent, job=scheduler_v1.Job(**job))
              except Exception:
                  client.update_job(job=scheduler_v1.Job(**job))
  ```
- [ ] Add `/send-reminder` endpoint to Cloud Run — sends FCM notification via Firebase Admin SDK:
  ```python
  from firebase_admin import messaging

  @app.post("/send-reminder")
  async def send_reminder(data: ReminderRequest):
      TIMING_HINDI = {"morning": "सुबह", "afternoon": "दोपहर", "night": "रात"}
      timing_hindi = TIMING_HINDI.get(data.timing, "")

      message = messaging.Message(
          notification=messaging.Notification(
              title="दवाई का समय ⏰",
              body=f"{timing_hindi}: {data.medicine_name} — {data.instruction}"
          ),
          android=messaging.AndroidConfig(
              priority="high",
              notification=messaging.AndroidNotification(channel_id="medication_reminders")
          ),
          token=data.fcm_token
      )
      messaging.send(message)
      return {"status": "sent"}
  ```
- [ ] In Flutter, create the Android notification channel on app launch:
  ```dart
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'medication_reminders',
    'Medication Reminders',
    importance: Importance.max,
  );
  await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);
  ```
- [ ] Retrieve and store the FCM token to Firestore `users/{uid}` on app launch:
  ```dart
  final token = await FirebaseMessaging.instance.getToken();
  await FirebaseFirestore.instance.collection('users').doc(uid).update({'fcm_token': token});
  ```
- [ ] Create `lib/screens/reminders/reminders_screen.dart` — lists all reminders from Firestore `reminders/{uid}` with per-medicine toggles and time customisation
- [ ] Add "Li li ✓" and "Miss ho gayi ✗" buttons on notification tap → writes to Firestore `adherence_log/{uid}/{date}` → calculate and show adherence streak on Home screen

**End Goal:** After care plan is generated, a Cloud Scheduler job is created for each medicine slot. At 8am the next day, a Hindi FCM notification fires: "सुबह: Metformin 500mg — खाना खाने के बाद". Tapping it logs adherence to Firestore.

---

### Phase 4 End Goal
The care plan screen renders fully in Hindi with a red danger signs card, tabbed medicine timeline with icons, TTS read-aloud on every section, offline support, and PDF export. Medication reminders are auto-scheduled and fire as Hindi FCM notifications. Users can log adherence with a tap.

---

## Phase 5: AI Chat with Voice Input
**Goal:** Users can ask questions in Hindi (typed or spoken) and receive care-plan-anchored answers from Gemini in under 5 seconds.
**Estimated Time:** 2–3 days
**Builds on:** Phase 3 (Gemini integration), Phase 4 (care plan in Firestore)

### What We're Building
A WhatsApp-style chat interface where every message is grounded in the user's specific care plan. Voice input via Google STT lets users who can't type still ask questions. Streaming responses via SSE make the AI feel fast and responsive.

---

### Sub-Phase 5.1 — Chat Backend Endpoint

**What:** `/chat` endpoint on Cloud Run that takes a user message + care plan context and returns a Gemini response.

**How:**
- [ ] Add `/chat` endpoint to `backend/main.py`:
  ```python
  class ChatRequest(BaseModel):
      care_plan_id: str
      uid: str
      user_message: str
      chat_history: list = []

  @app.post("/chat")
  async def chat(req: ChatRequest):
      # Fetch care plan from Firestore
      db = firestore.client()
      care_plan_doc = db.collection('care_plans').document(req.uid).collection('plans').document(req.care_plan_id).get()
      care_plan = care_plan_doc.to_dict()

      prompt = f"""
      You are SwasthyaSathi, a health assistant for Indian families.
      STRICT RULES:
      1. Only answer questions directly answered by the care plan below.
      2. If not covered: "Yeh jaankari is care plan mein nahi hai. Apne doctor se zaroor poochein."
      3. Never suggest medicines not listed in the care plan.
      4. Answer in simple Hindi. Short sentences. Max 3-4 sentences.

      PATIENT CARE PLAN:
      {json.dumps(care_plan, ensure_ascii=False)}

      PREVIOUS CONVERSATION:
      {json.dumps(req.chat_history[-5:], ensure_ascii=False)}

      USER MESSAGE: {req.user_message}
      """

      response = model.generate_content(prompt)
      return {"response": response.text}
  ```
- [ ] Save chat messages to Firestore `chat_history/{uid}/{care_plan_id}/messages` as a subcollection
- [ ] Implement SSE streaming (optional for MVP, implement if time allows) — use `fastapi.responses.StreamingResponse`

**End Goal:** POST to `/chat` with a Hindi question returns a Hindi answer grounded in the care plan within 3 seconds.

---

### Sub-Phase 5.2 — Chat UI & Voice Input

**What:** WhatsApp-style chat screen with quick-reply chips, voice input button, and streaming response display.

**How:**
- [ ] Create `lib/screens/chat/chat_screen.dart` — bubbles layout:
  - User messages: right-aligned, green/blue bubble
  - AI messages: left-aligned, grey bubble
  - Typing indicator: three animated dots while awaiting response
- [ ] Add quick-reply chips at the top of the screen:
  ```dart
  Wrap(
    children: [
      'Dawai miss ho gayi?',
      'Kya kha sakte hain?',
      'Dawai band kab hogi?',
      'Yeh test kahan se karwayein?',
    ].map((q) => ActionChip(label: Text(q), onPressed: () => sendMessage(q))).toList(),
  )
  ```
- [ ] Add voice input using `speech_to_text` package:
  ```dart
  final SpeechToText _speech = SpeechToText();
  await _speech.initialize();
  await _speech.listen(
    onResult: (result) => setState(() => _inputController.text = result.recognizedWords),
    localeId: 'hi_IN',
  );
  ```
- [ ] Add microphone 🎤 icon button in the input bar — tap to start, tap again to stop and auto-send
- [ ] Call `/chat` endpoint on message send, display response in a new AI bubble
- [ ] If response contains "is care plan mein nahi hai", style the bubble differently (grey text, italic) to signal out-of-scope
- [ ] Load chat history from Firestore on screen open (last 20 messages, paginated)
- [ ] Log `chat_message_sent` event to Firebase Analytics

**End Goal:** User taps the mic, speaks "Dawai doodh ke saath le sakte hain?", app transcribes it, sends to Gemini, and displays a Hindi answer grounded in the care plan within 5 seconds — all without typing.

---

### Phase 5 End Goal
The chat screen is fully functional. Users can ask care-plan-anchored questions in Hindi by voice or text and receive accurate, brief Hindi answers. Quick-reply chips reduce the typing burden for low-literacy users. All conversations are saved to Firestore and load on next open.

---

## Phase 6: Scheme Eligibility Guide & Maps
**Goal:** Users can check which government health schemes they qualify for and see the nearest empanelled hospital on a map.
**Estimated Time:** 2–3 days
**Builds on:** Phase 3 (Gemini), Phase 1 (Firebase)

### What We're Building
A 3-question eligibility form (state, income bracket, documents available), Gemini-powered scheme reasoning, a results screen showing eligible schemes with step-by-step Hindi guides, and Google Maps integration showing the nearest hospital/PHC/CSC.

---

### Sub-Phase 6.1 — Scheme Data & Backend

**What:** Scheme rules stored in Firestore, `/scheme` endpoint calls Gemini to determine eligibility, returns results in Hindi.

**How:**
- [ ] Populate Firestore `scheme_rules` collection with data for:
  - Ayushman Bharat PM-JAY (income < ₹10K/month, all states)
  - UP Mukhyamantri Jan Arogya Yojana (UP, income < ₹15K/month)
  - Jan Aushadhi (available to all)
- [ ] Add `/scheme` endpoint to Cloud Run:
  ```python
  @app.post("/scheme")
  async def check_scheme(state: str, income_bracket: str, documents: list):
      prompt = f"""
      Based on these details, identify which Indian health schemes the user is eligible for.
      Return ONLY a JSON array. No markdown.

      State: {state}
      Monthly income: {income_bracket}
      Documents: {documents}

      For each eligible scheme return:
      {{"scheme_name": "", "scheme_name_hindi": "", "what_you_get_hindi": "",
        "apply_at_hindi": "", "documents_needed": [], "how_to_apply_steps": []}}
      """
      response = model.generate_content(prompt)
      return json.loads(response.text)
  ```
- [ ] Handle Gemini JSON parse errors — return empty array with error flag

**End Goal:** POST to `/scheme` with UP + ₹8,000/month income returns Ayushman Bharat + UP MJAY eligibility with Hindi step-by-step guides.

---

### Sub-Phase 6.2 — Scheme UI & Google Maps

**What:** 3-question form UI, results screen with eligible schemes, Maps showing nearest facility.

**How:**
- [ ] Create `lib/screens/scheme/scheme_screen.dart` with form:
  - State dropdown (all Indian states in Hindi)
  - Monthly income bracket dropdown: "10,000 से कम", "10,000–15,000", "15,000 से ज़्यादा"
  - Documents available: checkboxes for Aadhaar, Ration Card, BPL Card
  - "जाँच करें" button → calls `/scheme` endpoint
- [ ] Results screen: eligible schemes in green cards with ✅, ineligible in grey:
  ```dart
  ExpansionTile(
    leading: Icon(Icons.check_circle, color: Colors.green),
    title: Text(scheme['scheme_name_hindi']),
    children: [
      Text(scheme['what_you_get_hindi']),
      ...scheme['how_to_apply_steps'].map((step) => ListTile(title: Text(step))),
      ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => NearbyFacilitiesScreen(schemeType: scheme['scheme_name'])
        )),
        child: Text('नज़दीकी हॉस्पिटल दिखाएं'),
      ),
    ],
  )
  ```
- [ ] Create `lib/screens/scheme/nearby_facilities_screen.dart` — integrates `google_maps_flutter`:
  ```dart
  Future<List<Place>> findNearbyHospitals(LatLng userLocation) async {
    final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${userLocation.latitude},${userLocation.longitude}'
        '&radius=5000&type=hospital&key=$MAPS_API_KEY';
    final response = await http.get(Uri.parse(url));
    return PlacesResponse.fromJson(jsonDecode(response.body)).results;
  }
  ```
- [ ] Request location permission using `geolocator` package
- [ ] Show map with markers for each nearby hospital/PHC/CSC with name, distance, and opening hours
- [ ] Add Directions API integration — tap a marker to open route in Google Maps app: `launchUrl(Uri.parse('https://maps.google.com/maps?daddr=...'))`
- [ ] Log `scheme_guide_opened` to Firebase Analytics

**End Goal:** User enters UP + ₹8,000/month income → sees "Ayushman Bharat: Aap eligible hain" with a 5-step Hindi guide → taps "नज़दीकी हॉस्पिटल दिखाएं" → Google Maps shows nearest empanelled hospital 1.2 km away.

---

### Phase 6 End Goal
The scheme guide works end-to-end. Users can determine eligibility for government schemes and get a step-by-step Hindi guide on where to go and what documents to carry. The nearby facilities map shows real hospitals within 5km with distances.

---

## Phase 7: Accessibility, Polish & Pilot Testing
**Goal:** All accessibility features implemented. App tested with 5+ real caregivers. 3+ feedback points documented with 2+ changes made. App is production-ready.
**Estimated Time:** 5–7 days (**Do not skip this phase — pilot testing is worth 10 points in the rubric**)
**Builds on:** All previous phases

### What We're Building
Font size settings, voice input on every text field, TTS on every content card, full offline mode verification, document history screen, and real-world pilot testing at GSVM / LLR Hospital in Kanpur with structured pre/post measurement.

---

### Sub-Phase 7.1 — Accessibility & Polish

**What:** Font size setting, TTS on all content cards, voice input on all text fields, document history screen.

**How:**
- [ ] Add font size setting to `lib/screens/settings/settings_screen.dart`:
  - Three options: Small / Medium / Large — stored in Firestore `users/{uid}.font_size`
  - Use `Provider` to propagate font size change across all screens immediately
  ```dart
  final fontScale = {'small': 0.85, 'medium': 1.0, 'large': 1.25};
  MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaleFactor: fontScale[userFontSize]),
    child: child,
  )
  ```
- [ ] Add TTS 🔊 button to every content card — medicine cards, danger signs, diet restrictions, follow-up section
- [ ] Add voice input microphone button to every text field (not just chat) — phone login, onboarding name field, etc.
- [ ] Create `lib/screens/history/history_screen.dart` — reverse-chronological list of all care plans, each showing hospital name and date
  - Reads from `documents/{uid}` collection, ordered by `created_at` descending
  - Tap any item → opens the care plan for that visit
  - Long-press → delete dialog → removes Firestore doc and Cloud Storage file
  - Search/filter by date range or hospital name
- [ ] Offline mode test checklist (verify each manually):
  - [ ] Disable WiFi → navigate to existing care plan → must load
  - [ ] Disable WiFi → navigate to chat → past messages must load
  - [ ] Disable WiFi → navigate to history → list must load
  - [ ] Disable WiFi → open reminders → list must load
  - [ ] Enable WiFi → new care plan scanned → syncs immediately

**End Goal:** All screens work offline. Font size Large mode renders all text 25% bigger. TTS plays on any content card. Document history shows all past visits.

---

### Sub-Phase 7.2 — Analytics & Crashlytics

**What:** All key user actions are tracked in Firebase Analytics. Crashlytics is capturing errors.

**How:**
- [ ] Add analytics events to all key interactions:
  ```dart
  // Add these calls throughout the app
  FirebaseAnalytics.instance.logEvent(name: 'care_plan_generated', parameters: {
    'hospital_name': hospitalName,
    'medicine_count': medicines.length,
  });
  FirebaseAnalytics.instance.logEvent(name: 'chat_message_sent');
  FirebaseAnalytics.instance.logEvent(name: 'tts_used', parameters: {'section': 'medicines'});
  FirebaseAnalytics.instance.logEvent(name: 'scheme_guide_opened');
  FirebaseAnalytics.instance.logEvent(name: 'reminder_acknowledged', parameters: {'action': 'taken'});
  FirebaseAnalytics.instance.logEvent(name: 'voice_input_used');
  ```
- [ ] Verify Crashlytics is receiving test crashes:
  ```dart
  // Add to a temporary debug button, remove before submission
  ElevatedButton(
    onPressed: () => FirebaseCrashlytics.instance.crash(),
    child: Text('Test Crash'),
  )
  ```
- [ ] Wait 24 hours and check Firebase Analytics dashboard — confirm events are appearing
- [ ] Enable Remote Config default values for: `gemini_model: "gemini-1.5-flash"`, `ocr_confidence_threshold: 0.70`, `scheme_module_enabled: true`

**End Goal:** Firebase Analytics shows real event counts for care plans generated, chat messages sent, and TTS usage. Crashlytics shows the test crash.

---

### Sub-Phase 7.3 — Pilot Testing

**What:** Structured user testing with real caregivers at GSVM / LLR Hospital in Kanpur.

**How:**
- [ ] Install the app on 2–3 physical Android phones (not emulators)
- [ ] Create a sample anonymised discharge paper from a real Kanpur hospital (with patient data removed) for users who prefer privacy
- [ ] Recruit 5–10 users at hospital discharge area — target profiles: caregivers, 30–60 years old, semi-literate, post-discharge with family member
- [ ] Run the pre-test protocol (in Hindi, verbally):
  - "Aapke haath mein yeh discharge paper hai. Mujhe batayein — kal subah aapko kaunsi dawai leni hai?"
  - "Aapki agli doctor appointment kab hai?"
  - Record answers verbatim — this is your baseline measurement
- [ ] Give user the phone, let them use the app freely for 20–30 minutes without guidance
  - Observe without intervening — note exactly where confusion occurs
  - Note any screens where they hesitate for more than 10 seconds
- [ ] Run post-test protocol:
  - "Ab batayein — kal subah kaunsi dawai leni hai?"
  - "Agli appointment kab hai?"
  - "Kya aapko app samajh mein aayi? Kya mushkil laga?"
  - "Koi cheez jo aap add karna chahenge?"
  - 5-point scale: "Kya aap ab apni dawai ke baare mein zyada confident feel kar rahe hain?"
- [ ] Document for each user: name, age, literacy level, relationship to patient, pre-test answers, post-test answers, 2 specific quotes
- [ ] Implement at least 2 changes based on feedback. Suggested common issues:
  - Medicine names unrecognisable → add original English name in brackets below Hindi name
  - Danger signs card not prominent enough → increase font size, make full-width
  - TTS button too small → increase to 60×60dp
  - Icons confusing → add text labels below icons
- [ ] Document each change: "User 3 said X → we changed Y"

**End Goal:** 5 real caregivers tested. Before: X% correctly recall next follow-up date. After: Y% (target: 2x improvement). 3+ verbatim feedback points documented. 2+ app changes implemented and described.

---

### Phase 7 End Goal
The app is fully accessible, analytically instrumented, and pilot-tested. You have measurable before/after data on follow-up date recall. You have 3+ named user feedback points with documented changes. The app is visually polished and passes offline mode verification.

---

## Phase 8: Demo Video, Documentation & Submission
**Goal:** Submission-ready GitHub repository, README, architecture diagram, and demo video.
**Estimated Time:** 2 days
**Builds on:** All phases

### What We're Building
A compelling under-2-minute demo video using a real discharge paper, a complete GitHub README with architecture diagram, and all submission checklist items verified.

---

### Sub-Phase 8.1 — Repository & Documentation

**What:** Public GitHub repo with complete README, architecture diagram, and sample discharge image.

**How:**
- [ ] Create `architecture.png` using draw.io or Excalidraw — show: Flutter → Firebase Storage → Cloud Function → Cloud Run → Document AI → Gemini → Firestore → Flutter, plus the Reminders pipeline and Maps pipeline as separate swim lanes
- [ ] Add `sample_discharge.jpg` to repo root — anonymised real discharge paper from a Kanpur hospital (no patient names/numbers)
- [ ] Write `README.md` covering:
  - [ ] Project name + one-line description
  - [ ] Problem statement with 3 data points (cite the CMC Punjab study, NITI Aayog, and the 700K deaths figure)
  - [ ] SDG 3 (Target 3.8) and SDG 10 (Target 10.2) mapping with specific target numbers and explanation
  - [ ] Architecture diagram image embedded: `![Architecture](architecture.png)`
  - [ ] Complete tech stack list with one-line justification per Google product
  - [ ] Flutter setup instructions: `flutter pub get`, how to add `google-services.json`
  - [ ] Backend setup instructions: `gcloud run deploy` command
  - [ ] Firebase setup: which services to enable, how to get the processor ID
  - [ ] Team members
  - [ ] Link to demo video (YouTube unlisted)
- [ ] Verify `.gitignore` — confirm no `google-services.json`, `.env`, or real API keys in history
- [ ] Create `.env.example` with placeholder values: `GEMINI_API_KEY=your_key_here`
- [ ] Tag the final commit: `git tag v1.0.0 && git push origin v1.0.0`

**End Goal:** A developer who has never seen the project can follow the README and get the app running in under 30 minutes.

---

### Sub-Phase 8.2 — Demo Video

**What:** Under 2-minute YouTube demo video showing the complete user journey with a real discharge paper.

**How:**
- [ ] Use a real discharge paper from GSVM or LLR Hospital (anonymised if needed)
- [ ] Record on a physical Android phone, not an emulator — screen record via scrcpy or Vysor
- [ ] Follow this script exactly:

| Time | Scene |
|------|-------|
| 0:00–0:10 | Title card + voice-over: "27% of Indian caregivers cannot understand discharge instructions. SwasthyaSathi changes that." |
| 0:10–0:30 | Live scan of real discharge paper → show "Processing..." spinner → Hindi care plan appears |
| 0:30–0:45 | Ask chat question in Hindi voice: "Dawai doodh ke saath le sakte hain?" → show transcription → Hindi answer appears |
| 0:45–0:55 | Show Hindi FCM reminder notification firing on the phone |
| 0:55–1:05 | Open scheme guide → enter UP + low income → show PM-JAY eligibility → show map |
| 1:05–1:20 | Show real caregiver testimonial (from pilot testing) in Hindi |
| 1:20–1:30 | Show Firebase Analytics: "X care plans generated, Y% users checked follow-up date" |
| 1:30–2:00 | Architecture diagram with voice-over: "Cloud Run + Firestore scales to 100,000 users without re-architecting" |

- [ ] Upload to YouTube as unlisted
- [ ] Do NOT add unnecessary captions or subtitles that cover the UI — the Hindi is the feature

**End Goal:** A sub-2-minute, fast-paced demo video that a judge can watch and understand the complete value proposition without reading anything else.

---

### Phase 8 End Goal
Public GitHub repo with complete README, architecture diagram, sample discharge paper, CI/CD config, and clean git history. YouTube demo video under 2 minutes showing a real discharge paper being scanned. All submission checklist items verified.

---

## 5. Testing Strategy

### Phase 3 — AI Pipeline Testing (Most Critical)
- Test Document AI with 10+ real anonymised discharge papers covering: printed English, printed Hindi, handwritten annotations, rubber stamps, multi-column layouts, faded paper, blurry photos
- Verify confidence threshold correctly rejects blurry images (test at exactly 0.65, 0.70, 0.75 confidence)
- Test Gemini extraction against ground truth: manually extract medicines from 5 papers, compare JSON output — target < 5% error rate on medicine names
- Test Gemini Hindi output: verify all danger signs start with "Yeh dikhne par TURANT doctor ke paas jaayein:", verify no English medical jargon in output
- **Passing**: 10/10 papers produce valid Pydantic-validated JSON, < 3% medicine name errors, latency < 15 seconds

### Phase 4 — Reminders Testing
- Create a care plan with morning/afternoon/night medicines → verify 3 Cloud Scheduler jobs are created
- Adjust phone clock to the reminder time → verify FCM notification fires with correct Hindi text
- Toggle a reminder off → verify Cloud Scheduler job is deleted or paused
- **Passing**: All 3 timing slots fire correctly on all Android API levels 21–34

### Phase 5 — Chat Testing
- Test 20 question types: in-scope questions (correctly answered), out-of-scope questions (correct refusal), emergency symptom questions (emergency response), questions in Hinglish
- Voice input: test with 5 different speakers, test in noisy environment (hospital background noise), test with elderly speaker (slower speech)
- **Passing**: In-scope accuracy > 90%, out-of-scope refusal rate 100%, STT accuracy > 85% for Hindi in quiet environment

### Phase 7 — End-to-End Testing
- Full flow test: install fresh app → log in → scan discharge paper → view care plan → ask chat question → check reminders → check scheme guide → go offline → verify all previously loaded content works
- Performance: pipeline latency < 15 seconds on 4G connection (test on real Airtel/Jio SIM in Kanpur)
- Crash testing: submit image with no text, submit PDF with 50 pages, disconnect internet mid-upload, submit image with non-medical content
- **Passing**: Full flow completes without crashes on Android 8–14, pipeline latency < 15s on 4G

### Tools
- Widget tests: `flutter test` for UI logic
- Integration tests: `flutter drive` for end-to-end flows on device
- Backend: `pytest` for Cloud Run endpoints
- Load testing: not required for MVP, mention in submission that Cloud Run auto-scales

---

## 6. Deployment & Launch Plan

### Staging vs Production
Use a single Firebase project for the Solution Challenge (time constraints). When you push to `main`, it deploys the production backend. Protect `main` with GitHub branch protection — require a PR review before merging.

### Environment Variables (Cloud Run)
Set all secrets via Secret Manager and inject into Cloud Run:
```bash
gcloud run services update swasthyasathi-api \
  --update-secrets=GEMINI_API_KEY=gemini-api-key:latest \
  --update-secrets=DOCUMENT_AI_PROCESSOR_ID=docai-processor-id:latest \
  --update-env-vars=GOOGLE_CLOUD_PROJECT=swasthyasathi \
  --update-env-vars=OCR_CONFIDENCE_THRESHOLD=0.70 \
  --update-env-vars=CLOUD_RUN_URL=https://your-cloud-run-url \
  --region=asia-south1
```

### Pre-Submission Checklist
- [ ] All API keys are in Secret Manager — none hardcoded anywhere in the codebase
- [ ] Cloud Run health endpoint returns 200: `curl https://your-url/health`
- [ ] Firebase Security Rules deny unauthenticated access (test with `curl` without auth token)
- [ ] Android APK builds without warnings: `flutter build apk --release`
- [ ] App installs and runs on a physical Android device (not just emulator)
- [ ] Sample discharge paper scan produces a complete Hindi care plan in < 15 seconds on real 4G
- [ ] FCM notification fires on a real device (not emulator — FCM is unreliable on emulators)
- [ ] GitHub repo is public and the README link to the demo video works
- [ ] Architecture diagram is visible in the README when viewed on GitHub
- [ ] `.env` and `google-services.json` are NOT in the git history: `git log --all --full-history -- "*.json" | grep google-services` must return nothing
- [ ] Cloud Monitoring shows > 0 successful pipeline runs

### Monitoring Setup
- Cloud Monitoring dashboard — create charts for:
  - OCR confidence score histogram
  - Pipeline latency (target: < 15s p95)
  - Gemini call latency
  - Error rate (failed pipeline runs / total)
- Set up alerting: alert if error rate > 10% in any 5-minute window
- Export a screenshot of the monitoring dashboard for the submission — it demonstrates production readiness

---

## 7. Future Improvements (Post-Submission)

- **WhatsApp bot version**: Use WhatsApp Business API to serve the care plan via chat for users without smartphones
- **ASHA worker integration**: Give ASHA workers a simplified dashboard to see care plans of their village patients
- **Regional language expansion**: Bhojpuri (dominant in rural UP), Maithili, Marathi, Tamil
- **Multi-patient support**: One caregiver phone, multiple patient profiles (common — one caregiver manages multiple family members)
- **Teleconsult integration**: "Apne doctor se baatein karein" — direct call booking with Practo/1mg API
- **Ayushman Bharat API integration**: Real-time eligibility check via the NHA API instead of Gemini reasoning
- **Follow-up reminder**: Separate reminder for the follow-up appointment date, not just medicines
- **Community ASHA network**: Partner with district health offices to deploy to all ASHA workers in UP — immediately reaches 100K+ users
- **Low-RAM mode**: Reduce image quality and pipeline timeout for phones with < 2GB RAM (common in tier-3 cities)
- **Gemini model upgrade path**: Remote Config already controls the model string — switch to Gemini 2.0 Flash when it's stable without an app update

---

*Implementation plan generated for SwasthyaSathi | Google Solution Challenge 2025*
*Total estimated timeline: 4 weeks for a team of 2–3 developers*
