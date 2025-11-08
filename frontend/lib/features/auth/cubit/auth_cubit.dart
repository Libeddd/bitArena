// File: lib/features/auth/cubit/auth_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  // Fungsi ini akan dipanggil oleh SplashScreen
  void checkAuthStatus() async {
    emit(AuthLoading());
    
    // Simulasi pengecekan ke server atau local storage
    await Future.delayed(const Duration(seconds: 3));

    // Logika palsu: anggap saja user belum login
    // Nanti di sini Anda akan cek (misal: SharedPreferences)
    const bool isLoggedIn = false; 

    if (isLoggedIn) {
      emit(Authenticated());
    } else {
      emit(Unauthenticated());
    }
  }

  // Fungsi untuk login (dipanggil dari LoginScreen nanti)
  void login(String email, String password) {
    // Logika login...
    emit(Authenticated());
  }

  // Fungsi untuk logout
  void logout() {
    // Logika logout...
    emit(Unauthenticated());
  }
}