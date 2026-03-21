// ════════════════════════════════════════════════════════════════════════════
// firebase_service.dart  — Centralised Firebase RTDB read / write layer
// All providers call through here — screens never touch FirebaseDatabase directly.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_config.dart';
import '../../features/company_login_screen.dart';

// ── Deep-cast helper ──────────────────────────────────────────────────────────
// Flutter Web Firebase returns LinkedMap<Object?, Object?> instead of
// Map<String, dynamic>. A shallow Map<String, dynamic>.from() only converts
// the top level — nested maps and lists remain as LinkedMap<Object?, Object?>
// and cause TypeErrors in every fromJson method that reads nested fields
// (e.g. editHistory entries inside a JarTransaction → transaction disappears).
// _deepCast() recursively converts the entire tree to properly typed Dart objects.
Map<String, dynamic> _deepCast(dynamic value) {
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), _deepCastValue(v)));
  }
  return {};
}

dynamic _deepCastValue(dynamic v) {
  if (v is Map)  return _deepCast(v);
  if (v is List) return v.map(_deepCastValue).toList();
  return v;
}

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  // Lazily-initialised database reference using the URL from FirebaseConfig
  late final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    databaseURL: FirebaseConfig.databaseUrl,
  );

  String get _companyId => CompanySession.companyId;

  DatabaseReference _ref(String node) {
    if (_companyId.isEmpty) {
      throw StateError('FirebaseService: Attempted access before CompanySession.init()');
    }
    return _db.ref('companies/$_companyId/$node');
  }

  // ── Generic helpers ───────────────────────────────────────────────────────

  /// Read a node once and return its value as a Map, or null if missing.
  Future<Map<String, dynamic>?> readOnce(String node) async {
    final snap = await _ref(node).get();
    if (!snap.exists || snap.value == null) return null;
    // _deepCast handles Flutter Web LinkedMap<Object?, Object?> recursively.
    return _deepCast(snap.value);
  }

  /// Stream every change to a node as a Map.
  Stream<Map<String, dynamic>?> watch(String node) =>
      _ref(node).onValue.map((event) {
        if (!event.snapshot.exists || event.snapshot.value == null) return null;
        // _deepCast handles Flutter Web LinkedMap<Object?, Object?> recursively.
        return _deepCast(event.snapshot.value);
      });

  /// Write (set) a whole node.
  Future<void> write(String node, Map<String, dynamic> data) =>
      _ref(node).set(data);

  /// Merge-update fields inside a node (PATCH semantics).
  Future<void> update(String node, Map<String, dynamic> data) =>
      _ref(node).update(data);

  /// Write a single child key inside a node.
  Future<void> setChild(String node, String childId, Map<String, dynamic> data) =>
      _ref(node).child(childId).set(data);

  /// Remove a single child.
  Future<void> removeChild(String node, String childId) =>
      _ref(node).child(childId).remove();

  // ── Settings ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> readSettings() =>
      readOnce(FirebaseConfig.nodeSettings);

  Future<void> writeSettings(Map<String, dynamic> data) =>
      write(FirebaseConfig.nodeSettings, data);

  // ── Inventory ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> readInventory() =>
      readOnce(FirebaseConfig.nodeInventory);

  Future<void> writeInventory(Map<String, dynamic> data) =>
      write(FirebaseConfig.nodeInventory, data);

  Stream<Map<String, dynamic>?> watchInventory() =>
      watch(FirebaseConfig.nodeInventory);

  // ── Customers ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> readCustomers() =>
      readOnce(FirebaseConfig.nodeCustomers);

  Future<void> setCustomer(String id, Map<String, dynamic> data) =>
      setChild(FirebaseConfig.nodeCustomers, id, data);

  Stream<Map<String, dynamic>?> watchCustomers() =>
      watch(FirebaseConfig.nodeCustomers);

  // ── Transactions ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> readTransactions() =>
      readOnce(FirebaseConfig.nodeTransactions);

  Future<void> setTransaction(String id, Map<String, dynamic> data) =>
      setChild(FirebaseConfig.nodeTransactions, id, data);

  Future<void> removeTransaction(String id) =>
      removeChild(FirebaseConfig.nodeTransactions, id);

  Stream<Map<String, dynamic>?> watchTransactions() =>
      watch(FirebaseConfig.nodeTransactions);

  // ── Staff ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> readStaff() =>
      readOnce(FirebaseConfig.nodeStaff);

  Future<void> setStaff(String id, Map<String, dynamic> data) =>
      setChild(FirebaseConfig.nodeStaff, id, data);

  Future<void> removeStaff(String id) =>
      removeChild(FirebaseConfig.nodeStaff, id);

  // ── Expenses ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> readExpenses() =>
      readOnce(FirebaseConfig.nodeExpenses);

  Future<void> setExpense(String id, Map<String, dynamic> data) =>
      setChild(FirebaseConfig.nodeExpenses, id, data);

  Future<void> removeExpense(String id) =>
      removeChild(FirebaseConfig.nodeExpenses, id);

  // ── Audit ─────────────────────────────────────────────────────────────────
  Future<void> appendAudit(String id, Map<String, dynamic> data) =>
      setChild(FirebaseConfig.nodeAuditLog, id, data);

  // ── Diagnostics ──────────────────────────────────────────────────────────
  // Used only by DiagnosticsScreen — returns a DiagResult per node/field.

  /// Attempt a test read on a path; returns latency in ms or an error string.
  Future<DiagResult> testRead(String path) async {
    final sw = Stopwatch()..start();
    try {
      await _db.ref(path).get();
      sw.stop();
      return DiagResult.ok(path, sw.elapsedMilliseconds);
    } catch (e) {
      sw.stop();
      return DiagResult.error(path, e.toString());
    }
  }

  /// Attempt a test write then immediately delete on a scratch path.
  Future<DiagResult> testWrite(String path) async {
    final testPath = '$path/__diag_test__';
    final sw = Stopwatch()..start();
    try {
      await _db.ref(testPath).set({'ts': DateTime.now().toIso8601String()});
      await _db.ref(testPath).remove();
      sw.stop();
      return DiagResult.ok(path, sw.elapsedMilliseconds);
    } catch (e) {
      sw.stop();
      return DiagResult.error(path, e.toString());
    }
  }
}

// ── Diagnostic result model ───────────────────────────────────────────────────
class DiagResult {
  final String path;
  final bool success;
  final int? latencyMs;
  final String? error;

  const DiagResult._({
    required this.path,
    required this.success,
    this.latencyMs,
    this.error,
  });

  factory DiagResult.ok(String path, int latencyMs) =>
      DiagResult._(path: path, success: true, latencyMs: latencyMs);

  factory DiagResult.error(String path, String error) =>
      DiagResult._(path: path, success: false, error: error);
}
