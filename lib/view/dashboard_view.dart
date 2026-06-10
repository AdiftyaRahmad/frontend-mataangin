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
const _kBg         = Color(0xFF1598A3);
const _kCard       = Color(0xFF1E1E1E);
const _kTeal       = Color(0xFF1598A3);
const _kTealDark   = Color(0xFF0D7A84);
const _kTealDeep   = Color(0xFF0A5C64);
const _kGreen      = Color(0xFF22C55E);
const _kRed        = Color(0xFFEF4444);
const _kTextPrim   = Colors.white;
const _kTextSub    = Color(0xFF9CA3AF);

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
      _NavItem(Icons.grid_view_rounded,        Icons.grid_view_rounded,        'Dashboard'),
      _NavItem(Icons.trending_up_rounded,      Icons.trending_up_rounded,      'Pemasukan'),
      _NavItem(Icons.trending_down_rounded,    Icons.trending_down_rounded,    'Pengeluaran'),
      _NavItem(Icons.people_alt_outlined,      Icons.people_alt_rounded,       'Utang'),
      _NavItem(Icons.bar_chart_rounded,        Icons.bar_chart_rounded,        'Laporan'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A), width: 1)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
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
    ...pemasukanVm.list.map((e) => _TxData(
          judul: 'Pemasukan - ${e.hari}',
          jumlah: e.totalPemasukan,
          tanggal: e.tanggal,
          isIncome: true,
        )),
    ...pengeluaranVm.list.map((e) => _TxData(
          judul: e.namaBarang,
          jumlah: e.nominal,
          tanggal: e.tanggal,
          isIncome: false,
        )),
  ];

  allTx.sort((a, b) => (b.tanggal ?? '').compareTo(a.tanggal ?? ''));

  final recentTx = allTx.take(5).toList();

    return Column(
      children: [
        // ── Teal Header ─────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: _kTeal,
          ),
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
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.white, size: 22),
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
                  _RingkasanKeuanganCard(
                    saldo: dashVm.dashboard.saldo,
                    pemasukan: dashVm.dashboard.totalPemasukan,
                    pengeluaran: dashVm.dashboard.totalPengeluaran,
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
                            horizontal: 4, vertical: 2),
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
                  ...recentTx.map((tx) => _TransactionTile(
                        judul: tx.judul,
                        jumlah: tx.jumlah,
                        tanggal: tx.tanggal,
                        isIncome: tx.isIncome,
                        fmt: fmt,
                      )),
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
        color: _kTealDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Saldo',
            style: TextStyle(
              color: Colors.white70,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kTealDeep,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 13),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
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
            Icon(Icons.receipt_long_outlined,
                size: 52, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: _kTextSub,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ringkasan Keuangan Card ──────────────────────────────────────────────────

class _RingkasanKeuanganCard extends StatelessWidget {
  final double saldo;
  final double pemasukan;
  final double pengeluaran;
  final NumberFormat fmt;

  const _RingkasanKeuanganCard({
    required this.saldo,
    required this.pemasukan,
    required this.pengeluaran,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic savings rate / net margin
    double pct = 0.0;
    if (pemasukan > 0) {
      pct = (saldo / pemasukan) * 100;
    } else if (pengeluaran > 0) {
      pct = -100.0;
    }

    final total = pemasukan + pengeluaran;
    final double pemasukanPct = total > 0 ? (pemasukan / total) : 0.0;
    final double pengeluaranPct = total > 0 ? (pengeluaran / total) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Keuangan',
            style: TextStyle(
              color: _kTextSub,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            fmt.format(saldo),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildTrendPill(pct),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: _DonutChart(
                pemasukan: pemasukan,
                pengeluaran: pengeluaran,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _LegendItem(
            label: 'Pemasukan',
            amount: pemasukan,
            percentage: pemasukanPct,
            color: _kGreen,
            fmt: fmt,
          ),
          const SizedBox(height: 12),
          _LegendItem(
            label: 'Pengeluaran',
            amount: pengeluaran,
            percentage: pengeluaranPct,
            color: _kRed,
            fmt: fmt,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendPill(double pct) {
    final isPositive = pct >= 0;
    final color = isPositive ? _kGreen : _kRed;
    final icon = isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            '${pct.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Donut Chart ──────────────────────────────────────────────────────────────

class _DonutChart extends StatelessWidget {
  final double pemasukan;
  final double pengeluaran;

  const _DonutChart({
    required this.pemasukan,
    required this.pengeluaran,
  });

  @override
  Widget build(BuildContext context) {
    final total = pemasukan + pengeluaran;
    final double pemasukanPct = total > 0 ? (pemasukan / total) : 0.0;
    final double pengeluaranPct = total > 0 ? (pengeluaran / total) : 0.0;
    final isZero = pemasukan == 0 && pengeluaran == 0;

    return CustomPaint(
      painter: _DonutChartPainter(
        pemasukanPct: isZero ? 0.0 : pemasukanPct,
        pengeluaranPct: isZero ? 0.0 : pengeluaranPct,
        isZero: isZero,
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double pemasukanPct;
  final double pengeluaranPct;
  final bool isZero;

  _DonutChartPainter({
    required this.pemasukanPct,
    required this.pengeluaranPct,
    required this.isZero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = 24.0;
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paintBg = Paint()
      ..color = const Color(0xFF2E2E2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    if (isZero) {
      canvas.drawCircle(center, radius, paintBg);
      return;
    }

    final paintPemasukan = Paint()
      ..color = _kGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final paintPengeluaran = Paint()
      ..color = _kRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Start drawing from the top (-pi/2)
    double startAngle = -3.141592653589793 / 2;

    // Draw Pemasukan (Green)
    final sweepPemasukan = 2 * 3.141592653589793 * pemasukanPct;
    canvas.drawArc(rect, startAngle, sweepPemasukan, false, paintPemasukan);

    // Draw Pengeluaran (Red)
    final sweepPengeluaran = 2 * 3.141592653589793 * pengeluaranPct;
    canvas.drawArc(rect, startAngle + sweepPemasukan, sweepPengeluaran, false, paintPengeluaran);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.pemasukanPct != pemasukanPct ||
        oldDelegate.pengeluaranPct != pengeluaranPct ||
        oldDelegate.isZero != isZero;
  }
}

// ─── Legend Item ──────────────────────────────────────────────────────────────

class _LegendItem extends StatelessWidget {
  final String label;
  final double amount;
  final double percentage;
  final Color color;
  final NumberFormat fmt;

  const _LegendItem({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              color: _kTextPrim,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            fmt.format(amount),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _kTextPrim,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            '${(percentage * 100).toStringAsFixed(2)}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _kTextSub,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
