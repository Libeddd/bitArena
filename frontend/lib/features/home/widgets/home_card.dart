import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/app/app_routes.dart';
import 'package:frontend/data/models/game_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeCard extends StatelessWidget {
  final GameModel game;
  const HomeCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('${AppRoutes.detail}/${game.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. GAMBAR (Bagian Atas) ---
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
              
              // --- INI PERBAIKANNYA ---
              // 1. Kita bungkus dengan 'AspectRatio'
              child: AspectRatio(
                aspectRatio: 16 / 9,
                // 2. 'CachedNetworkImage' sekarang ada di dalamnya
                child: CachedNetworkImage(
                  imageUrl: game.backgroundImage,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  
                  // --- PERBAIKAN: errorWidget yang lebih jelas ---
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[700],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, color: Colors.white, size: 40),
                          SizedBox(height: 8),
                          Text('Image failed to load', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PlatformIcons(platforms: game.platforms),
                      _MetacriticScore(score: game.metacritic),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    game.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.add, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        game.added.toString(),
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- (Sisa kode _MetacriticScore dan _PlatformIcons tidak berubah) ---

class _MetacriticScore extends StatelessWidget {
  final int score;
  const _MetacriticScore({required this.score});
  // ... (kode helper)
  Color _getScoreColor(int score) {
    if (score > 75) return Colors.green;
    if (score > 50) return Colors.yellow;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (score == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: _getScoreColor(score).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: _getScoreColor(score), width: 1),
      ),
      child: Text(
        score.toString(),
        style: TextStyle(
          color: _getScoreColor(score),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _PlatformIcons extends StatelessWidget {
  final List<String> platforms;
  const _PlatformIcons({required this.platforms});
  IconData _getIconForPlatform(String platformName) {
  switch (platformName.toLowerCase()) {
    case 'pc':
    case 'windows':
    case 'microsoft windows':
      return FontAwesomeIcons.windows;

    case 'playstation':
    case 'ps4':
    case 'ps5':
      return FontAwesomeIcons.playstation;

    case 'xbox':
    case 'xbox one':
    case 'xbox series x':
      return FontAwesomeIcons.xbox;

    default:
      return FontAwesomeIcons.gamepad;
  }
}

  @override
  Widget build(BuildContext context) {
    return Row(
      children: platforms
          .take(4)
          .map((platform) => Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Icon(
                  _getIconForPlatform(platform),
                  color: Colors.white,
                  size: 16,
                ),
              ))
          .toList(),
    );
  }
}