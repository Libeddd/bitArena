// File: lib/features/home/screens/home_screen.dart (REVISI PAGINATION)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/home/bloc/home_bloc.dart';
import 'package:frontend/features/home/widgets/home_card.dart';
import 'package:frontend/features/home/widgets/home_banner.dart';
import 'package:frontend/features/home/widgets/home_sidebar_list.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/app/app_routes.dart';
import 'package:shimmer/shimmer.dart';
import 'package:frontend/features/home/widgets/home_card_skeleton.dart';
import 'package:frontend/features/home/widgets/home_banner_skeleton.dart';
import 'package:frontend/features/home/widgets/home_sidebar_skeleton.dart';

// --- PERUBAHAN 1: Ubah ke StatefulWidget ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  // --- PERUBAHAN 2: Buat ScrollController ---
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Panggil data saat masuk
    context.read<HomeBloc>().add(HomeFetchList());
    
    // --- PERUBAHAN 3: Tambahkan Listener ---
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // --- PERUBAHAN 4: Hapus listener & controller ---
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // --- PERUBAHAN 5: Fungsi Listener ---
  void _onScroll() {
    final currentState = context.read<HomeBloc>().state;
    
    // Cek apakah kita sudah di state Success
    if (currentState is HomeSuccess) {
      // Cek apakah kita sudah 300px dari bawah
      if (_scrollController.position.extentAfter < 300) {
        // Panggil event untuk memuat lebih banyak
        context.read<HomeBloc>().add(HomeFetchMoreGames());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games Store'),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Search Bar (Tidak Berubah) ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 300, 
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search store',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[400],
                      size: 22.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                  onSubmitted: (query) {
                    if (query.isNotEmpty) {
                      context.push('${AppRoutes.search}/$query');
                    } else {
                      // Jika search kosong, refresh halaman 1
                      context.read<HomeBloc>().add(HomeFetchList());
                    }
                  },
                ),
              ),
            ),
          ),

          // --- 2. KONTEN (Scrollable) ---
          Expanded(
            // --- PERUBAHAN 6: Hubungkan Controller ---
            child: SingleChildScrollView(
              controller: _scrollController, // <-- Hubungkan di sini
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- Banner & Sidebar BlocBuilder (Tidak Berubah) ---
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading || state is HomeInitial) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[850]!,
                          highlightColor: Colors.grey[700]!,
                          child: Container(
                            height: 400,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: const Row(
                              children: [
                                Expanded(flex: 3, child: HomeBannerSkeleton()),
                                SizedBox(width: 16),
                                Expanded(flex: 1, child: HomeSidebarSkeleton()),
                              ],
                            ),
                          ),
                        );
                      }
                      if (state is HomeSuccess) {
                        final bannerGames = state.games.take(5).toList();
                        final sidebarGames = state.games.skip(5).take(5).toList();

                        return Container(
                          height: 400,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: HomeBannerCarousel(games: bannerGames),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: HomeSidebarList(games: sidebarGames),
                              ),
                            ],
                          ),
                        );
                      }
                      return Container(
                        height: 400,
                        alignment: Alignment.center,
                        child: const Text('Gagal memuat banner'),
                      );
                    },
                  ),
                  
                  // --- Judul "Trending Games" (Tidak Berubah) ---
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'All Games',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),

                  // --- 6. GRID "Trending Games" ---
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      
                      if (state is HomeLoading || state is HomeInitial) {
                        // ... (Kode Skeleton Grid tidak berubah)
                        return Shimmer.fromColors( 
                          baseColor: Colors.grey[850]!,
                          highlightColor: Colors.grey[700]!,
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              childAspectRatio: 1.05,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return const HomeCardSkeleton();
                            },
                          ),
                        );
                      }
                      if (state is HomeError) {
                        return Center(child: Text('Gagal memuat data: ${state.message}'));
                      }
                      if (state is HomeSuccess) {
                        if (state.games.isEmpty) {
                          return const Center(child: Text('Game tidak ditemukan.'));
                        }
                        
                        final gridGames = state.games.skip(10).toList();

                        // --- PERUBAHAN 7: Tampilkan Loading di Bawah Grid ---
                        return Column(
                          children: [
                            GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                childAspectRatio: 1.05,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: gridGames.length,
                              itemBuilder: (context, index) {
                                final game = gridGames[index];
                                return HomeCard(game: game);
                              },
                            ),

                            // Tampilkan CicularProgressIndicator jika
                            // sedang memuat lebih banyak DAN belum maks
                            if (state.isLoadingMore && !state.hasReachedMax)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}