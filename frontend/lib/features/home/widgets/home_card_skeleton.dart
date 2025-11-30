import 'package:flutter/material.dart';

class HomeCardSkeleton extends StatelessWidget {
  const HomeCardSkeleton({super.key});

  // Widget helper untuk membuat kotak skeleton
  Widget _buildSkeletonBox({
    double? width, 
    required double height, 
    double radius = 4
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[800], 
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ini adalah bentuk kartu Anda
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // --- 1. Skeleton untuk Gambar (16:9) ---
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF3A3A3A), // Abu-abu lebih gelap untuk gambar
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
            ),
          ),
          
          // --- 2. Skeleton untuk Konten Teks ---
          Padding(
            padding: const EdgeInsets.all(12.0), // Samakan dengan padding kartu asli
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skeleton untuk Platform & Skor
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSkeletonBox(width: 80, height: 16), // Ikon platform
                    _buildSkeletonBox(width: 30, height: 20), // Skor
                  ],
                ),
                const SizedBox(height: 12),
                
                // Skeleton untuk Judul Game
                _buildSkeletonBox(width: 200, height: 18),
                const SizedBox(height: 12),
                
                // Skeleton untuk '+ 3793'
                _buildSkeletonBox(width: 60, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}