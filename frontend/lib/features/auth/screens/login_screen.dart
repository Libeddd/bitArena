// File: lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/app/app_routes.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/cubit/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller untuk text field
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      // BlocListener untuk navigasi/reaksi, BUKAN untuk UI
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Jika login berhasil, lempar ke Home
            context.go(AppRoutes.home);
          }
          // Anda bisa tambahkan 'if (state is AuthError)' di sini
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlutterLogo(size: 80), // Ganti logo
                SizedBox(height: 32),
                Text('Login ke Akun Anda', style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: 24),
                
                // Email
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                
                // Password
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 32),
                
                // Tombol Login (Tanpa SetState)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // Lebar penuh
                  ),
                  onPressed: () {
                    // Panggil fungsi Cubit
                    // Tidak ada setState
                    context.read<AuthCubit>().login(
                          emailController.text,
                          passwordController.text,
                        );
                  },
                  child: Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}