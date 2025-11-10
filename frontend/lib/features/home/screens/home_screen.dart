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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<HomeBloc>().add(HomeFetchList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Games Store'),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      context.read<HomeBloc>().add(HomeFetchList());
                    }
                  },
                ),
              ),
            ),
          ),

          // --- 2. KONTEN (Scrollable) ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- 3. PERBAIKAN: BANNER & SIDEBAR BLOCBUILDER ---
                  BlocBuilder<HomeBloc, HomeState>(
                    // Kita hapus buildWhen agar builder ini
                    // juga berjalan saat state HomeLoading
                    builder: (context, state) {
                      
                      // --- TAMPILKAN SKELETON SAAT LOADING ---
                      if (state is HomeLoading || state is HomeInitial) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[850]!,
                          highlightColor: Colors.grey[700]!,
                          child: Container(
                            height: 400,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                // Panggil Skeleton Banner
                                const Expanded(
                                  flex: 3,
                                  child: HomeBannerSkeleton(),
                                ),
                                const SizedBox(width: 16),
                                // Panggil Skeleton Sidebar
                                const Expanded(
                                  flex: 1,
                                  child: HomeSidebarSkeleton(),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // --- TAMPILKAN BANNER ASLI SAAT SUKSES ---
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
                      
                      // Fallback jika Error (atau state lain)
                      return Container(
                        height: 400,
                        alignment: Alignment.center,
                        child: const Text('Gagal memuat banner'),
                      );
                    },
                  ),
                  // --- 5. JUDUL "Trending Games" ---
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

                  // --- 6. GRID "Trending Games" ---
                  // BlocBuilder ini menampilkan skeleton atau grid game
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      
                      // Tampilkan SKELETON saat loading
                      if (state is HomeLoading || state is HomeInitial) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[850]!,
                          highlightColor: Colors.grey[700]!,
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              childAspectRatio: 1.05, // Rasio yang sudah diperbaiki
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: 6, // Tampilkan 6 skeleton
                            itemBuilder: (context, index) {
                              return const HomeCardSkeleton();
                            },
                          ),
                        );
                      }

                      // Tampilkan ERROR jika gagal
                      if (state is HomeError) {
                        return Center(child: Text('Gagal memuat data: ${state.message}'));
                      }
                      
                      // Tampilkan HASIL jika sukses
                      if (state is HomeSuccess) {
                        if (state.games.isEmpty) {
                          return const Center(child: Text('Game tidak ditemukan.'));
                        }
                        
                        // Ambil sisa game (setelah 10 game untuk banner/sidebar)
                        final gridGames = state.games.skip(10).toList();

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            childAspectRatio: 1.05, // Rasio yang sudah diperbaiki
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: gridGames.length,
                          itemBuilder: (context, index) {
                            final game = gridGames[index];
                            // Panggil kartu baru
                            return HomeCard(game: game);
                          },
                        );
                      }
                      
                      // Fallback (seharusnya tidak terjadi)
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