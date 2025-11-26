// File: lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bitarena/app/app_routes.dart';
import 'package:bitarena/features/auth/cubit/auth_cubit.dart';
import 'package:bitarena/features/auth/cubit/auth_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color kRightBgColor = Color(0xFF1E1E1E); 
    const Color kLeftBgColor = Colors.white;       

    return Scaffold(
      // --- 1. TAMBAHKAN BLOC LISTENER ---
      // Ini yang membuat aplikasi pindah halaman saat login sukses
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Jika login sukses, pindah ke Home
            context.go(AppRoutes.home);
          }
          if (state is Unauthenticated) {
            // Opsional: Tampilkan snackbar jika gagal login (tapi bukan logout)
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text("Login Gagal. Cek email/password.")),
            // );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: kLeftBgColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logo_login.png',
                            width: 250,
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "bitArena",
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E1E1E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: kRightBgColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Center(
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: const _LoginForm(isMobile: false),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Container(
                color: kRightBgColor,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: const _LoginForm(isMobile: true),
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

class _LoginForm extends StatefulWidget {
  final bool isMobile;
  const _LoginForm({required this.isMobile});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  int _strengthLevel = 0; 

  void _checkPasswordStrength(String value) {
    setState(() {
      if (value.isEmpty) {
        _strengthLevel = 0;
      } else if (value.length < 6) {
        _strengthLevel = 1;
      } else if (value.length < 8) {
        _strengthLevel = 2;
      } else {
        _strengthLevel = 3;
      }
    });
  }

  Color _getStrengthColor(int barIndex) {
    if (_strengthLevel >= barIndex) {
      if (_strengthLevel == 1) return Colors.red;
      if (_strengthLevel == 2) return Colors.orange;
      return Colors.green;
    }
    return Colors.grey[800]!;
  }

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryRed = Color(0xFFE53935);
    const Color kInputFill = Color(0xFF2C2C2C);

    Widget buildRoundedInput({
      required String hint,
      required IconData icon,
      required TextEditingController controller,
      bool isPassword = false,
      ValueChanged<String>? onChanged,
    }) {
      return TextField(
        controller: controller,
        obscureText: isPassword,
        onChanged: onChanged,
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: widget.isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (widget.isMobile) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/logo_login.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "bitArena",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
        ],

        Text(
          'Welcome!',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please login to your account',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
        const SizedBox(height: 40),

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
          onChanged: _checkPasswordStrength,
        ),
        
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: widget.isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Text("Password strength", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40, height: 4, color: _getStrengthColor(1),
            ),
            const SizedBox(width: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40, height: 4, color: _getStrengthColor(2),
            ),
            const SizedBox(width: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40, height: 4, color: _getStrengthColor(3),
            ),
          ],
        ),
        const SizedBox(height: 40),

        // --- 2. UPDATE TOMBOL LOGIN ---
        // Tambahkan BlocBuilder agar tombol bisa menampilkan loading spinner
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final bool isLoading = state is AuthLoading;

            return Row(
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
                    onPressed: isLoading 
                        ? null // Matikan tombol jika loading
                        : () {
                            context.read<AuthCubit>().login(
                                  emailController.text,
                                  passwordController.text,
                                );
                          },
                    child: isLoading 
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
                          )
                        : const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    onPressed: isLoading 
                        ? null 
                        : () {
                            context.push(AppRoutes.register);
                          },
                    child: const Text('Sign Up'),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 30),
        
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[800])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("Or continue with", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
            ),
            Expanded(child: Divider(color: Colors.grey[800])),
          ],
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
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
}