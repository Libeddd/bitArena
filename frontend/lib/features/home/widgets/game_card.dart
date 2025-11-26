// File: lib/features/home/widgets/game_card.dart (REVISI TOTAL)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bitarena/app/app_routes.dart';
import 'package:bitarena/data/models/game_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// --- UBAH JADI STATELESSWIDGET ---
class GameCard extends StatelessWidget {
  final GameModel game;
  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRoutes.detail,
          pathParameters: {
            'id': game.id.toString(),
          },
        );
      },
      child: Container(
        // --- UI KARTU BARU ---
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F), // Latar belakang kartu
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. GAMBAR (Bentuk Kotak 1:1) ---
            AspectRatio(
              aspectRatio: 1 / 1, // Gambar kotak
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: CachedNetworkImage(
                  imageUrl: game.backgroundImage,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[800]),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: Icon(Icons.broken_image, color: Colors.grey[600]),
                  ),
                ),
              ),
            ),

            // --- 2. KONTEN TEKS & RATING ---
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    game.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  Text(
                    game.mainGenre,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // --- 3. RATING BINTANG ---
                  RatingBarIndicator(
                    rating: game.rating, // Rating dari API (skala 0-5)
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Colors.grey[600], // Warna bintang abu-abu
                    ),
                    itemCount: 5,
                    itemSize: 16.0,
                    unratedColor: Colors.grey[800],
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