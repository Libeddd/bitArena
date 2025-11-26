import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bitarena/app/app_routes.dart';
import 'package:bitarena/features/auth/cubit/auth_cubit.dart';
import 'package:bitarena/features/auth/cubit/auth_state.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late DateTime _startTime;
  static const _minDisplayTime = Duration(milliseconds: 3000);

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
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 30),
                    LoadingAnimationWidget.hexagonDots(
                      color: Colors.white,
                      size: 50,
                    ),
                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  "© 2025 bitArena Kelompok 3",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}