// File: lib/features/home/screens/home_screen.dart (REVISI)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/home/bloc/home_bloc.dart';
import 'package:frontend/features/home/widgets/game_card.dart';
import 'package:frontend/features/home/widgets/home_banner.dart';
import 'package:frontend/features/home/widgets/home_sidebar_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Panggil data saat masuk (Biarkan ini, sudah benar)
    context.read<HomeBloc>().add(HomeFetchList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Games Store'),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      // Kita bungkus Column dengan SingleChildScrollView
      // agar bisa di-scroll jika kontennya terlalu panjang
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. FITUR SEARCHING (Tidak berubah) ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Cari game (cth: "Cyberpunk")...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFF2A2A2A),
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    context.read<HomeBloc>().add(HomeSearchGames(query));
                  } else {
                    context.read<HomeBloc>().add(HomeFetchList());
                  }
                },
              ),
            ),

            // --- 2. BAGIAN BANNER BARU (Persis seperti) ---
            // Kita gunakan BlocBuilder di sini untuk menyediakan data
            // ke banner dan sidebar
            BlocBuilder<HomeBloc, HomeState>(
              // buildWhen agar tidak rebuild saat loading/error
              buildWhen: (previous, current) => current is HomeSuccess,
              builder: (context, state) {
                if (state is HomeSuccess) {
                  // Ambil 5 game untuk Banner
                  final bannerGames = state.games.take(5).toList();
                  // Ambil 5 game berikutnya untuk Sidebar
                  final sidebarGames = state.games.skip(5).take(5).toList();

                  return Container(
                    // Atur tinggi banner section
                    height: 400, 
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // Bagian Kiri: Carousel (lebih besar)
                        Expanded(
                          flex: 3, // Ambil 3/4 ruang
                          child: HomeBannerCarousel(games: bannerGames),
                        ),
                        const SizedBox(width: 16),
                        // Bagian Kanan: Sidebar (lebih kecil)
                        Expanded(
                          flex: 1, // Ambil 1/4 ruang
                          child: HomeSidebarList(games: sidebarGames),
                        ),
                      ],
                    ),
                  );
                }
                // Tampilkan placeholder loading
                return Container(
                  height: 400,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                );
              },
            ),

            // --- 3. JUDUL "Trending Games" (Tidak berubah) ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Trending Games',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),

            // --- 4. GRIDVIEW (Kita modifikasi sedikit) ---
            // Kita tidak bisa pakai Expanded di dalam SingleChildScrollView
            // Jadi kita gunakan BlocBuilder lagi
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is HomeError) {
                  return Center(child: Text('Gagal memuat data: ${state.message}'));
                }
                if (state is HomeSuccess) {
                  if (state.games.isEmpty) {
                    return const Center(child: Text('Game tidak ditemukan.'));
                  }
                  
                  // Ambil sisa game untuk grid
                  final gridGames = state.games.skip(10).toList();

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    // PENTING: Matikan scrolling GridView
                    // karena sudah dibungkus SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true, // Biarkan GridView ambil ruang yg dibutuhkan
                    
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      childAspectRatio: 2 / 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: gridGames.length,
                    itemBuilder: (context, index) {
                      final game = gridGames[index];
                      return GameCard(game: game);
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            const SizedBox(height: 20), // Beri jarak di bawah
          ],
        ),
      ),
    );
  }
}