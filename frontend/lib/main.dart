// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/app_routes.dart'; // (Kita akan buat ini)
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/data/repositories/game_repository.dart';
import 'package:frontend/data/services/game_api_service.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/detail/cubit/detail_cubit.dart';
import 'package:frontend/features/home/bloc/home_bloc.dart';

// Asumsi Anda sudah membuat file-file ini dari langkah sebelumnya
// - DioClient
// - GameRepository (abstract)
// - GameApiService (implementasi GameRepository)
// - HomeBloc
// - AuthCubit

void main() {
  // --- SETUP DEPENDENCY INJECTION (DI) MANUAL ---
  // 1. Buat instance Network Client (Encapsulation)
  final DioClient dioClient = DioClient();

  // 2. Buat instance Repository (Implementation)
  // Di sini Polymorphism terjadi. Tipe datanya adalah 'GameRepository' (kontrak)
  // namun objeknya adalah 'GameApiService' (implementasi).
  final GameRepository gameRepository = GameApiService(dioClient);

  // Jika menggunakan GetIt, panggil setup GetIt di sini
  // dependency_injection.setup();

  runApp(MyApp(gameRepository: gameRepository));
}

class MyApp extends StatelessWidget {
  final GameRepository gameRepository;

  const MyApp({super.key, required this.gameRepository});

  @override
  Widget build(BuildContext context) {
    // RepositoryProvider menyediakan satu instance Repository
    // ke semua BLoC/Cubit di bawahnya.
    return RepositoryProvider.value(
      value: gameRepository,
      child: MultiBlocProvider(
        providers: [
          // --- Sediakan BLoC/Cubit di sini ---
          
          // 1. AuthCubit (Disediakan di level atas agar bisa diakses di mana saja)
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(), // (Nanti diisi logic)
          ),
          
          // 2. HomeBloc (Menggunakan GameRepository yang sudah disediakan)
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(
              // Ambil repository dari context
              context.read<GameRepository>(),
            ),
          ),
          
          // 3. DetailCubit (Akan dibuat nanti)
          BlocProvider<DetailCubit>(
            create: (context) => DetailCubit(
              context.read<GameRepository>(),
              ),
          ),
        ],
        child: MaterialApp.router(
          title: 'Epic Games Clone',
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF121212),
            // Tambahkan kustomisasi tema di sini
          ),
          debugShowCheckedModeBanner: false,
          
          // --- Gunakan Konfigurasi Router ---
          routerConfig: AppRoutes.router,
        ),
      ),
    );
  }
}
