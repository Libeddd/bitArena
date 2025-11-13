// File: lib/app/app_routes.dart

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Impor semua file 'screen' Anda
import 'package:bitArena/features/splash/splash_screen.dart';
import 'package:bitArena/features/auth/screens/login_screen.dart';
import 'package:bitArena/features/home/screens/home_screen.dart';
import 'package:bitArena/features/detail/screens/detail_screen.dart';
import 'package:bitArena/features/search/screens/search_screen.dart';


class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';
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
      GoRoute(
        path: '$search/:query', 
        name: search, 
        builder: (context, state) {
          final String query = state.pathParameters['query'] ?? '';
          return SearchScreen(query: query);
        },
      ),
    ],
  );
}