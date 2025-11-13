// File: lib/features/home/widgets/home_sidebar_list.dart (REVISI)

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bitArena/data/models/game_model.dart';

// --- TAMBAHKAN DUA IMPORT INI ---
import 'package:go_router/go_router.dart';
import 'package:bitArena/app/app_routes.dart';

class HomeSidebarList extends StatelessWidget {
  final List<GameModel> games;
  const HomeSidebarList({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1F1F1F), // Warna latar belakang
      borderRadius: BorderRadius.circular(12), // Bentuk sudut
      clipBehavior: Clip.antiAlias, // Penting agar 'ListView' tidak tembus
      
      child: ListView.builder(
        // Pindahkan padding ke dalam ListView
        padding: const EdgeInsets.all(8.0), 
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          // _SidebarItem (yang berisi InkWell) sekarang akan
          // mendeteksi 'Material' ini dan bisa menampilkan hover.
          return _SidebarItem(game: game);
        },
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final GameModel game;
  const _SidebarItem({required this.game});

  @override
  Widget build(BuildContext context) {
    // --- GANTI PADDING DENGAN INKWELL ---
    return InkWell(
      // --- PERMINTAAN 2: Navigasi ke Detail Game ---
      onTap: () {
        context.push('${AppRoutes.detail}/${game.id}');
      },
      // --- PERMINTAAN 3: Warna Abu-abu saat Hover ---
      hoverColor: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      
      // Bungkus Row dengan Padding agar ada jarak
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Row(
          children: [
            // Gambar kecil
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: game.backgroundImage,
                fit: BoxFit.cover,
                width: 50,
                height: 65,
                placeholder: (context, url) => Container(color: Colors.grey[800]),
              ),
            ),
            const SizedBox(width: 12),
            // Judul Game
            Expanded(
              child: Text(
                game.name,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}