import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/pemasukan_model.dart';
import '../viewmodel/pemasukan_viewmodel.dart';

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
        backgroundColor: const Color(0xFF1598A3),
        elevation: 0,
        title: const Text(
          'Pemasukan',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: Colors.white),
            onPressed: () => context.read<PemasukanViewModel>().loadAll(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'pemasukan_fab',
        backgroundColor: const Color(0xFF1598A3),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showFormDialog(context),
      ),
      body: Column(
        children: [
          // ── Total Banner ────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A4D54),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.trending_up,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pemasukan',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        fmt.format(vm.totalPemasukan),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    final cashCtrl =
        TextEditingController(text: item?.cash.toStringAsFixed(0) ?? '0');
    final transferCtrl = TextEditingController(
        text: item?.transfer.toStringAsFixed(0) ?? '0');
    final qrisCtrl =
        TextEditingController(text: item?.qris.toStringAsFixed(0) ?? '0');
    final dendaCtrl =
        TextEditingController(text: item?.denda.toStringAsFixed(0) ?? '0');
    final kerusakanCtrl = TextEditingController(
        text: item?.kerusakan.toStringAsFixed(0) ?? '0');
    final dpCtrl =
        TextEditingController(text: item?.dp.toStringAsFixed(0) ?? '0');
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
            final c = double.tryParse(cashCtrl.text) ?? 0;
            final t = double.tryParse(transferCtrl.text) ?? 0;
            final q = double.tryParse(qrisCtrl.text) ?? 0;
            final d = double.tryParse(dendaCtrl.text) ?? 0;
            final k = double.tryParse(kerusakanCtrl.text) ?? 0;
            final dp = double.tryParse(dpCtrl.text) ?? 0;
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
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF111C2D),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item == null ? 'Tambah Pemasukan' : 'Edit Pemasukan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54),
                          onPressed: () => Navigator.pop(sheetCtx),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: tanggalCtrl,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14),
                                    decoration:
                                        _inputDecoration('Tanggal (YYYY-MM-DD)'),
                                    readOnly: true,
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
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1598A3)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFF1598A3)
                                            .withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    currentHari,
                                    style: const TextStyle(
                                        color: Color(0xFF1598A3),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('Rincian Pembayaran',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _formField(cashCtrl, 'Cash',
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => setModalState(() {})),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _formField(transferCtrl, 'Transfer',
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => setModalState(() {})),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _formField(qrisCtrl, 'QRIS',
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setModalState(() {})),
                            const SizedBox(height: 16),
                            const Text('Penerimaan Lainnya',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _formField(dendaCtrl, 'Denda',
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => setModalState(() {})),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _formField(
                                      kerusakanCtrl, 'Kerusakan',
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => setModalState(() {})),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _formField(dpCtrl, 'DP (Down Payment)',
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setModalState(() {})),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1598A3)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0xFF1598A3)
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Pemasukan',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500),
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
                    Consumer<PemasukanViewModel>(
                      builder: (ctx, vm, _) => ElevatedButton(
                        onPressed: vm.isMutating
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                final data = PemasukanModel(
                                  id: item?.id,
                                  tanggal: tanggalCtrl.text,
                                  hari: currentHari,
                                  cash: double.tryParse(cashCtrl.text) ?? 0,
                                  transfer:
                                      double.tryParse(transferCtrl.text) ?? 0,
                                  qris: double.tryParse(qrisCtrl.text) ?? 0,
                                  denda: double.tryParse(dendaCtrl.text) ?? 0,
                                  kerusakan:
                                      double.tryParse(kerusakanCtrl.text) ?? 0,
                                  dp: double.tryParse(dpCtrl.text) ?? 0,
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
                                  if (!success) {
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
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
                                  fontWeight: FontWeight.w600,
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
      context.read<PemasukanViewModel>().delete(id);
    }
  }
}

TextFormField _formField(
  TextEditingController ctrl,
  String label, {
  TextInputType? keyboardType,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
}) {
  return TextFormField(
    controller: ctrl,
    keyboardType: keyboardType,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    validator: validator,
    onChanged: onChanged,
    decoration: _inputDecoration(label),
  );
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF1598A3), width: 1.5),
    ),
    errorStyle: const TextStyle(color: Color(0xFFFCA5A5)),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1598A3).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.trending_up,
                      color: Color(0xFF1598A3), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDisplayDate(item.hari, item.tanggal),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Dibuat oleh: ${item.createdBy ?? '-'}',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11),
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
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: onEdit,
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.edit_outlined,
                                size: 16, color: Colors.white38),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: onDelete,
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.delete_outline,
                                size: 16, color: Color(0xFFEF4444)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Divider ────────────────────────────────────────────────────
          const Divider(height: 1, color: Color(0xFF1E2D40)),

          // ── Breakdown grid ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _breakdownItem('Cash', fmt.format(item.cash)),
                    _breakdownItem('Transfer', fmt.format(item.transfer)),
                    _breakdownItem('QRIS', fmt.format(item.qris)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _breakdownItem('Denda', fmt.format(item.denda)),
                    _breakdownItem('Kerusakan', fmt.format(item.kerusakan)),
                    _breakdownItem('DP', fmt.format(item.dp)),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          Text(label,
              style:
                  const TextStyle(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
