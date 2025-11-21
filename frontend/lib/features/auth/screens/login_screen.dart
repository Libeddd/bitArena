import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bitarena/app/app_routes.dart';
import 'package:bitarena/features/auth/cubit/auth_cubit.dart';
import 'package:bitarena/features/auth/cubit/auth_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Controller ---
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    // --- Warna Tema Asli Anda ---
    const Color kRightBgColor = Color(0xFF1E1E1E); 
    const Color kLeftBgColor = Colors.white;       
    const Color kPrimaryRed = Color(0xFFE53935);   
    const Color kInputFill = Color(0xFF2C2C2C);    

    // --- Helper: Input Field Bulat ---
    Widget buildRoundedInput({
      required String hint,
      required IconData icon,
      required TextEditingController controller,
      bool isPassword = false,
    }) {
      return TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          filled: true,
          fillColor: kInputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: kPrimaryRed, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    }

    // --- Helper: Widget Form ---
    Widget buildLoginForm(bool isMobile) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // Logo untuk Mobile (di atas)
          if (isMobile) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/logo_login.png', // ASET LOGO ANDA
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "bitArena",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
          ],

          // Header
          const Text(
            'Welcome!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please login to your account',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),

          // Inputs
          buildRoundedInput(
            hint: 'Your email',
            icon: Icons.email_outlined,
            controller: emailController,
          ),
          const SizedBox(height: 16),

          buildRoundedInput(
            hint: 'Password',
            icon: Icons.lock_outline,
            controller: passwordController,
            isPassword: true,
          ),
          
          const SizedBox(height: 16),
          // Password Strength visual
          Row(
            mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              const Text("Password strength", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(width: 10),
              Container(width: 40, height: 4, color: Colors.white),
              const SizedBox(width: 5),
              Container(width: 40, height: 4, color: Colors.white),
              const SizedBox(width: 5),
              Container(width: 40, height: 4, color: Colors.grey[800]),
            ],
          ),
          const SizedBox(height: 40),

          // Tombol Login & Sign Up
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    context.read<AuthCubit>().login(
                          emailController.text,
                          passwordController.text,
                        );
                  },
                  child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {},
                  child: const Text('Sign Up'),
                ),
              ),
            ],
          ),

          // --- BAGIAN TOMBOL GOOGLE ---
          const SizedBox(height: 30),
          
          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[800])),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Or continue with", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              Expanded(child: Divider(color: Colors.grey[800])),
            ],
          ),

          const SizedBox(height: 24),

          // Tombol Google
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Panggil fungsi loginGoogle dari AuthCubit
                context.read<AuthCubit>().loginGoogle();
              },
              icon: const Icon(FontAwesomeIcons.google, color: Colors.white, size: 18),
              label: const Text("Sign in with Google", style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.grey[700]!),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go(AppRoutes.home);
          }
        },
        // Layout Builder untuk Responsif
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Desktop Layout (> 800px)
            if (constraints.maxWidth > 800) {
              return Row(
                children: [
                  // Panel Kiri (Logo)
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: kLeftBgColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logo_login.png', // Logo Aset
                            width: 250,
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "bitArena",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Panel Kanan (Form)
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: kRightBgColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Center(
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: buildLoginForm(false),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } 
            // Mobile Layout (< 800px)
            else {
              return Container(
                color: kRightBgColor,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: buildLoginForm(true),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}