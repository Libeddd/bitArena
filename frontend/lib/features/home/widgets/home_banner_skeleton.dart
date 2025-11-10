// File: lib/features/home/widgets/home_banner_skeleton.dart (FILE BARU)

import 'package:flutter/material.dart';

class HomeBannerSkeleton extends StatelessWidget {
  const HomeBannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Ini adalah kotak placeholder untuk banner
    // Warna akan diatur oleh Shimmer
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}