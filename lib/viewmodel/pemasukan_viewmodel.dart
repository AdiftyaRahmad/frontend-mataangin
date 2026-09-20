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

  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  PemasukanViewModel({PemasukanRepository? repository})
      : _repository = repository ?? PemasukanRepository();

  ViewState get state => _state;
  List<PemasukanModel> get list => List.unmodifiable(_list);
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;
  bool get isFiltered => _filterStartDate != null || _filterEndDate != null;

  List<PemasukanModel> get filteredList {
    if (_filterStartDate == null && _filterEndDate == null) {
      return List.unmodifiable(_list);
    }
    final start = _filterStartDate != null
        ? DateTime(_filterStartDate!.year, _filterStartDate!.month, _filterStartDate!.day)
        : null;
    final end = _filterEndDate != null
        ? DateTime(_filterEndDate!.year, _filterEndDate!.month, _filterEndDate!.day)
        : null;

    return _list.where((item) {
      final dt = DateTime.tryParse(item.tanggal);
      if (dt == null) return false;
      final dateOnly = DateTime(dt.year, dt.month, dt.day);

      if (start != null && dateOnly.isBefore(start)) return false;
      if (end != null && dateOnly.isAfter(end)) return false;
      return true;
    }).toList();
  }

  void applyFilter(DateTime? start, DateTime? end) {
    _filterStartDate = start;
    _filterEndDate = end;
    notifyListeners();
  }

  void clearFilter() {
    _filterStartDate = null;
    _filterEndDate = null;
    notifyListeners();
  }

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

  Future<bool> update(String id, PemasukanModel pemasukan) async {
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

  Future<Map<String, double>> getDailySummary(String dateStr, int shift, {String? excludeId}) =>
      _repository.getDailySummary(dateStr, shift, excludeId: excludeId);
}
