import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bitArena/app/app_routes.dart';
import 'package:bitArena/features/auth/cubit/auth_cubit.dart';
import 'package:bitArena/features/auth/cubit/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    // --- Warna Tema (Gabungan Dark Mode & Referensi) ---
    const Color kRightBgColor = Color(0xFF1E1E1E); // Kanan: Hitam Pekat
    const Color kLeftBgColor = Colors.white;       // Kiri: Putih (untuk ilustrasi)
    const Color kPrimaryRed = Color(0xFFE53935);   // Aksen Merah
    const Color kInputFill = Color(0xFF2C2C2C);    // Warna isian kolom teks

    // Fungsi untuk membuat Input Field yang bulat (Pill shape)
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
          fillColor: kInputFill, // Latar belakang input abu-abu gelap
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30), // Membulat penuh
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: kPrimaryRed, width: 2), // Merah saat fokus
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    }

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go(AppRoutes.home);
          }
        },
        // Menggunakan Row untuk membagi layar
        child: Row(
          children: [
            // --- BAGIAN KIRI (Ilustrasi) ---
            // Kita sembunyikan jika layar terlalu kecil (Mobile)
            if (MediaQuery.of(context).size.width > 800)
              Expanded(
                flex: 1, // Mengambil 50% lebar layar
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

            // --- BAGIAN KANAN (Form Login) ---
            Expanded(
              flex: 1, // Mengambil 50% lebar layar (atau 100% di mobile)
              child: Container(
                color: kRightBgColor, // Background Hitam
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Center(
                  child: SingleChildScrollView( // Agar aman saat keyboard muncul
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400), // Batasi lebar form
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri seperti referensi
                        children: [
                          // Judul
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

                          // Input Email
                          buildRoundedInput(
                            hint: 'Your email',
                            icon: Icons.email_outlined,
                            controller: emailController,
                          ),
                          const SizedBox(height: 16),

                          // Input Password
                          buildRoundedInput(
                            hint: 'Password',
                            icon: Icons.lock_outline,
                            controller: passwordController,
                            isPassword: true,
                          ),
                          
                          // Password Strength (Opsional - Visual saja)
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text("Password strength", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(width: 10),
                              Container(width: 40, height: 4, color: Colors.white), // Indikator kuning
                              const SizedBox(width: 5),
                              Container(width: 40, height: 4, color: Colors.white),
                              const SizedBox(width: 5),
                              Container(width: 40, height: 4, color: Colors.grey[800]),
                            ],
                          ),
                          const SizedBox(height: 40),

                          // Tombol Aksi (Row)
                          Row(
                            children: [
                              // Tombol Login (Kuning - Utama)
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
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Tombol Register (Outline - Sekunder)
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
                                  onPressed: () {
                                    // Logika ke halaman register
                                  },
                                  child: const Text('Sign Up'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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