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

  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  PengeluaranViewModel({PengeluaranRepository? repository})
    : _repository = repository ?? PengeluaranRepository();

  ViewState get state => _state;
  List<PengeluaranModel> get list => List.unmodifiable(_list);
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;
  bool get isFiltered => _filterStartDate != null || _filterEndDate != null;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ViewState.loading;
  bool get isMutating => _mutating;

  // Helper getters for totals
  double get totalHarian {
    final now = DateTime.now();
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return _list
        .where((item) => item.tanggal == todayStr)
        .fold(0.0, (sum, item) => sum + item.nominal);
  }

  double get totalBulanan {
    final now = DateTime.now();
    final monthStr = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    return _list
        .where((item) => item.tanggal.startsWith(monthStr))
        .fold(0.0, (sum, item) => sum + item.nominal);
  }

  // Only for backwards compatibility if needed, but UI will use totalHarian & totalBulanan
  double get totalPengeluaran => totalHarian;

  List<PengeluaranModel> get filteredList {
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
