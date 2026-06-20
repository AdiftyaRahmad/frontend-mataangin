import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/laporan_model.dart';
import '../viewmodel/laporan_viewmodel.dart';
import '../core/widgets/admin_only_widget.dart';

class LaporanView extends StatefulWidget {
  const LaporanView({super.key});

  @override
  State<LaporanView> createState() => _LaporanViewState();
}

class _LaporanViewState extends State<LaporanView> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // Selected date for Daily Report
  DateTime _selectedDate = DateTime.now();

  // Selected month and year for Monthly Report
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  final List<int> _years = List.generate(10, (i) => DateTime.now().year - 5 + i);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHarian();
      _loadBulanan();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _loadHarian() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    context.read<LaporanViewModel>().loadHarian(dateStr);
  }

  void _loadBulanan() {
    final monthStr = _selectedMonth.toString().padLeft(2, '0');
    final yearStr = _selectedYear.toString();
    context.read<LaporanViewModel>().loadBulanan(monthStr, yearStr);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LaporanViewModel>();
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
          'Laporan Keuangan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: Colors.white70),
            tooltip: 'Refresh Laporan',
            onPressed: () {
              _loadHarian();
              _loadBulanan();
            },
          ),
          AdminOnlyWidget(
            child: IconButton(
              icon: vm.isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined, color: Colors.white70),
              tooltip: 'Export PDF',
              onPressed: vm.isExporting
                  ? null
                  : () async {
                      // Determine which tab is active
                      final isHarianTab = _tabCtrl.index == 0;
                      final success = await context.read<LaporanViewModel>().exportPdf(
                        isHarian: isHarianTab,
                        selectedDate: _selectedDate,
                        selectedMonth: _selectedMonth,
                        selectedYear: _selectedYear,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'PDF berhasil diunduh!'
                                  : (vm.exportError ?? 'Gagal mengunduh PDF'),
                            ),
                            backgroundColor: success ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                          ),
                        );
                      }
                    },
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFF1598A3),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Harian'),
            Tab(text: 'Bulanan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildHarianTab(vm, fmt),
          _buildBulananTab(vm, fmt),
        ],
      ),
    );
  }

  Widget _buildHarianTab(LaporanViewModel vm, NumberFormat fmt) {
    return Column(
      children: [
        // ── Date Selector ──────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: const Color(0xFF1E1E1E),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Colors.white54, size: 20),
              const SizedBox(width: 12),
              Text(
                DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                    _loadHarian();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1598A3),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Pilih Tanggal', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ),

        // ── Summary Cards ─────────────────────────────────────────────────
        if (vm.isHarianLoading)
          const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF1598A3))))
        else if (vm.harianState == ViewState.error)
          Expanded(child: _buildErrorWidget(vm.harianError ?? 'Gagal memuat', _loadHarian))
        else ...[
          _buildSummaryCards(vm.laporanHarian, fmt),
          Expanded(
            child: _buildTransactionList(
              vm.laporanHarian.transaksi,
              fmt,
              () async {
                _loadHarian();
              },
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildBulananTab(LaporanViewModel vm, NumberFormat fmt) {
    return Column(
      children: [
        // ── Month/Year Selector ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: const Color(0xFF1E1E1E),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedMonth,
                  dropdownColor: const Color(0xFF1E1E1E),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _dropdownDecoration('Bulan'),
                  items: List.generate(12, (i) {
                    return DropdownMenuItem(
                      value: i + 1,
                      child: Text(_months[i]),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMonth = val;
                      });
                      _loadBulanan();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedYear,
                  dropdownColor: const Color(0xFF1E1E1E),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _dropdownDecoration('Tahun'),
                  items: _years.map((y) {
                    return DropdownMenuItem(
                      value: y,
                      child: Text(y.toString()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedYear = val;
                      });
                      _loadBulanan();
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // ── Summary Cards ─────────────────────────────────────────────────
        if (vm.isBulananLoading)
          const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF1598A3))))
        else if (vm.bulananState == ViewState.error)
          Expanded(child: _buildErrorWidget(vm.bulananError ?? 'Gagal memuat', _loadBulanan))
        else ...[
          _buildSummaryCards(vm.laporanBulanan, fmt),
          Expanded(
            child: _buildTransactionList(
              vm.laporanBulanan.transaksi,
              fmt,
              () async {
                _loadBulanan();
              },
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildSummaryCards(LaporanModel laporan, NumberFormat fmt) {

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A4D54),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Pemasukan', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(
                      fmt.format(laporan.totalPemasukan),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: Colors.white12),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Pengeluaran', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(
                      fmt.format(laporan.totalPengeluaran),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Selisih / Saldo', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              Text(
                fmt.format(laporan.saldo),
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<LaporanItem> items, NumberFormat fmt, Future<void> Function() onRefresh) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: const Color(0xFF1598A3),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: Colors.white30),
                    SizedBox(height: 12),
                    Text('Tidak ada riwayat transaksi', style: TextStyle(color: Colors.white38)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF1598A3),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          final isIncome = item.jenis == 'pemasukan';
          final color = isIncome ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isIncome ? Icons.trending_up : Icons.trending_down,
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.judul,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.tanggal,
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${isIncome ? '+' : '-'} ${fmt.format(item.jumlah)}',
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String message, VoidCallback onRetry) {
    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      color: const Color(0xFF1598A3),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 44),
                  const SizedBox(height: 12),
                  Text(message, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1598A3), width: 1.5),
      ),
    );
  }
}
