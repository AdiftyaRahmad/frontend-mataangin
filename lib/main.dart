import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/utils/token_manager.dart';
import 'viewmodel/auth_viewmodel.dart';
import 'viewmodel/dashboard_viewmodel.dart';
import 'viewmodel/pemasukan_viewmodel.dart';
import 'viewmodel/pengeluaran_viewmodel.dart';
import 'viewmodel/utang_piutang_viewmodel.dart';
import 'viewmodel/laporan_viewmodel.dart';
import 'view/login_view.dart';
import 'view/dashboard_view.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID', null);
  runApp(const MataAnginApp());
}

class MataAnginApp extends StatelessWidget {
  const MataAnginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => PemasukanViewModel()),
        ChangeNotifierProvider(create: (_) => PengeluaranViewModel()),
        ChangeNotifierProvider(create: (_) => UtangPiutangViewModel()),
        ChangeNotifierProvider(create: (_) => LaporanViewModel()),
      ],
      child: MaterialApp(
        title: 'Mata Angin Finance',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1598A3),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const _Splash(),
      ),
    );
  }
}

/// Splash screen checks stored token and routes accordingly
class _Splash extends StatefulWidget {
  const _Splash();

  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final isLoggedIn = await TokenManager.isLoggedIn();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            isLoggedIn ? const DashboardView() : const LoginView(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F6D75), Color(0xFF1598A3)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1598A3).withValues(alpha: 0.5),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(Icons.air, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'Mata Angin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Finance Manager',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
