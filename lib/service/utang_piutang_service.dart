import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../model/utang_piutang_model.dart';

class UtangPiutangService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UtangPiutangService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _ref => _firestore.collection('utang_piutang');

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

  /// GET all utang_piutang records ordered by created_at descending
  Future<List<UtangPiutangModel>> getAll() async {
    final querySnap = await _ref.orderBy('created_at', descending: true).get();
    final List<UtangPiutangModel> list = [];
    final Map<String, String> cache = {};

    for (final doc in querySnap.docs) {
      final data = doc.data();
      final uid = data['created_by']?.toString();
      final userName = await _resolveUserName(uid, cache, data);
      list.add(_mapFromFirestore(doc, userName));
    }
    return list;
  }

  /// GET utang_piutang by ID
  Future<UtangPiutangModel> getById(String id) async {
    final doc = await _ref.doc(id).get();
    if (!doc.exists) {
      throw Exception('Data Utang/Piutang tidak ditemukan.');
    }
    final data = doc.data()!;
    final uid = data['created_by']?.toString();
    final userName = await _resolveUserName(uid, null, data);
    return _mapFromFirestore(doc, userName);
  }

  /// POST /create a new utang_piutang record
  Future<UtangPiutangModel> create(UtangPiutangModel utangPiutang) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Pengguna tidak terautentikasi.');
    }

    final userName = await _resolveUserName(uid, null, {});
    final data = _mapToFirestore(utangPiutang, uid, userName);
    final docRef = await _ref.add(data);
    final doc = await docRef.get();
    return _mapFromFirestore(doc, userName);
  }

  /// POST /create a new utang_piutang record with optional settlement/DP recording
  Future<Map<String, dynamic>> createWithSettlement(UtangPiutangModel utangPiutang) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Pengguna tidak terautentikasi.');
    }

    final userName = await _resolveUserName(uid, null, {});
    final data = _mapToFirestore(utangPiutang, uid, userName);

    // Calculate initial paid amount (DP or full payment)
    final paidAmount = utangPiutang.totalTagihan - utangPiutang.sisaPembayaran;
    final hasInitialPayment = paidAmount > 0;

    final docRef = _ref.doc(); // Generate ID beforehand

    if (hasInitialPayment) {
      final batch = _firestore.batch();
      
      // 1. Create the utang_piutang document
      batch.set(docRef, data);

      // 2. Create settlement/payment record
      final recordDate = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(recordDate);
      final hariIndo = _getHariIndonesia(recordDate.weekday);
      final tipe = utangPiutang.tipe.toLowerCase();

      if (tipe == 'piutang' || tipe == 'customer') {
        // Piutang DP/Full payment → customer pays us → Pemasukan
        final pemasukanRef = _firestore.collection('pemasukan').doc();
        batch.set(pemasukanRef, {
          'tanggal': Timestamp.fromDate(DateTime.parse(todayStr)),
          'hari': hariIndo,
          'cash': paidAmount.toInt(),
          'transfer_bca': 0,
          'qris_dana': 0,
          'denda': 0,
          'kerusakan': 0,
          'dp': 0,
          'total_pemasukan': paidAmount.toInt(),
          'created_by': uid,
          'created_by_name': userName,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
          'keterangan_pelunasan': utangPiutang.status == 'lunas'
              ? 'Pelunasan piutang: ${utangPiutang.nama}'
              : 'DP piutang: ${utangPiutang.nama}',
        });
      } else {
        // Utang DP/Full payment → we pay supplier → Pengeluaran
        final pengeluaranRef = _firestore.collection('pengeluaran').doc();
        batch.set(pengeluaranRef, {
          'nama_barang': utangPiutang.status == 'lunas'
              ? 'Pelunasan utang: ${utangPiutang.nama}'
              : 'DP utang: ${utangPiutang.nama}',
          'nominal': paidAmount.toInt(),
          'keterangan': utangPiutang.status == 'lunas'
              ? 'Pelunasan otomatis utang kepada ${utangPiutang.nama}'
              : 'DP otomatis utang kepada ${utangPiutang.nama}',
          'kategori': 'Lainnya',
          'tanggal': Timestamp.fromDate(DateTime.parse(todayStr)),
          'created_by': uid,
          'created_by_name': userName,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      final doc = await docRef.get();
      return {
        'createdItem': _mapFromFirestore(doc, userName),
        'settlementCreated': true,
        'settlementType': (tipe == 'piutang' || tipe == 'customer') ? 'pemasukan' : 'pengeluaran',
        'settlementAmount': paidAmount,
      };
    } else {
      // Normal creation without payment
      final docRef = await _ref.add(data);
      final doc = await docRef.get();
      return {
        'createdItem': _mapFromFirestore(doc, userName),
        'settlementCreated': false,
        'settlementType': null,
        'settlementAmount': 0.0,
      };
    }
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
    final originalCreatedByName = await _resolveUserName(originalCreatedBy, null, existingDoc.data()!);

    final data = _mapToFirestore(utangPiutang, originalCreatedBy, originalCreatedByName);
    data.remove('created_at'); // Do not overwrite created_at on update
    data['updated_at'] = FieldValue.serverTimestamp();

    await _ref.doc(id).update(data);
    final updatedDoc = await _ref.doc(id).get();
    return _mapFromFirestore(updatedDoc, originalCreatedByName);
  }

  /// UPDATE utang/piutang AND auto-record settlement to pemasukan/pengeluaran.
  Future<Map<String, dynamic>> updateWithSettlement(
    String id,
    UtangPiutangModel utangPiutang, {
    DateTime? settlementDate,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Pengguna tidak terautentikasi.');
    }

    // Fetch existing document to compare status
    final existingDoc = await _ref.doc(id).get();
    if (!existingDoc.exists) {
      throw Exception('Data Utang/Piutang tidak ditemukan.');
    }

    final existingData = existingDoc.data()!;
    final oldStatus = existingData['status'] ?? 'belum_lunas';
    final newStatus = utangPiutang.status;
    final oldSisaPembayaran = (existingData['sisa_pembayaran'] as num?)?.toDouble() ?? 0.0;

    // Determine if we need to create a settlement record
    final isBecomingLunas = oldStatus == 'belum_lunas' && newStatus == 'lunas';

    // The settlement amount is the old sisa_pembayaran (amount that was just settled)
    final settlementAmount = isBecomingLunas ? oldSisaPembayaran : 0.0;

    // Avoid updating created_by to satisfy rules
    final originalCreatedBy = existingData['created_by'] ?? uid;
    final originalCreatedByName = await _resolveUserName(originalCreatedBy, null, existingData);

    final updateData = _mapToFirestore(utangPiutang, originalCreatedBy, originalCreatedByName);
    updateData.remove('created_at');
    updateData['updated_at'] = FieldValue.serverTimestamp();

    if (isBecomingLunas && settlementAmount > 0) {
      // Use Firestore batch for atomicity
      final batch = _firestore.batch();

      // 1. Update the utang_piutang document
      batch.update(_ref.doc(id), updateData);

      // 2. Create settlement record
      // Use provided settlementDate, or default to today
      final recordDate = settlementDate ?? DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(recordDate);
      final hariIndo = _getHariIndonesia(recordDate.weekday);
      final tipe = utangPiutang.tipe.toLowerCase();

      // Ambil nama user dari Firestore untuk pelunasan otomatis
      final userName = await _resolveUserName(uid, null, {});

      if (tipe == 'piutang' || tipe == 'customer') {
        // Piutang lunas → customer pays us → Pemasukan
        final pemasukanRef = _firestore.collection('pemasukan').doc();
        batch.set(pemasukanRef, {
          'tanggal': Timestamp.fromDate(DateTime.parse(todayStr)),
          'hari': hariIndo,
          'cash': settlementAmount.toInt(),
          'transfer_bca': 0,
          'qris_dana': 0,
          'denda': 0,
          'kerusakan': 0,
          'dp': 0,
          'total_pemasukan': settlementAmount.toInt(),
          'created_by': uid,
          'created_by_name': userName,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
          'keterangan_pelunasan': 'Pelunasan piutang: ${utangPiutang.nama}',
        });
      } else {
        // Utang lunas → we pay supplier → Pengeluaran
        final pengeluaranRef = _firestore.collection('pengeluaran').doc();
        batch.set(pengeluaranRef, {
          'nama_barang': 'Pelunasan utang: ${utangPiutang.nama}',
          'nominal': settlementAmount.toInt(),
          'keterangan': 'Pelunasan otomatis utang kepada ${utangPiutang.nama}',
          'kategori': 'Lainnya',
          'tanggal': Timestamp.fromDate(DateTime.parse(todayStr)),
          'created_by': uid,
          'created_by_name': userName,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      // Commit batch
      await batch.commit();

      // Fetch updated document
      final updatedDoc = await _ref.doc(id).get();
      return {
        'updatedItem': _mapFromFirestore(updatedDoc, originalCreatedByName),
        'settlementCreated': true,
        'settlementType': (tipe == 'piutang' || tipe == 'customer') ? 'pemasukan' : 'pengeluaran',
        'settlementAmount': settlementAmount,
      };
    } else {
      // No settlement needed — just update normally
      await _ref.doc(id).update(updateData);
      final updatedDoc = await _ref.doc(id).get();
      return {
        'updatedItem': _mapFromFirestore(updatedDoc, originalCreatedByName),
        'settlementCreated': false,
        'settlementType': null,
        'settlementAmount': 0.0,
      };
    }
  }

  /// DELETE a utang_piutang record by ID
  Future<void> delete(String id) async {
    await _ref.doc(id).delete();
  }

  /// Helper: get Indonesian day name from weekday int
  String _getHariIndonesia(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
        return 'Minggu';
      default:
        return 'Senin';
    }
  }

  /// Helper to convert UtangPiutangModel to Firestore map
  Map<String, dynamic> _mapToFirestore(UtangPiutangModel model, String uid, String userName) {
    return {
      'nama_customer': model.nama,
      'tipe': model.tipe,
      'total_tagihan': model.totalTagihan.toInt(),
      'dp': model.dp.toInt(),
      'sisa_pembayaran': model.sisaPembayaran.toInt(),
      'status': model.status,
      'keterangan': model.keterangan ?? '',
      'created_by': uid,
      'created_by_name': userName,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /// Helper to map Firestore Document to UtangPiutangModel
  UtangPiutangModel _mapFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, String userName) {
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
      createdBy: userName,
      createdAt: (data['created_at'] as Timestamp?)?.toDate().toIso8601String(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate().toIso8601String(),
    );
  }
}
