// File: lib/features/detail/screens/detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/detail/cubit/detail_cubit.dart';

class DetailScreen extends StatelessWidget {
  final String gameId;
  const DetailScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    // Panggil Cubit untuk fetch data saat halaman ini dibuka
    context.read<DetailCubit>().fetchGameDetails(gameId);

    return Scaffold(
      // Kita gunakan BlocBuilder untuk membangun UI
      body: BlocBuilder<DetailCubit, DetailState>(
        builder: (context, state) {
          // 1. Loading State
          if (state is DetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (state is DetailError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          // 3. Success State
          if (state is DetailSuccess) {
            final game = state.game;
            // Kita gunakan CustomScrollView untuk efek parallax
            return CustomScrollView(
              slivers: [
                // App Bar yang bisa collapse
                SliverAppBar(
                  expandedHeight: 250.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFF1F1F1F),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      game.name,
                      style: const TextStyle(shadows: [Shadow(blurRadius: 5)]),
                    ),
                    background: CachedNetworkImage(
                      imageUrl: game.backgroundImage,
                      fit: BoxFit.cover,
                      // Tambahkan overlay gelap agar judul terbaca
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.5),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                ),
                
                // Konten di bawah gambar
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rating: ${game.rating}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          // Di sini Anda bisa tambahkan data lain
                          // (Misal: deskripsi, screenshot, dll dari API)
                          const Text(
                            'Deskripsi (Placeholder):',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                            'Quisque nec mi sit amet elit tempus ultrices. '
                            'Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.',
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            );
          }

          return const Center(child: Text('Memuat data...'));
        },
      ),
    );
  }
}