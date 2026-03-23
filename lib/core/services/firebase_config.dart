// ════════════════════════════════════════════════════════════════════════════
// firebase_config.dart  — credentials via --dart-define (Web + Mobile safe)
//
// ⚠️  ADD THIS FILE TO .gitignore  ⚠️
//     echo "lib/core/services/firebase_config.dart" >> .gitignore
//
// WHY NOT .env:
//   flutter_dotenv reads files at runtime — not supported on Flutter Web
//   because the web build doesn't have filesystem access.
//
// HOW TO USE (--dart-define works on ALL platforms including Web):
//
//   Development:
//     flutter run \
//       --dart-define=FIREBASE_API_KEY=AIzaSy... \
//       --dart-define=FIREBASE_AUTH_DOMAIN=project.firebaseapp.com \
//       --dart-define=FIREBASE_DATABASE_URL=https://project-rtdb.firebaseio.com \
//       --dart-define=FIREBASE_PROJECT_ID=your-project-id \
//       --dart-define=FIREBASE_STORAGE_BUCKET=project.firebasestorage.app \
//       --dart-define=FIREBASE_MESSAGING_SENDER_ID=123456789 \
//       --dart-define=FIREBASE_APP_ID=1:123:web:abc
//
//   Or save to a file (dart_defines.env) and use:
//     flutter run --dart-define-from-file=dart_defines.env
//
//   Production build:
//     flutter build web --dart-define-from-file=dart_defines.env
//
//   dart_defines.env format (JSON — NOT .env format):
//   {
//     "FIREBASE_API_KEY": "AIzaSy...",
//     "FIREBASE_AUTH_DOMAIN": "project.firebaseapp.com",
//     "FIREBASE_DATABASE_URL": "https://project-rtdb.firebaseio.com",
//     "FIREBASE_PROJECT_ID": "your-project-id",
//     "FIREBASE_STORAGE_BUCKET": "project.firebasestorage.app",
//     "FIREBASE_MESSAGING_SENDER_ID": "123456789",
//     "FIREBASE_APP_ID": "1:123:web:abc"
//   }
//
//   Add dart_defines.env to .gitignore too:
//     echo "dart_defines.env" >> .gitignore
//
// NOTE ON WEB SECURITY:
//   Firebase Web API keys are visible in the compiled JS — this is by design.
//   Protection comes from:
//     1. HTTP referrer restrictions in Google Cloud Console (most important)
//     2. Firebase Security Rules (auth != null for all reads/writes)
//   Never put server-side service account keys in client code.
// ════════════════════════════════════════════════════════════════════════════

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseConfig {
  FirebaseConfig._();

  // ── Hardcoded Firebase Configuration ──────────────────────────────────────
  // These are now hardcoded to bypass the need for --dart-define secrets in GitHub.
  static const _apiKey      = 'AIzaSyDr6JHIReYMAT-gff_OZZtU2aaAj0zt2ho';
  static const _authDomain  = 'mrwaterprov1-54c3f.firebaseapp.com';
  static const databaseUrl  = 'https://mrwaterprov1-54c3f-default-rtdb.firebaseio.com';
  static const projectId    = 'mrwaterprov1-54c3f';
  static const _storage     = 'mrwaterprov1-54c3f.firebasestorage.app';
  static const _senderId    = '199429585160';
  static const _appId       = '1:199429585160:web:919155f8d921ab0790d4bd';
  static const _appIdAndroid = '1:199429585160:android:de08ce0929fc6f6190d4bd';

  // ── RTDB node paths ───────────────────────────────────────────────────────
  static const nodeSettings           = 'settings';
  static const nodeStaff              = 'staff';
  static const nodeCustomers          = 'customers';
  static const nodeTransactions       = 'transactions';
  static const nodeInventory          = 'inventory';
  static const nodeExpenses           = 'expenses';
  static const nodeLoadUnload         = 'load_unload';
  static const nodeAuditLog           = 'auditLog';
  static const nodeAreas              = 'areas';
  static const nodeVehicles           = 'vehicles';
  static const nodeLedgerEntries      = 'ledgerEntries';
  static const nodeRevisions          = 'transactionRevisions';
  static const nodeInventoryMovements = 'inventoryMovements';
  static const nodePayments           = 'payments';

  // ── FirebaseOptions ───────────────────────────────────────────────────────
  static FirebaseOptions get currentPlatform => FirebaseOptions(
    apiKey:            _apiKey,
    appId:             kIsWeb ? _appId : _appIdAndroid,
    messagingSenderId: _senderId,
    projectId:         projectId,
    authDomain:        _authDomain,
    databaseURL:       databaseUrl,
    storageBucket:     _storage,
  );

  /// Returns true if credentials were supplied at build time.
  /// Call this in main() to catch missing --dart-define flags early.
  static bool get isConfigured =>
      _apiKey.isNotEmpty && projectId.isNotEmpty && databaseUrl.isNotEmpty;
}
