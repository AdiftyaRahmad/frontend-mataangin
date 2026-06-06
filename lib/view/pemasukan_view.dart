import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/pemasukan_model.dart';
import '../viewmodel/pemasukan_viewmodel.dart';
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
    final dendaCtrl = TextEditingController(
        text: item != null ? _formatRibuan(item.denda.toStringAsFixed(0)) : '');
    final kerusakanCtrl = TextEditingController(
        text: item != null ? _formatRibuan(item.kerusakan.toStringAsFixed(0)) : '');
    final dpCtrl = TextEditingController(
        text: item != null ? _formatRibuan(item.dp.toStringAsFixed(0)) : '');
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

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          double getSum() {
            final c = double.tryParse(cashCtrl.text.replaceAll('.', '')) ?? 0;
            final t = double.tryParse(transferCtrl.text.replaceAll('.', '')) ?? 0;
            final q = double.tryParse(qrisCtrl.text.replaceAll('.', '')) ?? 0;
            final d = double.tryParse(dendaCtrl.text.replaceAll('.', '')) ?? 0;
            final k = double.tryParse(kerusakanCtrl.text.replaceAll('.', '')) ?? 0;
            final dp = double.tryParse(dpCtrl.text.replaceAll('.', '')) ?? 0;
            return c + t + q + d + k + dp;
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
                            const SizedBox(height: 24),
                            const Text(
                              'Penerimaan Lainnya',
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
                                    label: 'Denda',
                                    ctrl: dendaCtrl,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setModalState(() {}),
                                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _labeledFormField(
                                    label: 'Kerusakan',
                                    ctrl: kerusakanCtrl,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setModalState(() {}),
                                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _labeledFormField(
                              label: 'DP (Down Payment)',
                              ctrl: dpCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setModalState(() {}),
                              inputFormatters: [ThousandsSeparatorInputFormatter()],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF252A34),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF383F51),
                                  width: 1,
                                ),
                              ),
                              child: Row(
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                            onPressed: vm.isMutating
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
                                      denda: double.tryParse(dendaCtrl.text.replaceAll('.', '')) ?? 0,
                                      kerusakan:
                                          double.tryParse(kerusakanCtrl.text.replaceAll('.', '')) ?? 0,
                                      dp: double.tryParse(dpCtrl.text.replaceAll('.', '')) ?? 0,
                                      totalPemasukan: getSum(),
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

class _PemasukanCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
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
                      Text(
                        _formatDisplayDate(item.hari, item.tanggal),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Dibuat oleh: ${item.createdBy ?? '-'}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      fmt.format(item.totalPemasukan),
                      style: const TextStyle(
                        color: Color(0xFF1598A3),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: onEdit,
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: Colors.white60,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        DeleteOnlyWidget(
                          child: InkWell(
                            onTap: onDelete,
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                _breakdownItem('Cash', fmt.format(item.cash)),
                _breakdownItem('Transfer', fmt.format(item.transfer)),
                _breakdownItem('QRIS', fmt.format(item.qris)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _breakdownItem('Denda', fmt.format(item.denda)),
                _breakdownItem('Kerusakan', fmt.format(item.kerusakan)),
                _breakdownItem('DP', fmt.format(item.dp)),
              ],
            ),
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
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
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
