// File: lib/app/app_routes.dart

import 'package:flutter/material.dart'; // WAJIB ada jika menggunakan widget UI seperti Scaffold/Center
import 'package:go_router/go_router.dart';
import 'package:bitarena/features/splash/splash_screen.dart';
import 'package:bitarena/features/auth/screens/login_screen.dart';
import 'package:bitarena/features/auth/screens/register_screen.dart';
import 'package:bitarena/features/home/screens/home_screen.dart';
import 'package:bitarena/features/detail/screens/detail_screen.dart';
import 'package:bitarena/features/search/screens/search_screen.dart';
import 'package:bitarena/features/browse/screens/browse_screen.dart';


class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home'; // Konstanta Path
  static const String detail = '/detail';
  static const String search = '/search';
  static const String browse = '/browse';


  static final GoRouter router = GoRouter(
    initialLocation: splash,
    // Opsional: untuk melihat jika rute tidak ditemukan
    errorBuilder: (context, state) => const Scaffold(
      body: Center(child: Text("Route not found")),
    ),
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
        path: register,
        name: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // --- PERBAIKAN KRITIS: RUTE HOME DITAMBAHKAN KEMBALI ---
      GoRoute(
        path: home, // path: '/home'
        name: home,
        builder: (context, state) => const HomeScreen(),
      ),
      // --------------------------------------------------------
      
      // Rute Detail, Search, Browse berada SEJAJAR (Sibling) dengan Home.
      GoRoute(
        path: '$detail/:id', 
        name: detail,
        builder: (context, state) {
          final String gameId = state.pathParameters['id'] ?? '0';
          return DetailScreen(gameId: gameId);
        },
      ),
      GoRoute(
        path: '$search/:query', 
        name: search, 
        builder: (context, state) {
          final String query = state.pathParameters['query'] ?? '';
          return SearchScreen(query: query);
        },
      ),
      GoRoute(
        path: browse,
        name: browse,
        builder: (context, state) {
          final String title = state.uri.queryParameters['title'] ?? 'Browse';
          final filters = Map<String, dynamic>.from(state.uri.queryParameters);
          filters.remove('title'); // Hapus title dari filter

          return BrowseScreen(
            title: title,
            filters: filters,
          );
        },
      ),
    ],
  );
}