import 'package:flutter/material.dart'; 
import 'package:go_router/go_router.dart';
import 'package:bitarena/features/splash/splash_screen.dart';
import 'package:bitarena/features/auth/screens/login_screen.dart';
import 'package:bitarena/features/auth/screens/register_screen.dart';
import 'package:bitarena/features/home/screens/home_screen.dart';
import 'package:bitarena/features/detail/screens/detail_screen.dart';
import 'package:bitarena/features/search/screens/search_screen.dart';
import 'package:bitarena/features/browse/screens/browse_screen.dart';
import 'package:bitarena/features/detail/screens/about_us_screen.dart';
import 'package:bitarena/features/wishlist/screens/wishlist_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String search = '/search';
  static const String browse = '/browse';
  static const String aboutUs = '/about-us';
  static const String wishlist = '/wishlist';


  static final GoRouter router = GoRouter(
    initialLocation: splash,
    // ErrorBuilder sekarang akan berfungsi karena sudah ada import material.dart
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

      GoRoute(
        path: aboutUs,
        name: 'aboutUs', 
        builder: (context, state) => const AboutUsScreen(),
      ),

      GoRoute(
        path: wishlist,
        name: wishlist,
        builder: (context, state) => const WishlistScreen(),
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

      GoRoute(
        path: browse,
        name: browse,
        builder: (context, state) {
          final String title = state.uri.queryParameters['title'] ?? 'Browse';
          final filters = Map<String, dynamic>.from(state.uri.queryParameters);
          filters.remove('title'); 

          return BrowseScreen(
            title: title,
            filters: filters,
          );
        },
      ),
    ],
  );
}