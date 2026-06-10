import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/pengeluaran_model.dart';

class PengeluaranService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PengeluaranService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _ref => _firestore.collection('pengeluaran');

  /// GET all pengeluaran records ordered by date descending
  Future<List<PengeluaranModel>> getAll() async {
    final querySnap = await _ref.orderBy('tanggal', descending: true).get();
    return querySnap.docs.map((doc) => _mapFromFirestore(doc)).toList();
  }

  /// GET pengeluaran by ID
  Future<PengeluaranModel> getById(String id) async {
    final doc = await _ref.doc(id).get();
    if (!doc.exists) {
      throw Exception('Data Pengeluaran tidak ditemukan.');
    }
    return _mapFromFirestore(doc);
  }

  /// POST /create a new pengeluaran record
  Future<PengeluaranModel> create(PengeluaranModel pengeluaran) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Pengguna tidak terautentikasi.');
    }

    final data = _mapToFirestore(pengeluaran, uid);
    final docRef = await _ref.add(data);
    final doc = await docRef.get();
    return _mapFromFirestore(doc);
  }

  /// PUT /update a pengeluaran record
  Future<PengeluaranModel> update(String id, PengeluaranModel pengeluaran) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Pengguna tidak terautentikasi.');
    }

    // Check if document exists first
    final existingDoc = await _ref.doc(id).get();
    if (!existingDoc.exists) {
      throw Exception('Data Pengeluaran tidak ditemukan.');
    }

    // Avoid updating created_by to satisfy rules
    final originalCreatedBy = existingDoc.data()?['created_by'] ?? uid;

    final data = _mapToFirestore(pengeluaran, originalCreatedBy);
    data.remove('created_at'); // Do not overwrite created_at on update
    data['updated_at'] = FieldValue.serverTimestamp();

    await _ref.doc(id).update(data);
    final updatedDoc = await _ref.doc(id).get();
    return _mapFromFirestore(updatedDoc);
  }

  /// DELETE a pengeluaran record by ID
  Future<void> delete(String id) async {
    await _ref.doc(id).delete();
  }

  /// Helper to convert PengeluaranModel to Firestore map
  Map<String, dynamic> _mapToFirestore(PengeluaranModel model, String uid) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(model.tanggal);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return {
      'nama_barang': model.namaBarang,
      'nominal': model.nominal.toInt(),
      'keterangan': model.keterangan ?? '',
      'kategori': model.kategori,
      'tanggal': Timestamp.fromDate(parsedDate),
      'created_by': uid,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /// Helper to map Firestore Document to PengeluaranModel
  PengeluaranModel _mapFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
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

    return PengeluaranModel(
      id: doc.id,
      namaBarang: data['nama_barang'] ?? '',
      nominal: (data['nominal'] as num?)?.toDouble() ?? 0.0,
      keterangan: data['keterangan'],
      kategori: data['kategori'] ?? 'Pengeluaran lainya',
      tanggal: dateStr,
      createdBy: data['created_by'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate().toIso8601String(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate().toIso8601String(),
    );
  }
}
