import 'package:flutter/material.dart';
import '../core/constants/app_enums.dart';
import '../model/pemasukan_model.dart';
import '../repository/pemasukan_repository.dart';

export '../core/constants/app_enums.dart' show ViewState;

class PemasukanViewModel extends ChangeNotifier {
  final PemasukanRepository _repository;

  ViewState _state = ViewState.idle;
  List<PemasukanModel> _list = [];
  String? _errorMessage;
  bool _mutating = false;

  PemasukanViewModel({PemasukanRepository? repository})
      : _repository = repository ?? PemasukanRepository();

  ViewState get state => _state;
  List<PemasukanModel> get list => List.unmodifiable(_list);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ViewState.loading;
  bool get isMutating => _mutating;

  double get totalPemasukan =>
      _list.fold(0.0, (sum, item) => sum + item.totalPemasukan);

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

  Future<bool> create(PemasukanModel pemasukan) async {
    _mutating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final created = await _repository.create(pemasukan);
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

  Future<bool> update(int id, PemasukanModel pemasukan) async {
    _mutating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _repository.update(id, pemasukan);
      final idx = _list.indexWhere((e) => e.id == id);
      if (idx != -1) {
        final mutable = List<PemasukanModel>.from(_list);
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

  Future<bool> delete(int id) async {
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
