// File: lib/features/auth/cubit/auth_state.dart

import 'package:equatable/equatable.dart';

// Abstract class untuk state
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

// State awal, belum dicek
class AuthInitial extends AuthState {}

// State ketika sedang mengecek (loading)
class AuthLoading extends AuthState {}

// State jika user sudah login
class Authenticated extends AuthState {}

// State jika user belum login
class Unauthenticated extends AuthState {}