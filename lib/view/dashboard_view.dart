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
      backgroundColor: const Color(0xFF1598A3),
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Colors.white10, width: 1)),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: const Color(0xFF1598A3).withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                  color: Color(0xFF1598A3),
                  fontSize: 11,
                  fontWeight: FontWeight.w600);
            }
            return TextStyle(
                color: Colors.white.withValues(alpha: 0.45), fontSize: 11);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF1598A3));
            }
            return IconThemeData(color: Colors.white.withValues(alpha: 0.45));
          }),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view),
                label: 'Dashboard'),
            NavigationDestination(
                icon: Icon(Icons.trending_up_outlined),
                selectedIcon: Icon(Icons.trending_up),
                label: 'Pemasukan'),
            NavigationDestination(
                icon: Icon(Icons.trending_down_outlined),
                selectedIcon: Icon(Icons.trending_down),
                label: 'Pengeluaran'),
            NavigationDestination(
                icon: Icon(Icons.handshake_outlined),
                selectedIcon: Icon(Icons.handshake),
                label: 'Utang'),
            NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Laporan'),
          ],
        ),
      ),
    );
  }
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
    final fmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Column(
      children: [
        // ── Teal Header ────────────────────────────────────────────────────
        Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 14,
            left: 20,
            right: 8,
            bottom: 20,
          ),
          child: Row(
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
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Selamat Datang!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.exit_to_app, color: Colors.white),
                onPressed: () async {
                  await context.read<AuthViewModel>().logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginView()),
                        (r) => false);
                  }
                },
              ),
            ],
          ),
        ),

        // ── Body ───────────────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Saldo Card ─────────────────────────────────────────────
                if (dashVm.isLoading)
                  const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF1598A3)))
                else if (dashVm.state == ViewState.error)
                  _ErrorCard(message: dashVm.errorMessage ?? 'Gagal memuat')
                else
                  _SaldoCard(
                    saldo: dashVm.dashboard.saldo,
                    pemasukan: dashVm.dashboard.totalPemasukan,
                    pengeluaran: dashVm.dashboard.totalPengeluaran,
                    fmt: fmt,
                  ),

                const SizedBox(height: 24),

                // ── Transaksi Terakhir ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaksi Terakhir',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0)),
                      child: const Text(
                        'Lihat Semua',
                        style:
                            TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Recent Transactions ───────────────────────────────────
                ...pemasukanVm.list.take(3).map((e) => _TransactionTile(
                      judul: 'Pemasukan - ${e.hari}',
                      jumlah: e.totalPemasukan,
                      tanggal: e.tanggal,
                      isIncome: true,
                      fmt: fmt,
                    )),
                ...pengeluaranVm.list.take(3).map((e) => _TransactionTile(
                      judul: e.namaBarang,
                      jumlah: e.nominal,
                      tanggal: e.tanggal,
                      isIncome: false,
                      fmt: fmt,
                    )),

                if (pemasukanVm.list.isEmpty && pengeluaranVm.list.isEmpty)
                  const _EmptyState(message: 'Belum ada transaksi'),

                const SizedBox(height: 24),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A4D54),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Saldo',
              style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            fmt.format(saldo),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'PEMASUKAN',
                  value: fmt.format(pemasukan),
                  icon: Icons.arrow_upward_rounded,
                  accentColor: const Color(0xFF22C55E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: 'PENGELUARAN',
                  value: fmt.format(pengeluaran),
                  icon: Icons.arrow_downward_rounded,
                  accentColor: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF166B72),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 14),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Transaction Tile ──────────────────────────────────────────────────────────

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
    final color =
        isIncome ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome
                  ? Icons.add_circle_outline
                  : Icons.remove_circle_outline,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                if (tanggal != null)
                  Text(tanggal!,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.38),
                          fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} ${fmt.format(jumlah)}',
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: const TextStyle(color: Color(0xFFFCA5A5)))),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined,
                size: 48, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(message,
                style:
                    TextStyle(color: Colors.white.withValues(alpha: 0.4))),
          ],
        ),
      ),
    );
  }
}
