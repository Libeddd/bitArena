// File: lib/features/home/widgets/home_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bitarena/app/app_routes.dart';
import 'package:bitarena/data/models/game_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeCard extends StatefulWidget {
  final GameModel game;
  const HomeCard({super.key, required this.game});

  @override
  State<HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> {
  bool _isHovered = false;
  bool _isExpanded = false; // State untuk toggle expand details

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF202020),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: _isHovered
              ? [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 15, offset: const Offset(0, 8))]
              : [],
        ),
        child: GestureDetector(
          onTap: () {
            context.push('${AppRoutes.detail}/${widget.game.id}');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. GAMBAR COVER
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.game.backgroundImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(color: Colors.grey[800]),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: Icon(Icons.broken_image, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),

              // 2. KONTEN
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF202020),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Penting agar tidak overflow
                  children: [
                    // Platform Icons & Metascore (Opsional, disembunyikan jika collapsed agar rapi)
                    if (!_isExpanded) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _PlatformIcons(platforms: widget.game.platforms),
                          if (widget.game.metacritic > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green, width: 1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.game.metacritic.toString(),
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Judul Game
                    Text(
                      widget.game.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Ukuran font judul
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),

                    // Baris Tombol (+ Add) dan (Panah Expand)
                    Row(
                      children: [
                        // Tombol Plus / Added Count
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.add, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                widget.game.added.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(),

                        // --- TOMBOL PANAH INTERAKTIF ---
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Icon(
                            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),

                    // --- BAGIAN DETAIL YANG BISA DI-EXPAND ---
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: _isExpanded
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                // Divider halus
                                Divider(color: Colors.grey[800], height: 1),
                                const SizedBox(height: 12),
                                
                                // Release Date
                                _buildInfoRow("Release Date:", widget.game.releasedDate),
                                const SizedBox(height: 6),
                                
                                // Genres
                                _buildInfoRow("Genres:", widget.game.genres.take(2).join(", ")),
                              ],
                            )
                          : const SizedBox.shrink(), // Jika tidak expanded, ukurannya 0
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

  // Helper Widget untuk Baris Info (Date/Genre)
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

class _PlatformIcons extends StatelessWidget {
  final List<String> platforms;
  const _PlatformIcons({required this.platforms});
  
  IconData _getIconForPlatform(String platformName) {
    final p = platformName.toLowerCase();
    if (p.contains('pc') || p.contains('windows')) return FontAwesomeIcons.windows;
    if (p.contains('playstation') || p.contains('ps')) return FontAwesomeIcons.playstation;
    if (p.contains('xbox')) return FontAwesomeIcons.xbox;
    if (p.contains('switch')) return FontAwesomeIcons.gamepad;
    if (p.contains('mac') || p.contains('apple')) return FontAwesomeIcons.apple;
    if (p.contains('linux')) return FontAwesomeIcons.linux;
    if (p.contains('android')) return FontAwesomeIcons.android;
    if (p.contains('ios')) return FontAwesomeIcons.appStoreIos;
    return FontAwesomeIcons.gamepad;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: platforms.take(4).map((platform) => Padding(
        padding: const EdgeInsets.only(right: 6.0),
        child: Icon(_getIconForPlatform(platform), color: Colors.white, size: 14),
      )).toList(),
    );
  }
}