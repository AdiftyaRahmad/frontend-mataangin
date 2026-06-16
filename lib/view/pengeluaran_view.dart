import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/pengeluaran_model.dart';
import '../viewmodel/pengeluaran_viewmodel.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../core/widgets/admin_only_widget.dart';

class PengeluaranView extends StatelessWidget {
  const PengeluaranView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PengeluaranViewModel>();
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
        title: const Text(
          'Pengeluaran',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white, size: 28),
            onPressed: () => context.read<PengeluaranViewModel>().loadAll(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 8),
        child: SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            heroTag: 'pengeluaran_fab',
            backgroundColor: const Color(0xFFB32626),
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
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFB32626),
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
                  child: const Icon(Icons.trending_down,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pengeluaran',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fmt.format(vm.totalPengeluaran),
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
          Expanded(child: _buildList(context, vm, fmt)),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    PengeluaranViewModel vm,
    NumberFormat fmt,
  ) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFEF4444)),
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
              onPressed: () => context.read<PengeluaranViewModel>().loadAll(),
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
              'Belum ada data pengeluaran',
              style: TextStyle(color: Colors.white38),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 88, left: 16, right: 16),
      itemCount: vm.list.length,
      itemBuilder: (_, i) {
        final item = vm.list[i];
        return _PengeluaranCard(
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
    PengeluaranModel? item,
  }) async {
    final namaBarangCtrl = TextEditingController(text: item?.namaBarang);
    final cashCtrl = TextEditingController(
      text: item != null ? _formatRibuan(item.cash.toStringAsFixed(0)) : '0',
    );
    final transferCtrl = TextEditingController(
      text: item != null ? _formatRibuan(item.transfer.toStringAsFixed(0)) : '0',
    );
    final qrisCtrl = TextEditingController(
      text: item != null ? _formatRibuan(item.qris.toStringAsFixed(0)) : '0',
    );
    final keteranganCtrl = TextEditingController(text: item?.keterangan);
    final tanggalCtrl = TextEditingController(
      text: item?.tanggal ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
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

    final categories = [
      'Gaji & Uang Makan',
      'Operasional Toko',
      'Perawatan & Service',
      'Inventaris',
      'Pemasaran & Penjualan',
      'Pengeluaran Lainnya',
    ];

    String selectedKategori = item?.kategori ?? 'Gaji & Uang Makan';
    if (!categories.contains(selectedKategori)) {
      selectedKategori = 'Gaji & Uang Makan';
    }
    int selectedShift = item?.shift ?? 1;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Form(
            key: formKey,
            child: StatefulBuilder(
              builder: (context, setModalState) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item == null ? 'Tambah Pengeluaran' : 'Edit Pengeluaran',
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
                    const SizedBox(height: 8),
                    // Date row
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: sheetCtx,
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
                    const SizedBox(height: 14),

                    // ── Shift Dropdown ──────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Shift',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          initialValue: selectedShift,
                          dropdownColor: const Color(0xFF1C1C1C),
                          style: const TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          iconEnabledColor: const Color(0xFF1E1E1E),
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
                          ),
                          selectedItemBuilder: (BuildContext context) {
                            return [1, 2].map((s) {
                              return Text(
                                'Shift $s',
                                style: const TextStyle(
                                  color: Color(0xFF1E1E1E),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                          items: [1, 2].map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(
                                'Shift $s',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedShift = val);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _formField(
                      namaBarangCtrl,
                      'Nama Barang',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Nama barang wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    
                    // ── Kategori Dropdown ──────────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Kategori',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: selectedKategori,
                          dropdownColor: const Color(0xFF1C1C1C),
                          style: const TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          iconEnabledColor: const Color(0xFF1E1E1E),
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
                          selectedItemBuilder: (BuildContext context) {
                            return categories.map((cat) {
                              return Text(
                                cat,
                                style: const TextStyle(
                                  color: Color(0xFF1E1E1E),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                          items: categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(
                                cat,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedKategori = val);
                            }
                          },
                          validator: (v) => v == null || v.isEmpty ? 'Kategori wajib dipilih' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Rincian Pengeluaran ──────────────────────────────
                    const Text(
                      'Rincian Pengeluaran',
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
                          child: _formField(
                            cashCtrl,
                            'Cash',
                            keyboardType: TextInputType.number,
                            inputFormatters: [ThousandsSeparatorInputFormatter()],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _formField(
                            transferCtrl,
                            'Transfer',
                            keyboardType: TextInputType.number,
                            inputFormatters: [ThousandsSeparatorInputFormatter()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _formField(
                      qrisCtrl,
                      'QRIS',
                      keyboardType: TextInputType.number,
                      inputFormatters: [ThousandsSeparatorInputFormatter()],
                    ),
                    const SizedBox(height: 14),

                    _formField(keteranganCtrl, 'Keterangan (opsional)'),
                    const SizedBox(height: 24),

                    Consumer<PengeluaranViewModel>(
                      builder: (ctx, vm, _) => ElevatedButton(
                        onPressed: vm.isMutating
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                final pengeluaranVm = ctx.read<PengeluaranViewModel>();
                                final double c = double.tryParse(cashCtrl.text.replaceAll('.', '')) ?? 0.0;
                                final double t = double.tryParse(transferCtrl.text.replaceAll('.', '')) ?? 0.0;
                                final double q = double.tryParse(qrisCtrl.text.replaceAll('.', '')) ?? 0.0;
                                final double total = c + t + q;

                                final data = PengeluaranModel(
                                  id: item?.id,
                                  namaBarang: namaBarangCtrl.text.trim(),
                                  nominal: total,
                                  cash: c,
                                  transfer: t,
                                  qris: q,
                                  kategori: selectedKategori,
                                  keterangan: keteranganCtrl.text.trim().isEmpty
                                      ? null
                                      : keteranganCtrl.text.trim(),
                                  tanggal: tanggalCtrl.text,
                                  shift: selectedShift,
                                );
                                final success = item == null
                                    ? await pengeluaranVm.create(data)
                                    : await pengeluaranVm.update(item.id!, data);
                                if (sheetCtx.mounted) {
                                  Navigator.pop(sheetCtx);
                                  if (success) {
                                    sheetCtx.read<DashboardViewModel>().loadDashboard();
                                  } else {
                                    ScaffoldMessenger.of(sheetCtx).showSnackBar(
                                      SnackBar(
                                        content: Text(vm.errorMessage ?? 'Gagal menyimpan'),
                                        backgroundColor: const Color(0xFFEF4444),
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
                                item == null ? 'Simpan' : 'Perbarui',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Hapus Pengeluaran',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus data ini?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
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
      final success = await context.read<PengeluaranViewModel>().delete(id);
      if (success && context.mounted) {
        context.read<DashboardViewModel>().loadDashboard();
      }
    }
  }


}

Widget _formField(
  TextEditingController ctrl,
  String label, {
  TextInputType? keyboardType,
  String? Function(String?)? validator,
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

class _PengeluaranCard extends StatelessWidget {
  final PengeluaranModel item;
  final NumberFormat fmt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PengeluaranCard({
    required this.item,
    required this.fmt,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2D1F21),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_downward_rounded,
              color: Color(0xFFEF4444),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaBarang,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.kategori != null && item.kategori!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1598A3).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF1598A3).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      item.kategori!,
                      style: const TextStyle(
                        color: Color(0xFF1598A3),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  'TGL: ${item.tanggal} • Dibuat oleh: ${item.createdBy ?? '-'}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Shift ${item.shift}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.keterangan != null && item.keterangan!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.keterangan!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '- ${fmt.format(item.nominal)}',
                style: const TextStyle(
                  color: Color(0xFFEF5350),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              if (item.cash > 0)
                Text('Cash: ${fmt.format(item.cash)}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
              if (item.transfer > 0)
                Text('TF: ${fmt.format(item.transfer)}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
              if (item.qris > 0)
                Text('QRIS: ${fmt.format(item.qris)}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Tombol EDIT - Admin & Operator bisa
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Colors.white54,
                    ),
                    onPressed: onEdit,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 4),
                  // Tombol DELETE - Hanya Admin
                  DeleteOnlyWidget(
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Color(0xFFEF4444),
                      ),
                      onPressed: onDelete,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ),
                ],
              ),
            ],
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
