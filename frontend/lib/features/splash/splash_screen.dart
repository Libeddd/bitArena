import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/app/app_routes.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/cubit/auth_state.dart';

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
        // Menghapus backgroundColor dari Scaffold dan akan menggunakan Container dengan Gradient
        // backgroundColor: Theme.of(context).colorScheme.background, // Baris ini dihapus
        body: Container(
          // Menggunakan BoxDecoration untuk gradient background
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft, // Mulai dari kiri
              end: Alignment.centerRight, // Berakhir di kanan
              colors: [
                Colors.black, // Warna kiri: Hitam
                Colors.white, // Warna kanan: Putih
              ],
            ),
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
