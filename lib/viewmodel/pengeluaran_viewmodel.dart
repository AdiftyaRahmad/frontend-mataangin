import 'package:flutter/material.dart';
import '../core/constants/app_enums.dart';
import '../model/pengeluaran_model.dart';
import '../repository/pengeluaran_repository.dart';

export '../core/constants/app_enums.dart' show ViewState;

class PengeluaranViewModel extends ChangeNotifier {
  final PengeluaranRepository _repository;

  ViewState _state = ViewState.idle;
  List<PengeluaranModel> _list = [];
  String? _errorMessage;
  bool _mutating = false;

  PengeluaranViewModel({PengeluaranRepository? repository})
      : _repository = repository ?? PengeluaranRepository();

  ViewState get state => _state;
  List<PengeluaranModel> get list => List.unmodifiable(_list);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ViewState.loading;
  bool get isMutating => _mutating;

  double get totalPengeluaran =>
      _list.fold(0.0, (sum, item) => sum + item.nominal);

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

  Future<bool> create(PengeluaranModel pengeluaran) async {
    _mutating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final created = await _repository.create(pengeluaran);
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

  Future<bool> update(String id, PengeluaranModel pengeluaran) async {
    _mutating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _repository.update(id, pengeluaran);
      final idx = _list.indexWhere((e) => e.id == id);
      if (idx != -1) {
        final mutable = List<PengeluaranModel>.from(_list);
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
