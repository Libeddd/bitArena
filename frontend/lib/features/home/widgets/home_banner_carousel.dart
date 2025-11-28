// File: lib/features/home/widgets/home_banner_carousel.dart (FINAL REVISI)

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
// Dipertahankan untuk CarouselOptions (jika dibutuhkan di masa depan)
import 'package:bitarena/data/models/game_model.dart'; 
import 'package:flutter/material.dart' hide CarouselController;
import 'package:go_router/go_router.dart';
import 'package:bitarena/app/app_routes.dart'; 

// Hapus widget HomeBannerCarousel, karena tidak lagi digunakan sebagai carousel
// dan kita akan menggunakan widget MainBannerCard dan SmallBannerList secara langsung.

// Widget yang sudah diubah namanya menjadi public (menghapus underscore)
class MainBannerCard extends StatelessWidget {
  final GameModel game;
  final double height;
  
  // Ubah key agar sesuai dengan penggunaan di home_screen.dart
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0), // Tambahkan radius agar sesuai dengan gambar
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

                // 3. Konten Teks
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

// Widget baru untuk daftar game kecil di sebelah kanan (Diubah namanya menjadi public)
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
          height: 128, // Sesuaikan tinggi sedikit agar 3 item pas 400px (128*3 + 8*2 = 400)
          margin: const EdgeInsets.only(bottom: 8.0), 
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0), 
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
    // Karena kita hanya ingin menampilkan 3, pastikan listnya hanya 3.
    final List<GameModel> top3Games = games.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      // Menggunakan SmallBannerCard (yang sudah public)
      children: top3Games.map((game) => SmallBannerCard(game: game)).toList(),
    );
  }
}