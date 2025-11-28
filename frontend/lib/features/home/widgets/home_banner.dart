// File: lib/features/home/widgets/home_banner_carousel.dart (REVISI)

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bitarena/data/models/game_model.dart'; 
import 'package:flutter/material.dart' hide CarouselController;
import 'package:go_router/go_router.dart';
import 'package:bitarena/app/app_routes.dart'; 

class HomeBannerCarousel extends StatelessWidget {
  final List<GameModel> games;
  final double height; 

  const HomeBannerCarousel({
    super.key, 
    required this.games,
    this.height = 400.0, // Default disamakan dengan HomeScreen
  });

  @override
  Widget build(BuildContext context) {
    // Diganti dari CarouselSlider.builder menjadi IndexedStack
    // karena hanya akan menampilkan 1 banner utama saja (tidak carousel)
    // dan dipanggil di bagian utama (kiri)
    if (games.isEmpty) return const SizedBox.shrink();

    // Ambil game pertama untuk banner utama
    final game = games.first; 
    return _MainBannerCard(game: game, height: height);
  }
}

// Widget baru untuk Banner Utama Kiri
class _MainBannerCard extends StatelessWidget {
  final GameModel game;
  final double height;
  const _MainBannerCard({required this.game, required this.height});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.push('${AppRoutes.detail}/${game.id}');
        },
        child: SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.zero,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Gambar Background
                CachedNetworkImage(
                  imageUrl: game.backgroundImage,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[900]),
                ),
                
                // 2. Gradient Gelap
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter, // Ubah gradien dari bawah
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),

                // 3. Konten Teks
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name, // Huruf besar dihilangkan
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      // Subtitle dan Tombol dihilangkan
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget baru untuk daftar game kecil di sebelah kanan
class _SmallBannerCard extends StatelessWidget {
  final GameModel game;
  const _SmallBannerCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.push('${AppRoutes.detail}/${game.id}');
        },
        child: Container(
          height: 151, // Sesuaikan tinggi per item
          margin: const EdgeInsets.only(bottom: 23.0), // Spasi antar item
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0), // Tambahkan sedikit border radius
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Gambar Background
                CachedNetworkImage(
                  imageUrl: game.backgroundImage,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[900]),
                ),
                
                // 2. Gradient Gelap (untuk memastikan teks terbaca)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),

                // 3. Konten Teks
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget baru untuk menampung daftar game kecil
class SmallBannerList extends StatelessWidget {
  final List<GameModel> games;

  const SmallBannerList({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: games.map((game) => _SmallBannerCard(game: game)).toList(),
    );
  }
}