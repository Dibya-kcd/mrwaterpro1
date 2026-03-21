// ════════════════════════════════════════════════════════════════════════════
// firebase_config.dart  — Single source of truth for all Firebase credentials
// Never hardcode any of these values anywhere else in the project.
// ════════════════════════════════════════════════════════════════════════════

import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  FirebaseConfig._();

  // ── Project identifiers ───────────────────────────────────────────────────
  static const projectId        = 'mrwaterprov1-54c3f';
  static const projectNumber    = '199429585160';

  // ── API keys ──────────────────────────────────────────────────────────────
  /// Android API key (from google-services.json)
  static const androidApiKey    = 'AIzaSyArDnXqUojZJVBUAcnW_QWIH3h57nBE6Ic';
  /// Web / general API key (from Firebase console web config)
  static const webApiKey        = 'AIzaSyDr6JHIReYMAT-gff_OZZtU2aaAj0zt2ho';

  // ── App identifiers ───────────────────────────────────────────────────────
  static const androidAppId     = '1:199429585160:android:4583ea952e2258b590d4bd';
  static const webAppId         = '1:199429585160:web:919155f8d921ab0790d4bd';
  static const androidPackage   = 'com.example.mrwaterpro';

  // ── Service URLs ──────────────────────────────────────────────────────────
  static const databaseUrl      = 'https://mrwaterprov1-54c3f-default-rtdb.firebaseio.com';
  static const storageBucket    = 'mrwaterprov1-54c3f.firebasestorage.app';
  static const authDomain       = 'mrwaterprov1-54c3f.firebaseapp.com';
  static const messagingSenderId = projectNumber;

  // ── RTDB top-level node paths ─────────────────────────────────────────────
  // Use these constants whenever referencing RTDB paths — never use raw strings.
  static const nodeSettings     = 'settings';
  static const nodeStaff        = 'staff';
  static const nodeCustomers    = 'customers';
  static const nodeTransactions = 'transactions';
  static const nodeInventory    = 'inventory';
  static const nodeExpenses     = 'expenses';
  static const nodeLoadUnload   = 'load_unload';
  static const nodeAuditLog     = 'auditLog';
  static const nodeAreas        = 'areas';
  static const nodeVehicles          = 'vehicles';
  // ── New collections (spec-required audit trail) ─────────────────────────
  static const nodeLedgerEntries     = 'ledgerEntries';
  static const nodeRevisions         = 'transactionRevisions';
  static const nodeInventoryMovements= 'inventoryMovements';
  static const nodePayments          = 'payments';

  // ── Firebase Options (General/Web) ─────────────────────────────────────────
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: webApiKey,
      appId: webAppId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: authDomain,
      databaseURL: databaseUrl,
      storageBucket: storageBucket,
    );
  }
}
