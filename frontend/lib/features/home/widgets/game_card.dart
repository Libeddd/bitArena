// File: lib/features/home/widgets/game_card.dart (REVISI TOTAL)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bitArena/app/app_routes.dart';
import 'package:bitArena/data/models/game_model.dart';
import 'dart:ui'; // Import untuk BackdropFilter

class GameCard extends StatefulWidget {
  final GameModel game;
  const GameCard({super.key, required this.game});

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _isHovered = false;

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.push('${AppRoutes.detail}/${widget.game.id}');
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          // Stack digunakan untuk menumpuk gambar dan overlay
          child: Stack(
            fit: StackFit.expand,
            children: [
              // --- 1. GAMBAR (Paling Bawah) ---
              CachedNetworkImage(
                imageUrl: widget.game.backgroundImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[900]),
                errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
              ),

              // --- 2. EFEK BLUR SAAT HOVER ---
              // Tampil/Sembunyi overlay secara animasi
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isHovered ? 1.0 : 0.0,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                  child: Container(
                    // Gradient gelap agar teks terbaca
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // --- 3. KONTEN OVERLAY (Paling Atas) ---
              // Tampil/Sembunyi overlay secara animasi
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isHovered ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      // --- Bagian Atas: Kategori & Versi ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Kategori (cth: "Horror")
                          _InfoTag(text: widget.game.mainGenre),
                          // Versi (Placeholder)
                          _InfoTag(text: 'v1.0.0', color: Colors.green),
                        ],
                      ),
                      
                      const Spacer(), // Mendorong ke tengah & bawah

                      // --- Bagian Tengah: Ikon Download ---
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: const Icon(Icons.download_rounded, size: 30, color: Colors.white),
                      ),
                      
                      const Spacer(), // Mendorong ke bawah

                      // --- Bagian Bawah: Info Game ---
                      // Judul
                      Text(
                        widget.game.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Tahun & Ukuran
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(widget.game.releasedDate, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 16),
                          const Icon(Icons.star, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(widget.game.rating.toString(),style: const TextStyle(color: Colors.grey)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget helper untuk Tag Kategori & Versi
class _InfoTag extends StatelessWidget {
  final String text;
  final Color? color;

  const _InfoTag({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color ?? Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}