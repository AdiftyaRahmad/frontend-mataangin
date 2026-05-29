import 'package:flutter/material.dart';
import '../core/constants/app_enums.dart';
import '../model/laporan_model.dart';
import '../repository/laporan_repository.dart';
import '../core/utils/file_saver.dart';

export '../core/constants/app_enums.dart' show ViewState;

class LaporanViewModel extends ChangeNotifier {
  final LaporanRepository _repository;

  ViewState _harianState = ViewState.idle;
  ViewState _bulananState = ViewState.idle;
  ViewState _exportState = ViewState.idle;

  LaporanModel _laporanHarian = LaporanModel.empty();
  LaporanModel _laporanBulanan = LaporanModel.empty();

  String? _harianError;
  String? _bulananError;
  String? _exportError;

  LaporanViewModel({LaporanRepository? repository})
      : _repository = repository ?? LaporanRepository();

  ViewState get harianState => _harianState;
  ViewState get bulananState => _bulananState;
  ViewState get exportState => _exportState;

  LaporanModel get laporanHarian => _laporanHarian;
  LaporanModel get laporanBulanan => _laporanBulanan;

  String? get harianError => _harianError;
  String? get bulananError => _bulananError;
  String? get exportError => _exportError;

  bool get isHarianLoading => _harianState == ViewState.loading;
  bool get isBulananLoading => _bulananState == ViewState.loading;
  bool get isExporting => _exportState == ViewState.loading;

  Future<void> loadHarian(String tanggal) async {
    _harianState = ViewState.loading;
    _harianError = null;
    notifyListeners();
    try {
      _laporanHarian = await _repository.getHarian(tanggal);
      _harianState = ViewState.success;
    } catch (e) {
      _harianError = e.toString().replaceAll('AppException: ', '');
      _harianState = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> loadBulanan(String bulan, String tahun) async {
    _bulananState = ViewState.loading;
    _bulananError = null;
    notifyListeners();
    try {
      _laporanBulanan = await _repository.getBulanan(bulan, tahun);
      _bulananState = ViewState.success;
    } catch (e) {
      _bulananError = e.toString().replaceAll('AppException: ', '');
      _bulananState = ViewState.error;
    }
    notifyListeners();
  }

  Future<bool> exportPdf() async {
    _exportState = ViewState.loading;
    _exportError = null;
    notifyListeners();
    try {
      final bytes = await _repository.exportPdfBytes();
      final now = DateTime.now();
      final fileName = 'laporan_mata_angin_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.pdf';
      saveFile(bytes, fileName, 'application/pdf');
      _exportState = ViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _exportError = e.toString().replaceAll('AppException: ', '');
      _exportState = ViewState.error;
      notifyListeners();
      return false;
    }
  }
}
