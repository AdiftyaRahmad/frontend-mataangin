import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/pemasukan_model.dart';

class PemasukanService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PemasukanService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _ref => _firestore.collection('pemasukan');

  /// Resolve user name from Firestore users collection
  Future<String> _resolveUserName(String? uid, Map<String, String>? cache, Map<String, dynamic> docData) async {
    if (uid == null || uid.isEmpty) return 'Staf';
    if (cache != null && cache.containsKey(uid)) {
      return cache[uid]!;
    }

    final dbName = docData['created_by_name']?.toString();
    if (dbName != null && dbName.isNotEmpty) {
      if (cache != null) cache[uid] = dbName;
      return dbName;
    }

    String userName = 'Staf';
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        userName = userDoc.data()?['name'] ?? 'Staf';
      }
    } catch (_) {}

    if (cache != null) cache[uid] = userName;
    return userName;
  }

  /// GET all pemasukan records ordered by date descending
  Future<List<PemasukanModel>> getAll() async {
    final querySnap = await _ref.orderBy('tanggal', descending: true).get();
    final List<PemasukanModel> list = [];
    final Map<String, String> cache = {};

    for (final doc in querySnap.docs) {
      final data = doc.data();
      final uid = data['created_by']?.toString();
      final userName = await _resolveUserName(uid, cache, data);
      list.add(_mapFromFirestore(doc, userName));
    }
    return list;
  }

  /// GET pemasukan by ID
  Future<PemasukanModel> getById(String id) async {
    final doc = await _ref.doc(id).get();
    if (!doc.exists) {
      throw Exception('Data Pemasukan tidak ditemukan.');
    }
    final data = doc.data()!;
    final uid = data['created_by']?.toString();
    final userName = await _resolveUserName(uid, null, data);
    return _mapFromFirestore(doc, userName);
  }

  /// POST /create a new pemasukan record
  Future<PemasukanModel> create(PemasukanModel pemasukan) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Pengguna tidak terautentikasi.');
    }

    final userName = await _resolveUserName(uid, null, {});
    final data = _mapToFirestore(pemasukan, uid, userName);
    final docRef = await _ref.add(data);
    final doc = await docRef.get();
    return _mapFromFirestore(doc, userName);
  }

  /// PUT /update a pemasukan record
  Future<PemasukanModel> update(String id, PemasukanModel pemasukan) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Pengguna tidak terautentikasi.');
    }

    // Check if document exists first
    final existingDoc = await _ref.doc(id).get();
    if (!existingDoc.exists) {
      throw Exception('Data Pemasukan tidak ditemukan.');
    }

    // Avoid updating created_by to satisfy rules
    final originalCreatedBy = existingDoc.data()?['created_by'] ?? uid;
    final originalCreatedByName = await _resolveUserName(originalCreatedBy, null, existingDoc.data()!);

    final data = _mapToFirestore(pemasukan, originalCreatedBy, originalCreatedByName);
    data.remove('created_at'); // Do not overwrite created_at on update
    data['updated_at'] = FieldValue.serverTimestamp();

    await _ref.doc(id).update(data);
    final updatedDoc = await _ref.doc(id).get();
    return _mapFromFirestore(updatedDoc, originalCreatedByName);
  }

  /// DELETE a pemasukan record by ID
  Future<void> delete(String id) async {
    await _ref.doc(id).delete();
  }

  /// Helper to convert PemasukanModel to Firestore map
  Map<String, dynamic> _mapToFirestore(PemasukanModel model, String uid, String userName) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(model.tanggal);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return {
      'tanggal': Timestamp.fromDate(parsedDate),
      'hari': model.hari,
      'cash': model.cash.toInt(),
      'transfer_bca': model.transfer.toInt(),
      'qris_dana': model.qris.toInt(),
      'denda': model.denda.toInt(),
      'kerusakan': model.kerusakan.toInt(),
      'dp': model.dp.toInt(),
      'total_pemasukan': model.totalPemasukan.toInt(),
      'setoran_aktual': model.setoranAktual.toInt(),
      'saldo_sistem': model.saldoSistem.toInt(),
      'selisih': model.selisih.toInt(),
      'catatan': model.catatan ?? '',
      'created_by': uid,
      'created_by_name': userName,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /// Helper to map Firestore Document to PemasukanModel
  PemasukanModel _mapFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, String userName) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Data kosong.');
    }

    String dateStr = '';
    if (data['tanggal'] is Timestamp) {
      final timestamp = data['tanggal'] as Timestamp;
      dateStr = timestamp.toDate().toIso8601String().split('T')[0];
    } else if (data['tanggal'] is String) {
      dateStr = (data['tanggal'] as String).split('T')[0];
    }

    return PemasukanModel(
      id: doc.id,
      tanggal: dateStr,
      hari: data['hari'] ?? '',
      cash: (data['cash'] as num?)?.toDouble() ?? 0.0,
      transfer: (data['transfer_bca'] as num?)?.toDouble() ?? 0.0,
      qris: (data['qris_dana'] as num?)?.toDouble() ?? 0.0,
      denda: (data['denda'] as num?)?.toDouble() ?? 0.0,
      kerusakan: (data['kerusakan'] as num?)?.toDouble() ?? 0.0,
      dp: (data['dp'] as num?)?.toDouble() ?? 0.0,
      totalPemasukan: (data['total_pemasukan'] as num?)?.toDouble() ?? 0.0,
      setoranAktual: (data['setoran_aktual'] as num?)?.toDouble() ?? 0.0,
      saldoSistem: (data['saldo_sistem'] as num?)?.toDouble() ?? 0.0,
      selisih: (data['selisih'] as num?)?.toDouble() ?? 0.0,
      catatan: data['catatan']?.toString() ?? '',
      createdBy: userName,
      createdAt: (data['created_at'] as Timestamp?)?.toDate().toIso8601String(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate().toIso8601String(),
    );
  }

  /// GET daily summary of total pengeluaran and other pemasukan on a date
  Future<Map<String, double>> getDailySummary(String dateStr, {String? excludeId}) async {
    final date = DateTime.parse(dateStr);
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final pengeluaranSnap = await _firestore
        .collection('pengeluaran')
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    double totalPengeluaran = 0.0;
    for (var doc in pengeluaranSnap.docs) {
      totalPengeluaran += (doc.data()['nominal'] as num?)?.toDouble() ?? 0.0;
    }

    final pemasukanSnap = await _ref
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    double otherPemasukan = 0.0;
    for (var doc in pemasukanSnap.docs) {
      if (excludeId != null && doc.id == excludeId) continue;
      otherPemasukan += (doc.data()['total_pemasukan'] as num?)?.toDouble() ?? 0.0;
    }

    return {
      'totalPengeluaran': totalPengeluaran,
      'otherPemasukan': otherPemasukan,
    };
  }
}
