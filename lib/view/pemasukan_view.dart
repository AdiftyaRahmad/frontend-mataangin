import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/pemasukan_model.dart';
import '../viewmodel/pemasukan_viewmodel.dart';
import '../viewmodel/pengeluaran_viewmodel.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../core/widgets/admin_only_widget.dart';

class PemasukanView extends StatelessWidget {
  const PemasukanView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PemasukanViewModel>();
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1598A3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Pemasukan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.sync, color: Colors.white, size: 28),
              onPressed: () => context.read<PemasukanViewModel>().loadAll(),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 8),
        child: SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            heroTag: 'pemasukan_fab',
            backgroundColor: const Color(0xFF0A7E8C),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            onPressed: () => _showFormDialog(context),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Total Banner ────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A7E8C),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.trending_up,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pemasukan',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fmt.format(vm.totalPemasukan),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── List ─────────────────────────────────────────────────────────
          Expanded(child: _buildList(context, vm, fmt)),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    PemasukanViewModel vm,
    NumberFormat fmt,
  ) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1598A3)),
      );
    }
    if (vm.state == ViewState.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
            const SizedBox(height: 12),
            Text(
              vm.errorMessage ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<PemasukanViewModel>().loadAll(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1598A3)),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
    if (vm.list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.white30),
            SizedBox(height: 12),
            Text(
              'Belum ada data pemasukan',
              style: TextStyle(color: Colors.white38),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      itemCount: vm.list.length,
      itemBuilder: (_, i) {
        final item = vm.list[i];
        return _PemasukanCard(
          item: item,
          fmt: fmt,
          onEdit: () => _showFormDialog(context, item: item),
          onDelete: () => _confirmDelete(context, item.id!),
        );
      },
    );
  }

  Future<void> _showFormDialog(
    BuildContext context, {
    PemasukanModel? item,
  }) async {
    final tanggalCtrl = TextEditingController(
        text: item?.tanggal ?? DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final cashCtrl = TextEditingController(
        text: item != null ? _formatRibuan(item.cash.toStringAsFixed(0)) : '');
    final transferCtrl = TextEditingController(
        text: item != null ? _formatRibuan(item.transfer.toStringAsFixed(0)) : '');
    final qrisCtrl = TextEditingController(
        text: item != null ? _formatRibuan(item.qris.toStringAsFixed(0)) : '');
    final setoranAktualCtrl = TextEditingController(
        text: item != null ? _formatRibuan(item.setoranAktual.toStringAsFixed(0)) : '');
    final catatanCtrl = TextEditingController(text: item?.catatan ?? '');
    final formKey = GlobalKey<FormState>();

    String getHariIndo(String dateStr) {
      try {
        final parsed = DateTime.parse(dateStr);
        switch (parsed.weekday) {
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
        }
      } catch (_) {}
      return 'Senin';
    }

    String currentHari = getHariIndo(tanggalCtrl.text);

    // Dynamic calculations from database
    double totalPengeluaran = 0.0;
    double otherPemasukan = 0.0;
    bool isLoadingDaily = false;
    bool isFirstLoad = true;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> fetchDaily(String dateStr) async {
            setModalState(() {
              isLoadingDaily = true;
            });
            try {
              final summary = await sheetCtx
                  .read<PemasukanViewModel>()
                  .getDailySummary(dateStr, excludeId: item?.id);
              setModalState(() {
                totalPengeluaran = summary['totalPengeluaran'] ?? 0.0;
                otherPemasukan = summary['otherPemasukan'] ?? 0.0;
                isLoadingDaily = false;
              });
            } catch (_) {
              setModalState(() {
                isLoadingDaily = false;
              });
            }
          }

          if (isFirstLoad) {
            isFirstLoad = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              fetchDaily(tanggalCtrl.text);
            });
          }

          double getSum() {
            final c = double.tryParse(cashCtrl.text.replaceAll('.', '')) ?? 0;
            final t = double.tryParse(transferCtrl.text.replaceAll('.', '')) ?? 0;
            final q = double.tryParse(qrisCtrl.text.replaceAll('.', '')) ?? 0;
            return c + t + q;
          }

          double getSaldoSistem() {
            return getSum() + otherPemasukan - totalPengeluaran;
          }

          double getSelisih() {
            final sa = double.tryParse(setoranAktualCtrl.text.replaceAll('.', '')) ?? 0;
            return sa - getSaldoSistem();
          }

          final fmtCur = NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item == null ? 'Tambah Pemasukan' : 'Edit Pemasukan',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 24),
                            onPressed: () => Navigator.pop(sheetCtx),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            // Date row
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate:
                                            DateTime.tryParse(tanggalCtrl.text) ??
                                                DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2100),
                                      );
                                      if (date != null) {
                                        final newDateStr =
                                            DateFormat('yyyy-MM-dd').format(date);
                                        setModalState(() {
                                          tanggalCtrl.text = newDateStr;
                                          currentHari = getHariIndo(newDateStr);
                                        });
                                        fetchDaily(newDateStr);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1598A3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        tanggalCtrl.text,
                                        style: const TextStyle(
                                          color: Color(0xFF1E1E1E),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF262E3B),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    currentHari,
                                    style: const TextStyle(
                                      color: Color(0xFF1598A3),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Rincian Pembayaran',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _labeledFormField(
                                    label: 'Cash',
                                    ctrl: cashCtrl,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setModalState(() {}),
                                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _labeledFormField(
                                    label: 'Transfer',
                                    ctrl: transferCtrl,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setModalState(() {}),
                                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _labeledFormField(
                              label: 'QRIS',
                              ctrl: qrisCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setModalState(() {}),
                              inputFormatters: [ThousandsSeparatorInputFormatter()],
                            ),
                            const SizedBox(height: 14),
                            _labeledFormField(
                              label: 'Setoran Aktual',
                              ctrl: setoranAktualCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setModalState(() {}),
                              inputFormatters: [ThousandsSeparatorInputFormatter()],
                            ),
                            const SizedBox(height: 14),
                            _labeledFormField(
                              label: 'Catatan Selisih',
                              ctrl: catatanCtrl,
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                              onChanged: (_) => setModalState(() {}),
                            ),
                            const SizedBox(height: 24),
                            isLoadingDaily
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(color: Color(0xFF1598A3)),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF252A34),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF383F51),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Total Pemasukan',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              fmtCur.format(getSum()),
                                              style: const TextStyle(
                                                color: Color(0xFF1598A3),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Pengeluaran Hari Ini',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              fmtCur.format(totalPengeluaran),
                                              style: const TextStyle(
                                                color: Color(0xFFEF4444),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (otherPemasukan > 0) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Pemasukan Lain Hari Ini',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                fmtCur.format(otherPemasukan),
                                                style: const TextStyle(
                                                  color: Color(0xFF1598A3),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        const Divider(color: Colors.white12, height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Saldo Sistem',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              fmtCur.format(getSaldoSistem()),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Selisih',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              (getSelisih() >= 0 ? '+' : '') + fmtCur.format(getSelisih()),
                                              style: TextStyle(
                                                color: getSelisih() >= 0 ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: const Color(0xFF262626),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Consumer<PemasukanViewModel>(
                        builder: (ctx, vm, _) => SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: vm.isMutating || isLoadingDaily
                                ? null
                               : () async {
                                    if (!formKey.currentState!.validate()) return;
                                    final data = PemasukanModel(
                                      id: item?.id,
                                      tanggal: tanggalCtrl.text,
                                      hari: currentHari,
                                      cash: double.tryParse(cashCtrl.text.replaceAll('.', '')) ?? 0,
                                      transfer:
                                          double.tryParse(transferCtrl.text.replaceAll('.', '')) ?? 0,
                                      qris: double.tryParse(qrisCtrl.text.replaceAll('.', '')) ?? 0,
                                      denda: 0.0,
                                      kerusakan: 0.0,
                                      dp: 0.0,
                                      totalPemasukan: getSum(),
                                      setoranAktual: double.tryParse(setoranAktualCtrl.text.replaceAll('.', '')) ?? 0,
                                      saldoSistem: getSaldoSistem(),
                                      selisih: getSelisih(),
                                      catatan: catatanCtrl.text,
                                    );
                                    bool success;
                                    if (item == null) {
                                      success = await ctx
                                          .read<PemasukanViewModel>()
                                          .create(data);
                                    } else {
                                      success = await ctx
                                          .read<PemasukanViewModel>()
                                          .update(item.id!, data);
                                    }
                                    if (context.mounted) {
                                      Navigator.pop(sheetCtx);
                                      if (success) {
                                        context.read<DashboardViewModel>().loadDashboard();
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                vm.errorMessage ?? 'Gagal menyimpan'),
                                            backgroundColor:
                                                const Color(0xFFEF4444),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1598A3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: vm.isMutating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    item == null
                                        ? 'Simpan Pemasukan'
                                        : 'Perbarui Pemasukan',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111C2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Pemasukan',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus data ini?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final success = await context.read<PemasukanViewModel>().delete(id);
      if (success && context.mounted) {
        context.read<DashboardViewModel>().loadDashboard();
      }
    }
  }
}

Widget _labeledFormField({
  required String label,
  required TextEditingController ctrl,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
  List<TextInputFormatter>? inputFormatters,
  int maxLines = 1,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          color: Color(0xFF1E1E1E),
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        cursorColor: const Color(0xFF1E1E1E),
        validator: validator,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF1598A3),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorStyle: const TextStyle(color: Color(0xFFFCA5A5)),
        ),
      ),
    ],
  );
}

class _PemasukanCard extends StatefulWidget {
  final PemasukanModel item;
  final NumberFormat fmt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PemasukanCard({
    required this.item,
    required this.fmt,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_PemasukanCard> createState() => _PemasukanCardState();
}

class _PemasukanCardState extends State<_PemasukanCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final pengeluaranVm = context.watch<PengeluaranViewModel>();
    final pemasukanVm = context.watch<PemasukanViewModel>();

    // Hitung total pengeluaran hari ini secara real-time dari list pengeluaran yang di-load
    final totalPengeluaran = pengeluaranVm.list
        .where((e) => e.tanggal == widget.item.tanggal)
        .fold(0.0, (sum, e) => sum + e.nominal);

    // Hitung pemasukan lain pada hari yang sama (selain dokumen pemasukan ini) secara real-time
    final otherPemasukan = pemasukanVm.list
        .where((e) => e.tanggal == widget.item.tanggal && e.id != widget.item.id)
        .fold(0.0, (sum, e) => sum + e.totalPemasukan);

    // Saldo sistem real-time = total pemasukan record ini + pemasukan lain - total pengeluaran
    final saldoSistem = widget.item.totalPemasukan + otherPemasukan - totalPengeluaran;

    // Selisih real-time = setor aktual - saldo sistem
    final selisih = widget.item.setoranAktual - saldoSistem;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ─────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2529), // Dark teal background
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Color(0xFF1598A3),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatDisplayDate(widget.item.hari, widget.item.tanggal),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: widget.onEdit,
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 12),
                          DeleteOnlyWidget(
                            child: InkWell(
                              onTap: widget.onDelete,
                              child: const Icon(
                                                                Icons.delete_outline_rounded,
                                size: 20,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dibuat oleh: ${widget.item.createdBy ?? '-'}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Divider ────────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: Colors.white10),
            ),

            // ── Breakdown grid ─────────────────────────────────────────────
            Row(
              children: [
                _breakdownItem('Cash', widget.fmt.format(widget.item.cash)),
                _breakdownItem('Transfer', widget.fmt.format(widget.item.transfer)),
                _breakdownItem('QRIS', widget.fmt.format(widget.item.qris)),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // ── Expandable Trigger ──────────────────────────────────────────
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rincian Keuangan',
                    style: TextStyle(
                      color: Color(0xFF1598A3),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF1598A3),
                    size: 24,
                  ),
                ],
              ),
            ),

            // ── Expanded Content ────────────────────────────────────────────
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              _rincianRow('Total Pemasukan', widget.fmt.format(widget.item.totalPemasukan), valueColor: const Color(0xFF1598A3)),
              _rincianRow('Total Pengeluaran', widget.fmt.format(totalPengeluaran), valueColor: const Color(0xFFEF4444)),
              _rincianRow('Saldo Sistem', widget.fmt.format(saldoSistem), valueColor: const Color(0xFF1598A3)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Colors.white10, height: 1),
              ),
              _rincianRow('Setor Aktual', widget.fmt.format(widget.item.setoranAktual)),
              _rincianRow('Selisih', widget.fmt.format(selisih)),
              if (widget.item.catatan != null && widget.item.catatan!.trim().isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Catatan Selisih:',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.item.catatan!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _formatDisplayDate(String? hari, String? tanggal) {
    if (hari != null && tanggal != null) return '$hari, $tanggal';
    return tanggal ?? '-';
  }

  Widget _breakdownItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _rincianRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final double? parsed = double.tryParse(cleanText);
    if (parsed == null) {
      return oldValue;
    }

    final String reversed = cleanText.split('').reversed.join('');
    final List<String> chunks = [];
    for (int i = 0; i < reversed.length; i += 3) {
      chunks.add(reversed.substring(i, i + 3 < reversed.length ? i + 3 : reversed.length));
    }
    final String formatted = chunks.join('.').split('').reversed.join('');

    int selectionIndex = newValue.selection.end;
    int digitsBeforeCursor = 0;
    for (int i = 0; i < selectionIndex && i < newValue.text.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(newValue.text[i])) {
        digitsBeforeCursor++;
      }
    }

    int newSelectionIndex = 0;
    int digitCount = 0;
    while (digitCount < digitsBeforeCursor && newSelectionIndex < formatted.length) {
      if (RegExp(r'[0-9]').hasMatch(formatted[newSelectionIndex])) {
        digitCount++;
      }
      newSelectionIndex++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}

String _formatRibuan(String s) {
  final clean = s.replaceAll(RegExp(r'[^0-9]'), '');
  if (clean.isEmpty) return '';
  final reversed = clean.split('').reversed.join('');
  final List<String> chunks = [];
  for (int i = 0; i < reversed.length; i += 3) {
    chunks.add(reversed.substring(i, i + 3 < reversed.length ? i + 3 : reversed.length));
  }
  return chunks.join('.').split('').reversed.join('');
}
