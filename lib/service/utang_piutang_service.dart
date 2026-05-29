import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/utang_piutang_model.dart';

class UtangPiutangService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UtangPiutangService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _ref => _firestore.collection('utang_piutang');

  /// GET all utang_piutang records ordered by created_at descending
  Future<List<UtangPiutangModel>> getAll() async {
    final querySnap = await _ref.orderBy('created_at', descending: true).get();
    return querySnap.docs.map((doc) => _mapFromFirestore(doc)).toList();
  }

  /// GET utang_piutang by ID
  Future<UtangPiutangModel> getById(String id) async {
    final doc = await _ref.doc(id).get();
    if (!doc.exists) {
      throw Exception('Data Utang/Piutang tidak ditemukan.');
    }
    return _mapFromFirestore(doc);
  }

  /// POST /create a new utang_piutang record
  Future<UtangPiutangModel> create(UtangPiutangModel utangPiutang) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Pengguna tidak terautentikasi.');
    }

    final data = _mapToFirestore(utangPiutang, uid);
    final docRef = await _ref.add(data);
    final doc = await docRef.get();
    return _mapFromFirestore(doc);
  }

  /// PUT /update a utang_piutang record
  Future<UtangPiutangModel> update(String id, UtangPiutangModel utangPiutang) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Pengguna tidak terautentikasi.');
    }

    // Check if document exists first
    final existingDoc = await _ref.doc(id).get();
    if (!existingDoc.exists) {
      throw Exception('Data Utang/Piutang tidak ditemukan.');
    }

    // Avoid updating created_by to satisfy rules
    final originalCreatedBy = existingDoc.data()?['created_by'] ?? uid;

    final data = _mapToFirestore(utangPiutang, originalCreatedBy);
    data.remove('created_at'); // Do not overwrite created_at on update
    data['updated_at'] = FieldValue.serverTimestamp();

    await _ref.doc(id).update(data);
    final updatedDoc = await _ref.doc(id).get();
    return _mapFromFirestore(updatedDoc);
  }

  /// DELETE a utang_piutang record by ID
  Future<void> delete(String id) async {
    await _ref.doc(id).delete();
  }

  /// Helper to convert UtangPiutangModel to Firestore map
  Map<String, dynamic> _mapToFirestore(UtangPiutangModel model, String uid) {
    return {
      'nama_customer': model.nama,
      'tipe': model.tipe,
      'total_tagihan': model.totalTagihan.toInt(),
      'dp': model.dp.toInt(),
      'sisa_pembayaran': model.sisaPembayaran.toInt(),
      'status': model.status,
      'keterangan': model.keterangan ?? '',
      'created_by': uid,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /// Helper to map Firestore Document to UtangPiutangModel
  UtangPiutangModel _mapFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Data kosong.');
    }

    return UtangPiutangModel(
      id: doc.id,
      nama: data['nama_customer'] ?? '',
      tipe: data['tipe'] ?? 'utang',
      totalTagihan: (data['total_tagihan'] as num?)?.toDouble() ?? 0.0,
      dp: (data['dp'] as num?)?.toDouble() ?? 0.0,
      sisaPembayaran: (data['sisa_pembayaran'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'belum_lunas',
      keterangan: data['keterangan'],
      createdBy: data['created_by'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate().toIso8601String(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate().toIso8601String(),
    );
  }
}
