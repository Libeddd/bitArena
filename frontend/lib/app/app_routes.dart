// File: lib/app/app_routes.dart

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Impor semua file 'screen' Anda
import 'package:frontend/features/splash/splash_screen.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:frontend/features/home/screens/home_screen.dart';
import 'package:frontend/features/detail/screens/detail_screen.dart';

class AppRoutes {
  // Definisikan nama rute sebagai konstanta agar tidak salah ketik
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail'; // Akan menjadi /detail/:id

  // Konfigurasi GoRouter
  static final GoRouter router = GoRouter(
    initialLocation: splash, // Mulai dari splash screen
    routes: [
      // 1. Splash Screen
      GoRoute(
        path: splash,
        name: splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Login Screen
      GoRoute(
        path: login,
        name: login,
        builder: (context, state) => const LoginScreen(),
      ),

      // 3. Home Screen
      GoRoute(
        path: home,
        name: home,
        builder: (context, state) => const HomeScreen(),
      ),

      // 4. Detail Screen (dengan parameter ID)
      GoRoute(
        // :id adalah parameter yang akan dikirim
        path: '$detail/:id', 
        name: detail,
        builder: (context, state) {
          // Ambil 'id' dari parameter URL
          final String gameId = state.pathParameters['id'] ?? '0';
          return DetailScreen(gameId: gameId);
        },
      ),
    ],
    
    // (Opsional) Logika Redirect:
    // Jika Anda ingin menangani user yang belum login,
    // Anda bisa tambahkan 'redirect' di sini.
    redirect: (BuildContext context, GoRouterState state) {
      // Cek status login dari AuthCubit (Contoh)
      // final bool isLoggedIn = context.read<AuthCubit>().state.isAuthenticated;
      // final bool isLoggingIn = state.matchedLocation == login;
      
      // if (!isLoggedIn && !isLoggingIn) return login; // Paksa ke login
      // if (isLoggedIn && isLoggingIn) return home; // Jika sudah login, lempar ke home
      
      return null; // Biarkan navigasi
    },
  );
}