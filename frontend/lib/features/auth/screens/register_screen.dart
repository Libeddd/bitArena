// File: lib/features/auth/screens/register_screen.dart (FILE BARU)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bitarena/app/app_routes.dart';
import 'package:bitarena/features/auth/cubit/auth_cubit.dart';
import 'package:bitarena/features/auth/cubit/auth_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    // Warna Tema
    const Color kRightBgColor = Color(0xFF1E1E1E);
    const Color kLeftBgColor = Colors.white;
    const Color kPrimaryRed = Color(0xFFE53935);
    const Color kInputFill = Color(0xFF2C2C2C);

    // Helper Input
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

    // Helper Form
    Widget buildRegisterForm(bool isMobile) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Image.asset('assets/logo_login.png', width: 80, height: 80, fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            const Text("bitArena", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 40),
          ],

          const Text(
            'Create Account',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please fill in the details below',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),

          // Input Name (BARU)
          buildRoundedInput(hint: 'Full Name', icon: Icons.person_outline, controller: nameController),
          const SizedBox(height: 16),

          // Input Email
          buildRoundedInput(hint: 'Email', icon: Icons.email_outlined, controller: emailController),
          const SizedBox(height: 16),

          // Input Password
          buildRoundedInput(hint: 'Password', icon: Icons.lock_outline, controller: passwordController, isPassword: true),
          
          const SizedBox(height: 40),

          // Tombol Aksi
          Row(
            children: [
              // Tombol Sign Up (Primary)
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    // Panggil fungsi SignUp di Cubit
                    context.read<AuthCubit>().signUp(
                          emailController.text,
                          passwordController.text,
                          nameController.text,
                        );
                  },
                  child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              // Tombol Back to Login
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    context.go(AppRoutes.login); // KEMBALI KE LOGIN
                  },
                  child: const Text('Login'),
                ),
              ),
            ],
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
                          Image.asset('assets/logo_login.png', width: 250, height: 250, fit: BoxFit.contain),
                          const SizedBox(height: 20),
                          const Text("bitArena", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
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
                            child: buildRegisterForm(false),
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
                    child: buildRegisterForm(true),
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