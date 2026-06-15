import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../viewmodel/auth_viewmodel.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../viewmodel/pemasukan_viewmodel.dart';
import '../viewmodel/pengeluaran_viewmodel.dart';
import '../viewmodel/utang_piutang_viewmodel.dart';
import 'login_view.dart';
import 'pemasukan_view.dart';
import 'pengeluaran_view.dart';
import 'utang_piutang_view.dart';
import 'laporan_view.dart';

// ─── Color Palette ─────────────────────────────────────────────────────────────
const _kBg = Color(0xFF1598A3);
const _kCard = Color(0xFF1E1E1E);
const _kTeal = Color(0xFF1598A3);
const _kGreen = Color(0xFF22C55E);
const _kRed = Color(0xFFEF4444);
const _kTextPrim = Colors.white;
const _kTextSub = Color(0xFF9CA3AF);

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboard();
      context.read<PemasukanViewModel>().loadAll();
      context.read<PengeluaranViewModel>().loadAll();
      context.read<UtangPiutangViewModel>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          PemasukanView(),
          PengeluaranView(),
          UtangPiutangView(),
          LaporanView(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ─── Bottom Navigation ─────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(Icons.grid_view_rounded, Icons.grid_view_rounded, 'Dashboard'),
      _NavItem(
        Icons.trending_up_rounded,
        Icons.trending_up_rounded,
        'Pemasukan',
      ),
      _NavItem(
        Icons.trending_down_rounded,
        Icons.trending_down_rounded,
        'Pengeluaran',
      ),
      _NavItem(Icons.people_alt_outlined, Icons.people_alt_rounded, 'Utang'),
      _NavItem(Icons.bar_chart_rounded, Icons.bar_chart_rounded, 'Laporan'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A), width: 1)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == currentIndex;
          final item = items[i];
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selected ? item.activeIcon : item.icon,
                    color: selected ? _kTeal : _kTextSub,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      color: selected ? _kTeal : _kTextSub,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

