// File: lib/features/home/widgets/home_banner_carousel.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:bitarena/data/models/game_model.dart';
import 'package:go_router/go_router.dart';
import 'package:bitarena/app/app_routes.dart';

// --- 1. WIDGET CAROUSEL (BANNER BESAR KIRI) ---
class HomeBannerCarousel extends StatelessWidget {
  final List<GameModel> games;
  final double height;

  const HomeBannerCarousel({
    super.key,
    required this.games,
    this.height = 500.0, // Default disamakan dengan inputan Anda
  });

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) return const SizedBox.shrink();

    return CarouselSlider.builder(
      itemCount: games.length,
      itemBuilder: (context, index, realIndex) {
        final game = games[index];
        // Menggunakan MainBannerCard untuk setiap item carousel
        return MainBannerCard(game: game, height: height);
      },
      options: CarouselOptions(
        height: height,
        autoPlay: true, // Animasi Otomatis
        autoPlayInterval: const Duration(seconds: 5), // Durasi ganti slide
        viewportFraction: 1.0, // PENTING: 1.0 agar ukuran pas memenuhi container (tidak mengecil)
        enlargeCenterPage: false, // False agar tidak ada efek zoom in/out yang mengubah ukuran
        enableInfiniteScroll: true, // Bisa swipe terus menerus
        scrollPhysics: const BouncingScrollPhysics(), // Efek swipe halus
      ),
    );
  }
}

// --- 2. MAIN BANNER CARD (DESIGN KOTAK BESAR) ---
class MainBannerCard extends StatelessWidget {
  final GameModel game;
  final double height;

  const MainBannerCard({super.key, required this.game, required this.height});

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
          width: double.infinity, // Pastikan lebar memenuhi parent carousel
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Gambar Background
                CachedNetworkImage(
                  imageUrl: game.backgroundImage,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[900]),
                  errorWidget: (context, url, error) => Container(color: Colors.grey[900], child: const Icon(Icons.error)),
                ),

                // Gradient Gelap
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
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

                // Konten Teks
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
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

// --- 3. SMALL BANNER CARD (DESIGN KOTAK KECIL KANAN) ---
class SmallBannerCard extends StatelessWidget {
  final GameModel game;
  const SmallBannerCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.push('${AppRoutes.detail}/${game.id}');
        },
        child: Container(
          // Tinggi disesuaikan agar 3 item pas sejajar dengan banner utama (500px / 3 dikurangi margin)
          // 158 * 3 + 13*2 = ~500
          height: 158, 
          margin: const EdgeInsets.only(bottom: 13.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: game.backgroundImage,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[900]),
                ),
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

// --- 4. SMALL BANNER LIST (WRAPPER KANAN) ---
class SmallBannerList extends StatelessWidget {
  final List<GameModel> games;

  const SmallBannerList({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    // Pastikan hanya mengambil 3 game untuk sisi kanan
    final List<GameModel> top3Games = games.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: top3Games.map((game) => SmallBannerCard(game: game)).toList(),
    );
  }
}