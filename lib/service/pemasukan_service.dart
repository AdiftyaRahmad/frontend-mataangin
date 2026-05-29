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

  /// GET all pemasukan records ordered by date descending
  Future<List<PemasukanModel>> getAll() async {
    final querySnap = await _ref.orderBy('tanggal', descending: true).get();
    return querySnap.docs.map((doc) => _mapFromFirestore(doc)).toList();
  }

  /// GET pemasukan by ID
  Future<PemasukanModel> getById(String id) async {
    final doc = await _ref.doc(id).get();
    if (!doc.exists) {
      throw Exception('Data Pemasukan tidak ditemukan.');
    }
    return _mapFromFirestore(doc);
  }

  /// POST /create a new pemasukan record
  Future<PemasukanModel> create(PemasukanModel pemasukan) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Pengguna tidak terautentikasi.');
    }

    final data = _mapToFirestore(pemasukan, uid);
    final docRef = await _ref.add(data);
    final doc = await docRef.get();
    return _mapFromFirestore(doc);
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

    final data = _mapToFirestore(pemasukan, originalCreatedBy);
    data.remove('created_at'); // Do not overwrite created_at on update
    data['updated_at'] = FieldValue.serverTimestamp();

    await _ref.doc(id).update(data);
    final updatedDoc = await _ref.doc(id).get();
    return _mapFromFirestore(updatedDoc);
  }

  /// DELETE a pemasukan record by ID
  Future<void> delete(String id) async {
    await _ref.doc(id).delete();
  }

  /// Helper to convert PemasukanModel to Firestore map
  Map<String, dynamic> _mapToFirestore(PemasukanModel model, String uid) {
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
      'created_by': uid,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /// Helper to map Firestore Document to PemasukanModel
  PemasukanModel _mapFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
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
      createdBy: data['created_by'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate().toIso8601String(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate().toIso8601String(),
    );
  }
}
