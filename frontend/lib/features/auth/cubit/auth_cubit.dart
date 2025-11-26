import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bitarena/features/auth/cubit/auth_state.dart';
import 'package:bitarena/data/services/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService = AuthService();

  AuthCubit() : super(AuthInitial());

  void checkAuthStatus() async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 2));
    
    final user = _authService.currentUser;
    if (user != null) {
      print("AuthCubit: User sudah login sebelumnya (${user.email})");
      emit(Authenticated());
    } else {
      print("AuthCubit: Belum ada user login");
      emit(Unauthenticated());
    }
  }

  void login(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authService.loginWithEmail(email, password);
      print("AuthCubit: Login Email Berhasil");
      emit(Authenticated());
    } catch (e) {
      print("AuthCubit Error (Email): $e");
      emit(Unauthenticated());
    }
  }

  void signUp(String email, String password, String name) async {
    emit(AuthLoading());
    try {
      await _authService.signUpWithEmail(email, password, name);
      print("Sign Up Berhasil");
      emit(Authenticated());
    } catch (e) {
      print("Sign Up Gagal: $e");
      emit(Unauthenticated());
    }
  }

  void loginGoogle() async {
    print("AuthCubit: Memulai Login Google..."); // LOG 1
    emit(AuthLoading());
    try {
      final user = await _authService.loginWithGoogle();
      
      if (user != null) {
        print("AuthCubit: Login Google BERHASIL! User: ${user.email}"); // LOG 2
        emit(Authenticated());
      } else {
        print("AuthCubit: Login Google DIBATALKAN oleh user (User is null)"); // LOG 3
        emit(Unauthenticated());
      }
    } catch (e) {
      // --- INI YANG KITA CARI ---
      print("AuthCubit CRITICAL ERROR (Google): $e"); // LOG 4
      emit(Unauthenticated());
    }
  }

  void logout() async {
    await _authService.logout();
    emit(Unauthenticated());
  }
}