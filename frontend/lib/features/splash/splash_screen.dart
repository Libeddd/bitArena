import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bitArena/app/app_routes.dart';
import 'package:bitArena/features/auth/cubit/auth_cubit.dart';
import 'package:bitArena/features/auth/cubit/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late DateTime _startTime;
  static const _minDisplayTime = Duration(milliseconds: 2500); // 2.5 detik

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    context.read<AuthCubit>().checkAuthStatus();
  }

  void _handleNavigation(String route) async {
    final elapsed = DateTime.now().difference(_startTime);

    if (elapsed < _minDisplayTime) {
      final remainingTime = _minDisplayTime - elapsed;
      await Future.delayed(remainingTime);
    }
    if (mounted) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          _handleNavigation(AppRoutes.home);
        } else if (state is Unauthenticated) {
          _handleNavigation(AppRoutes.login);
        }
      },
      child: Scaffold(
        // Menggunakan Container untuk background hitam solid
        body: Container(
          // --- PERUBAHAN DI SINI ---
          decoration: const BoxDecoration(
            color: Colors.black, // Warna latar belakang diubah menjadi hitam solid
          ),
          child: Center(
            // Sekarang hanya ada logo di dalam Center
            child: Image.asset(
              'assets/logo.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
            // Widget Column, SizedBox, dan Text sudah dihapus
          ),
        ),
      ),
    );
  }
}
