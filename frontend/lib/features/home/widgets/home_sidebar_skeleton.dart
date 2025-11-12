// File: lib/features/home/widgets/home_sidebar_skeleton.dart (FILE BARU)

import 'package:flutter/material.dart';

class HomeSidebarSkeleton extends StatelessWidget {
  const HomeSidebarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Latar belakang gelap seperti sidebar asli
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      // Kita buat 5 item placeholder
      child: Column(
        children: List.generate(5, (_) => const _SkeletonItem()),
      ),
    );
  }
}

// Widget privat untuk satu item skeleton
class _SkeletonItem extends StatelessWidget {
  const _SkeletonItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          // Placeholder untuk gambar (50x65)
          Container(
            width: 50,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.grey[850], // Warna dasar Shimmer
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          // Placeholder untuk teks
          Expanded(
            child: Container(
              height: 14,
              color: Colors.grey[850], // Warna dasar Shimmer
            ),
          ),
        ],
      ),
    );
  }
}