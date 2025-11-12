import 'package:flutter/material.dart';

class GameCardSkeleton extends StatelessWidget {
  const GameCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Kartu ini hanya kotak abu-abu dengan sudut tumpul
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}