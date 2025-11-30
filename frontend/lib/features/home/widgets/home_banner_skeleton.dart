// File: lib/features/home/widgets/home_banner_skeleton.dart

import 'package:flutter/material.dart';

class HomeBannerSkeleton extends StatelessWidget {
  const HomeBannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 800;

        if (isDesktop) {
          // --- LAYOUT DESKTOP (ROW) ---
          return SizedBox(
            height: 520, // Tinggi total
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Besar Kiri
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 500,
                    decoration: BoxDecoration(
                      color: Colors.grey[850], // Warna dasar Shimmer
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // List Kanan (3 Item Vertikal)
                Expanded(
                  flex: 1,
                  child: Column(
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[850],
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        } else {
          // --- LAYOUT MOBILE (COLUMN) ---
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Besar Atas
              Container(
                height: 380,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              
              // List Bawah (Horizontal)
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(), // Tidak perlu scroll saat loading
                  itemCount: 3, // Tampilkan 3 dummy
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return Container(
                      width: 130, // Lebar sama dengan SmallBannerCard Mobile
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}