// ─── Home Tab ──────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final dashVm = context.watch<DashboardViewModel>();
    final pemasukanVm = context.watch<PemasukanViewModel>();
    final pengeluaranVm = context.watch<PengeluaranViewModel>();

    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final List<_TxData> allTx = [
      ...pemasukanVm.list.map(
        (e) => _TxData(
          judul: 'Pemasukan - ${e.hari}',
          jumlah: e.totalPemasukan,
          tanggal: e.tanggal,
          isIncome: true,
        ),
      ),
      ...pengeluaranVm.list.map(
        (e) => _TxData(
          judul: e.namaBarang,
          jumlah: e.nominal,
          tanggal: e.tanggal,
          isIncome: false,
        ),
      ),
    ];

    allTx.sort((a, b) => (b.tanggal ?? '').compareTo(a.tanggal ?? ''));

    final recentTx = allTx.take(5).toList();

    return Column(
      children: [
        // ── Teal Header ─────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: _kTeal),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 8,
            bottom: 20,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${authVm.user?.name ?? 'Pengguna'} 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Selamat Datang!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () async {
                  await context.read<AuthViewModel>().logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginView()),
                      (r) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),

        // ── Scrollable Body ──────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Saldo Card ───────────────────────────────────────────────
                if (dashVm.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: CircularProgressIndicator(color: _kTeal),
                    ),
                  )
                else if (dashVm.state == ViewState.error)
                  _ErrorCard(message: dashVm.errorMessage ?? 'Gagal memuat')
                else ...[
                  _SaldoCard(
                    saldo: dashVm.dashboard.saldo,
                    pemasukan: dashVm.dashboard.totalPemasukan,
                    pengeluaran: dashVm.dashboard.totalPengeluaran,
                    fmt: fmt,
                  ),
                  const SizedBox(height: 16),
                  _ExpenseBreakdownCard(
                    pengeluaranList: pengeluaranVm.list,
                    totalPengeluaran: dashVm.dashboard.totalPengeluaran,
                    fmt: fmt,
                  ),
                ],

                const SizedBox(height: 28),

                // ── Transaksi Terakhir Header ─────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaksi Terakhir',
                      style: TextStyle(
                        color: _kTextPrim,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: _kTeal,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Transaction List ──────────────────────────────────────
                if (recentTx.isEmpty)
                  const _EmptyState(message: 'Belum ada transaksi')
                else
                  ...recentTx.map(
                    (tx) => _TransactionTile(
                      judul: tx.judul,
                      jumlah: tx.jumlah,
                      tanggal: tx.tanggal,
                      isIncome: tx.isIncome,
                      fmt: fmt,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Saldo Card ────────────────────────────────────────────────────────────────

class _SaldoCard extends StatelessWidget {
  final double saldo;
  final double pemasukan;
  final double pengeluaran;
  final NumberFormat fmt;

  const _SaldoCard({
    required this.saldo,
    required this.pemasukan,
    required this.pengeluaran,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF044B52),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Saldo',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fmt.format(saldo),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'PEMASUKAN',
                  value: fmt.format(pemasukan),
                  icon: Icons.arrow_upward_rounded,
                  accentColor: _kGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: 'PENGELUARAN',
                  value: fmt.format(pengeluaran),
                  icon: Icons.arrow_downward_rounded,
                  accentColor: _kRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Mini Stat ─────────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF063A40).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Transaction Tile ──────────────────────────────────────────────────────────

class _TxData {
  final String judul;
  final double jumlah;
  final String? tanggal;
  final bool isIncome;
  const _TxData({
    required this.judul,
    required this.jumlah,
    this.tanggal,
    required this.isIncome,
  });
}

class _TransactionTile extends StatelessWidget {
  final String judul;
  final double jumlah;
  final String? tanggal;
  final bool isIncome;
  final NumberFormat fmt;

  const _TransactionTile({
    required this.judul,
    required this.jumlah,
    this.tanggal,
    required this.isIncome,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? _kGreen : _kRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // ── Icon ──────────────────────────────────────────────────────────
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome
                  ? Icons.add_circle_outline_rounded
                  : Icons.remove_circle_outline_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // ── Title & Date ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    color: _kTextPrim,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (tanggal != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    tanggal!,
                    style: const TextStyle(
                      color: _kTextSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Amount ───────────────────────────────────────────────────────
          Text(
            '${isIncome ? '+' : '-'} ${fmt.format(jumlah)}',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error Card ────────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: _kRed),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFCA5A5)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 52,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: _kTextSub, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Expense Breakdown Card ──────────────────────────────────────────────────

class _ExpenseBreakdownCard extends StatelessWidget {
  final List<dynamic> pengeluaranList; // List<PengeluaranModel>
  final double totalPengeluaran;
  final NumberFormat fmt;

  const _ExpenseBreakdownCard({
    required this.pengeluaranList,
    required this.totalPengeluaran,
    required this.fmt,
  });

  String _mapCategory(String? raw) {
    final cat = raw?.toLowerCase() ?? '';
    if (cat.contains('gaji')) {
      return 'Gaji & Uang Makan';
    } else if (cat.contains('operasional') || cat.contains('sewa') || cat.contains('utilitas')) {
      return 'Operasional Toko';
    } else if (cat.contains('service') || cat.contains('perawatan')) {
      return 'Perawatan & Service';
    } else if (cat.contains('inventaris') || cat.contains('alat')) {
      return 'Inventaris';
    } else if (cat.contains('pemasaran') || cat.contains('penjualan') || cat.contains('bahan') || cat.contains('stok')) {
      return 'Pemasaran & Penjualan';
    } else {
      return 'Pengeluaran Lainnya';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Categories template
    final categoriesData = {
      'Gaji & Uang Makan': {'color': const Color(0xFF14B8A6), 'amount': 0.0},
      'Operasional Toko': {'color': const Color(0xFF3B82F6), 'amount': 0.0},
      'Perawatan & Service': {'color': const Color(0xFF6366F1), 'amount': 0.0},
      'Inventaris': {'color': const Color(0xFFEC4899), 'amount': 0.0},
      'Pemasaran & Penjualan': {'color': const Color(0xFFF59E0B), 'amount': 0.0},
      'Pengeluaran Lainnya': {'color': const Color(0xFFEAB308), 'amount': 0.0},
    };

    // Calculate dynamic values
    double calculatedTotal = 0.0;
    for (final item in pengeluaranList) {
      final mapped = _mapCategory(item.kategori);
      if (categoriesData.containsKey(mapped)) {
        categoriesData[mapped]!['amount'] = (categoriesData[mapped]!['amount'] as double) + item.nominal;
        calculatedTotal += item.nominal;
      }
    }

    final List<_PieSliceData> slices = [];
    final bool useMock = calculatedTotal == 0.0;

    categoriesData.forEach((label, data) {
      final double amount = useMock ? 100000.0 : (data['amount'] as double);
      final double totalForPct = useMock ? 600000.0 : calculatedTotal;
      final double percentage = totalForPct > 0 ? (amount / totalForPct) : 0.0;
      slices.add(_PieSliceData(
        label: label,
        value: useMock ? 100000.0 : (data['amount'] as double),
        percentage: percentage,
        color: data['color'] as Color,
      ));
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: constraints.maxWidth,
                  height: 300,
                  child: CustomPaint(
                    painter: _PieChartPainter(slices: slices),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Categories list below the chart
          ...slices.map((slice) {
            final double displayAmount = slice.value;
            final int displayPct = (slice.percentage * 100).round();
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: slice.color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$displayPct%',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      slice.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    fmt.format(displayAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PieSliceData {
  final String label;
  final double value;
  final double percentage;
  final Color color;

  _PieSliceData({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  });
}

/// Helper class to hold label positioning data for anti-collision logic.
class _LabelInfo {
  final int index;
  final double middleAngle;
  final bool isRight;
  final double extensionX;
  final double extensionY;
  double anchorY;
  final TextPainter painter;
  final Color color;

  _LabelInfo({
    required this.index,
    required this.middleAngle,
    required this.isRight,
    required this.extensionX,
    required this.extensionY,
    required this.anchorY,
    required this.painter,
    required this.color,
  });
}

class _PieChartPainter extends CustomPainter {
  final List<_PieSliceData> slices;

  _PieChartPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const piVal = 3.141592653589793;
    final radius = min(size.width * 0.20, size.height * 0.30);
    const extOffset = 12.0;
    const labelGap = 18.0;
    const edgeMargin = 4.0;

    // Label column X positions
    final rightColX = center.dx + radius + labelGap;
    final leftColX = center.dx - radius - labelGap;
    final rightMaxWidth = size.width - rightColX - edgeMargin;
    final leftMaxWidth = leftColX - edgeMargin;

    // ── Phase 1: Draw pie slices ──────────────────────────────────────
    double startAngle = -piVal / 2;
    final List<List<double>> angles = [];

    for (final slice in slices) {
      final sweep = slice.percentage * 2 * piVal;
      angles.add([startAngle, sweep]);

      if (sweep > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle, sweep, true,
          Paint()..color = slice.color..style = PaintingStyle.fill,
        );
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle, sweep, true,
          Paint()
            ..color = _kCard
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
      }
      startAngle += sweep;
    }

    // ── Phase 2: Build label info ─────────────────────────────────────
    final List<_LabelInfo> rightLabels = [];
    final List<_LabelInfo> leftLabels = [];

    for (int i = 0; i < slices.length; i++) {
      final sweep = angles[i][1];
      if (sweep <= 0) continue;

      final mid = angles[i][0] + sweep / 2;
      final dx = cos(mid);
      final dy = sin(mid);
      final isRight = dx >= 0;

      final extX = center.dx + dx * (radius + extOffset);
      final extY = center.dy + dy * (radius + extOffset);
      final pct = (slices[i].percentage * 100).round();

      final span = TextSpan(
        children: [
          TextSpan(
            text: '${slices[i].label}\n',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          TextSpan(
            text: '$pct%',
            style: TextStyle(
              color: slices[i].color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ],
      );

      final tp = TextPainter(
        text: span,
        textDirection: ui.TextDirection.ltr,
        textAlign: isRight ? TextAlign.left : TextAlign.right,
      );
      tp.layout(maxWidth: max(isRight ? rightMaxWidth : leftMaxWidth, 40));

      final info = _LabelInfo(
        index: i,
        middleAngle: mid,
        isRight: isRight,
        extensionX: extX,
        extensionY: extY,
        anchorY: extY,
        painter: tp,
        color: slices[i].color,
      );

      if (isRight) {
        rightLabels.add(info);
      } else {
        leftLabels.add(info);
      }
    }

    // ── Phase 3: Anti-collision (prevent label overlap) ────────────────
    _resolveOverlaps(rightLabels, size.height);
    _resolveOverlaps(leftLabels, size.height);

    // ── Phase 4: Draw callout lines and labels ───────────────────────
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final label in [...rightLabels, ...leftLabels]) {
      // Point on slice edge
      final edgePoint = Offset(
        center.dx + cos(label.middleAngle) * radius,
        center.dy + sin(label.middleAngle) * radius,
      );

      // Extension point (short radial line beyond pie edge)
      final extPoint = Offset(label.extensionX, label.extensionY);

      // Anchor point (where the line meets the label column)
      final anchorX = label.isRight ? rightColX - 4 : leftColX + 4;
      final anchorPoint = Offset(anchorX, label.anchorY);

      // Draw line: edge → extension → anchor
      canvas.drawLine(edgePoint, extPoint, linePaint);
      canvas.drawLine(extPoint, anchorPoint, linePaint);

      // Small colored dot at the anchor
      canvas.drawCircle(
        anchorPoint,
        2.5,
        Paint()..color = label.color,
      );

      // Draw text
      final textX = label.isRight ? rightColX : edgeMargin;
      final textY = label.anchorY - label.painter.height / 2;
      label.painter.paint(canvas, Offset(textX, textY));
    }
  }

  /// Vertically redistributes labels so they don't overlap each other.
  void _resolveOverlaps(List<_LabelInfo> labels, double maxHeight) {
    if (labels.length <= 1) return;
    labels.sort((a, b) => a.anchorY.compareTo(b.anchorY));

    const minSpacing = 38.0;
    const margin = 12.0;

    // Push overlapping labels downward
    for (int i = 1; i < labels.length; i++) {
      final needed = labels[i - 1].anchorY + minSpacing;
      if (labels[i].anchorY < needed) {
        labels[i].anchorY = needed;
      }
    }

    // If the last label exceeds the bottom, shift everything upward
    final bottomEdge = labels.last.anchorY + 16;
    if (bottomEdge > maxHeight - margin) {
      final shift = bottomEdge - (maxHeight - margin);
      for (final l in labels) {
        l.anchorY -= shift;
      }
    }

    // Clamp to top boundary
    if (labels.first.anchorY < margin + 8) {
      final shift = (margin + 8) - labels.first.anchorY;
      for (final l in labels) {
        l.anchorY += shift;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return true;
  }
}
