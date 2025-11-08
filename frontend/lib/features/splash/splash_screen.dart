// File: lib/features/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Pastikan go_router di-import
import 'package:frontend/app/app_routes.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/cubit/auth_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Panggil fungsi checkAuthStatus saat SplashScreen pertama kali dibangun
    context.read<AuthCubit>().checkAuthStatus();

    return BlocListener<AuthCubit, AuthState>(
      // BlocListener untuk reaksi (navigasi, dialog)
      listener: (context, state) {
        if (state is Authenticated) {
          // --- PERBAIKAN ---
          // Jangan gunakan context.pushReplacement()
          // Gunakan context.go() yang merupakan perintah GoRouter
          context.go(AppRoutes.home);
        } 
        else if (state is Unauthenticated) {
          // --- PERBAIKAN ---
          // Gunakan context.go()
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlutterLogo(size: 100), // Ganti dengan logo Anda
              SizedBox(height: 20),
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}