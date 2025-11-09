// File: lib/features/home/widgets/home_banner_carousel.dart (REVISI)

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:frontend/data/models/game_model.dart'; // Ganti 'frontend' dengan nama project Anda
import 'package:flutter/material.dart' hide CarouselController;

// --- Impor yang benar ---
import 'package:go_router/go_router.dart';
import 'package:frontend/app/app_routes.dart'; // Ganti 'frontend' dengan nama project Anda

class HomeBannerCarousel extends StatelessWidget {
  final List<GameModel> games;
  const HomeBannerCarousel({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: games.length,
      itemBuilder: (context, index, realIndex) {
        final game = games[index];
        return _BannerCard(game: game);
      },
      options: CarouselOptions(
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        aspectRatio: 16 / 9,
        viewportFraction: 0.9,
        enlargeCenterPage: true,
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final GameModel game;
  const _BannerCard({required this.game});

  @override
  Widget build(BuildContext context) {
    // --- KEMBALIKAN KE GESTUREDETECTOR ---
    // Ini adalah widget yang tepat untuk banner besar
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
        context.push('${AppRoutes.detail}/${game.id}');
      },
      // Child-nya adalah ClipRRect (bukan bagian dari InkWell)
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // 3. Konten Teks
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Experience Mind-Blowing Co-op. Save on Split Fiction.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    onPressed: () {
                       context.push('${AppRoutes.detail}/${game.id}');
                    },
                    child: const Text(
                      "Save Now",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}