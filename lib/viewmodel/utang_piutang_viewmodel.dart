import 'package:flutter/material.dart';
import '../core/constants/app_enums.dart';
import '../model/utang_piutang_model.dart';
import '../repository/utang_piutang_repository.dart';

export '../core/constants/app_enums.dart' show ViewState;

class UtangPiutangViewModel extends ChangeNotifier {
  final UtangPiutangRepository _repository;

  ViewState _state = ViewState.idle;
  List<UtangPiutangModel> _list = [];
  String? _errorMessage;
  bool _mutating = false;

  UtangPiutangViewModel({UtangPiutangRepository? repository})
      : _repository = repository ?? UtangPiutangRepository();

  ViewState get state => _state;
  List<UtangPiutangModel> get list => List.unmodifiable(_list);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ViewState.loading;
  bool get isMutating => _mutating;

  double get totalUtang => _list
      .where((e) => e.tipe.toLowerCase() == 'utang')
      .fold(0.0, (sum, item) => sum + item.sisaPembayaran);

  double get totalPiutang => _list
      .where((e) => e.tipe.toLowerCase() == 'piutang')
      .fold(0.0, (sum, item) => sum + item.sisaPembayaran);

  double get totalBelumLunasUtang => _list
      .where((e) => e.tipe.toLowerCase() == 'utang' && e.status == 'belum_lunas')
      .fold(0.0, (sum, item) => sum + item.sisaPembayaran);

  double get totalBelumLunasPiutang => _list
      .where((e) => e.tipe.toLowerCase() == 'piutang' && e.status == 'belum_lunas')
      .fold(0.0, (sum, item) => sum + item.sisaPembayaran);

  Future<void> loadAll() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _list = await _repository.getAll();
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('AppException: ', '');
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<bool> create(UtangPiutangModel item) async {
    _mutating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final created = await _repository.create(item);
      _list = [created, ..._list];
      _mutating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('AppException: ', '');
      _mutating = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> createWithSettlement(UtangPiutangModel item) async {
    _mutating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _repository.createWithSettlement(item);
      final created = result['createdItem'] as UtangPiutangModel;
      _list = [created, ..._list];
      _mutating = false;
      notifyListeners();
      return {
        'success': true,
        'settlementCreated': result['settlementCreated'] ?? false,
        'settlementType': result['settlementType'],
        'settlementAmount': result['settlementAmount'] ?? 0.0,
      };
    } catch (e) {
      _errorMessage = e.toString().replaceAll('AppException: ', '');
      _mutating = false;
      notifyListeners();
      return {
        'success': false,
        'settlementCreated': false,
        'settlementType': null,
        'settlementAmount': 0.0,
      };
    }
  }

  Future<bool> update(String id, UtangPiutangModel item) async {
    _mutating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _repository.update(id, item);
      final idx = _list.indexWhere((e) => e.id == id);
      if (idx != -1) {
        final mutable = List<UtangPiutangModel>.from(_list);
        mutable[idx] = updated;
        _list = mutable;
      }
      _mutating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('AppException: ', '');
      _mutating = false;
      notifyListeners();
      return false;
    }
  }

  /// Update with settlement detection.
  /// Returns a Map with:
  ///   - 'success': bool
  ///   - 'settlementCreated': bool
  ///   - 'settlementType': String? ('pemasukan' or 'pengeluaran')
  ///   - 'settlementAmount': double
  Future<Map<String, dynamic>> updateWithSettlement(
    String id,
    UtangPiutangModel item, {
    DateTime? settlementDate,
  }) async {
    _mutating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _repository.updateWithSettlement(id, item, settlementDate: settlementDate);
      final updated = result['updatedItem'] as UtangPiutangModel;
      final idx = _list.indexWhere((e) => e.id == id);
      if (idx != -1) {
        final mutable = List<UtangPiutangModel>.from(_list);
        mutable[idx] = updated;
        _list = mutable;
      }
      _mutating = false;
      notifyListeners();
      return {
        'success': true,
        'settlementCreated': result['settlementCreated'] ?? false,
        'settlementType': result['settlementType'],
        'settlementAmount': result['settlementAmount'] ?? 0.0,
      };
    } catch (e) {
      _errorMessage = e.toString().replaceAll('AppException: ', '');
      _mutating = false;
      notifyListeners();
      return {
        'success': false,
        'settlementCreated': false,
        'settlementType': null,
        'settlementAmount': 0.0,
      };
    }
  }

  Future<bool> delete(String id) async {
    _mutating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.delete(id);
      _list = _list.where((e) => e.id != id).toList();
      _mutating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('AppException: ', '');
      _mutating = false;
      notifyListeners();
      return false;
    }
  }
}

