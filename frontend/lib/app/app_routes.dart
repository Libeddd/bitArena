// File: lib/app/app_routes.dart

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Impor semua file 'screen' Anda
import 'package:frontend/features/splash/splash_screen.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:frontend/features/home/screens/home_screen.dart';
import 'package:frontend/features/detail/screens/detail_screen.dart';
import 'package:frontend/features/search/screens/search_screen.dart';


class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';
  
  // --- PASTIKAN BARIS INI ADA DAN BENAR ---
  // Error Anda terjadi karena 'search' di bawah ini salah
  // atau tidak ada di dalam kelas AppRoutes.
  static const String search = '/search';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        name: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: home,
        name: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '$detail/:id', 
        name: detail,
        builder: (context, state) {
          final String gameId = state.pathParameters['id'] ?? '0';
          return DetailScreen(gameId: gameId);
        },
      ),

      // --- PASTIKAN BLOK INI BENAR ---
      // Error 'path: "null/:query"' berasal dari sini
      GoRoute(
        // 'path' harus menggunakan '$search' (yang bernilai '/search')
        path: '$search/:query', 
        // 'name' harus menggunakan 'search'
        name: search, 
        builder: (context, state) {
          final String query = state.pathParameters['query'] ?? '';
          return SearchScreen(query: query);
        },
      ),
    ],
  );
}