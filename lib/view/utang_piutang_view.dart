import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/utang_piutang_model.dart';
import '../viewmodel/utang_piutang_viewmodel.dart';
import '../core/widgets/admin_only_widget.dart';

class UtangPiutangView extends StatefulWidget {
  const UtangPiutangView({super.key});

  @override
  State<UtangPiutangView> createState() => _UtangPiutangViewState();
}

class _UtangPiutangViewState extends State<UtangPiutangView> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UtangPiutangViewModel>().loadAll();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UtangPiutangViewModel>();
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
          'Utang Piutang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: Colors.white70),
            onPressed: () => context.read<UtangPiutangViewModel>().loadAll(),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFF1598A3),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Utang'),
            Tab(text: 'Piutang'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'utang_piutang_fab',
        backgroundColor: const Color(0xFF1598A3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () => _showFormDialog(context),
      ),
      body: Column(
        children: [
          // ── Stat Banner ──────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A4D54),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Utang',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fmt.format(vm.totalUtang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Belum Lunas: ${fmt.format(vm.totalBelumLunasUtang)}',
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.white12),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Piutang',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fmt.format(vm.totalPiutang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Belum Lunas: ${fmt.format(vm.totalBelumLunasPiutang)}',
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── List view tabs ───────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildList(context, vm, vm.list, fmt),
                _buildList(context, vm, vm.list.where((e) => e.tipe == 'utang').toList(), fmt),
                _buildList(context, vm, vm.list.where((e) => e.tipe == 'piutang').toList(), fmt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    UtangPiutangViewModel vm,
    List<UtangPiutangModel> items,
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
              onPressed: () => context.read<UtangPiutangViewModel>().loadAll(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.white30),
            SizedBox(height: 12),
            Text(
              'Belum ada data utang piutang',
              style: TextStyle(color: Colors.white38),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return _buildTile(context, vm, item, fmt);
      },
    );
  }

  Widget _buildTile(
    BuildContext context,
    UtangPiutangViewModel vm,
    UtangPiutangModel item,
    NumberFormat fmt,
  ) {
    final isUtang = item.tipe == 'utang' || item.tipe == 'supplier';
    final isLunas = item.status == 'lunas';
    final accentColor = isUtang ? const Color(0xFFEF4444) : const Color(0xFF22C55E);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isUtang ? 'UTANG' : 'PIUTANG',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLunas ? const Color(0xFF22C55E).withValues(alpha: 0.15) : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isLunas ? 'LUNAS' : 'BELUM LUNAS',
                  style: TextStyle(
                    color: isLunas ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              // Tombol EDIT - Admin & Operator bisa
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white54),
                onPressed: () => _showFormDialog(context, item: item),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              // Tombol DELETE - Hanya Admin
              DeleteOnlyWidget(
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                  onPressed: () => _confirmDelete(context, vm, item.id!),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.nama,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Dibuat oleh: ${item.createdBy ?? '-'}  •  ${item.createdAt ?? ''}',
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
          if (item.keterangan != null && item.keterangan!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.keterangan!,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _breakdownCol('Total Tagihan', fmt.format(item.totalTagihan)),
              _breakdownCol('DP', fmt.format(item.dp)),
              _breakdownCol('Sisa Pembayaran', fmt.format(item.sisaPembayaran), valueColor: accentColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _breakdownCol(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _showFormDialog(BuildContext context, {UtangPiutangModel? item}) async {
    final namaCtrl = TextEditingController(text: item?.nama);
    final totalTagihanCtrl = TextEditingController(
      text: item != null ? _formatRibuan(item.totalTagihan.toStringAsFixed(0)) : '',
    );
    final dpCtrl = TextEditingController(
      text: item != null ? _formatRibuan(item.dp.toStringAsFixed(0)) : '',
    );
    final keteranganCtrl = TextEditingController(text: item?.keterangan);

    String selectedTipe = (item?.tipe ?? 'utang').trim().toLowerCase();
    if (selectedTipe == 'customer' || selectedTipe == 'piutang') {
      selectedTipe = 'piutang';
    } else {
      selectedTipe = 'utang';
    }
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          double getSisa() {
            final t = double.tryParse(totalTagihanCtrl.text.replaceAll('.', '')) ?? 0;
            final d = double.tryParse(dpCtrl.text.replaceAll('.', '')) ?? 0;
            return (t - d) > 0 ? (t - d) : 0;
          }

          final fmtCur = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1C),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header ──────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item == null ? 'Tambah Utang Piutang' : 'Edit Utang Piutang',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 24),
                            onPressed: () => Navigator.pop(sheetCtx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Nama ────────────────────────────────────────────
                      _labeledField(
                        label: 'Nama',
                        child: TextFormField(
                          controller: namaCtrl,
                          style: _inputTextStyle,
                          cursorColor: const Color(0xFF1E1E1E),
                          decoration: _tealInputDecoration(),
                          validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Total Tagihan & DP ───────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _labeledField(
                              label: 'Total Tagihan',
                              child: TextFormField(
                                controller: totalTagihanCtrl,
                                style: _inputTextStyle,
                                cursorColor: const Color(0xFF1E1E1E),
                                keyboardType: TextInputType.number,
                                inputFormatters: [_ThousandsSeparatorFormatter()],
                                decoration: _tealInputDecoration(),
                                onChanged: (_) => setModalState(() {}),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Total wajib diisi';
                                  if (double.tryParse(v.replaceAll('.', '')) == null) return 'Angka tidak valid';
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _labeledField(
                              label: 'DP (Down Payment)',
                              child: TextFormField(
                                controller: dpCtrl,
                                style: _inputTextStyle,
                                cursorColor: const Color(0xFF1E1E1E),
                                keyboardType: TextInputType.number,
                                inputFormatters: [_ThousandsSeparatorFormatter()],
                                decoration: _tealInputDecoration(),
                                onChanged: (_) => setModalState(() {}),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Tipe Dropdown ────────────────────────────────────
                      _labeledField(
                        label: 'Tipe',
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedTipe,
                          dropdownColor: const Color(0xFF1C1C1C),
                          style: _inputTextStyle,
                          iconEnabledColor: const Color(0xFF1E1E1E),
                          decoration: _tealInputDecoration(),
                          selectedItemBuilder: (BuildContext context) {
                            return const [
                              Text('Utang', style: _inputTextStyle),
                              Text('Piutang', style: _inputTextStyle),
                            ];
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'utang',
                              child: Text('Utang', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                            ),
                            DropdownMenuItem(
                              value: 'piutang',
                              child: Text('Piutang', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedTipe = val);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Keterangan ───────────────────────────────────────
                      _labeledField(
                        label: 'Keterangan (opsional)',
                        child: TextFormField(
                          controller: keteranganCtrl,
                          style: _inputTextStyle,
                          cursorColor: const Color(0xFF1E1E1E),
                          maxLines: 2,
                          decoration: _tealInputDecoration(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Sisa & Status Summary ────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252A34),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF383F51), width: 1),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Sisa Pembayaran',
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                Text(
                                  fmtCur.format(getSisa()),
                                  style: const TextStyle(
                                    color: Color(0xFF1598A3),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Status Pembayaran',
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                Text(
                                  getSisa() <= 0 ? 'LUNAS' : 'BELUM LUNAS',
                                  style: TextStyle(
                                    color: getSisa() <= 0
                                        ? const Color(0xFF22C55E)
                                        : const Color(0xFFF59E0B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Simpan Button ─────────────────────────────────────
                      Consumer<UtangPiutangViewModel>(
                        builder: (_, vm, __) => SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: vm.isMutating
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate()) return;
                                    final sisa = getSisa();
                                    final model = UtangPiutangModel(
                                      id: item?.id,
                                      nama: namaCtrl.text.trim(),
                                      tipe: selectedTipe,
                                      totalTagihan: double.parse(
                                          totalTagihanCtrl.text.trim().replaceAll('.', '')),
                                      dp: double.tryParse(
                                              dpCtrl.text.trim().replaceAll('.', '')) ??
                                          0.0,
                                      sisaPembayaran: sisa,
                                      keterangan: keteranganCtrl.text.trim().isEmpty
                                          ? null
                                          : keteranganCtrl.text.trim(),
                                      status: sisa <= 0 ? 'lunas' : 'belum_lunas',
                                    );

                                    final success = item == null
                                        ? await vm.create(model)
                                        : await vm.update(item.id!, model);

                                    if (context.mounted) {
                                      Navigator.pop(sheetCtx);
                                      if (!success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content:
                                                Text(vm.errorMessage ?? 'Gagal menyimpan'),
                                            backgroundColor: const Color(0xFFEF4444),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1598A3),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: vm.isMutating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, UtangPiutangViewModel vm, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Hapus Data', style: TextStyle(color: Colors.white)),
        content: const Text('Apakah Anda yakin ingin menghapus data utang piutang ini?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await vm.delete(id);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage ?? 'Gagal menghapus'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  /// Label above a child widget (matches pemasukan/pengeluaran style)
  Widget _labeledField({required String label, required Widget child}) {
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
        child,
      ],
    );
  }

  static const TextStyle _inputTextStyle = TextStyle(
    color: Color(0xFF1E1E1E),
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  InputDecoration _tealInputDecoration() {
    return InputDecoration(
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
    );
  }
}

// ── Thousand separator formatter ─────────────────────────────────────────────

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

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    final clean = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) {
      return const TextEditingValue(
          text: '', selection: TextSelection.collapsed(offset: 0));
    }
    if (double.tryParse(clean) == null) return oldValue;

    final reversed = clean.split('').reversed.join('');
    final chunks = <String>[];
    for (int i = 0; i < reversed.length; i += 3) {
      chunks.add(reversed.substring(
          i, i + 3 < reversed.length ? i + 3 : reversed.length));
    }
    final formatted = chunks.join('.').split('').reversed.join('');

    int digitsBeforeCursor = 0;
    final selEnd = newValue.selection.end.clamp(0, newValue.text.length);
    for (int i = 0; i < selEnd; i++) {
      if (RegExp(r'[0-9]').hasMatch(newValue.text[i])) digitsBeforeCursor++;
    }

    int newSel = 0, digits = 0;
    while (digits < digitsBeforeCursor && newSel < formatted.length) {
      if (RegExp(r'[0-9]').hasMatch(formatted[newSel])) digits++;
      newSel++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newSel),
    );
  }
}
