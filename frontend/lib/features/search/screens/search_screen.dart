import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bitArena/features/home/widgets/game_card.dart'; // Kita pakai ulang GameCard
import 'package:bitArena/features/search/bloc/search_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:bitArena/features/home/widgets/game_card_skeleton.dart';

class SearchScreen extends StatelessWidget {
  // Kita terima query dari GoRouter
  final String query;
  const SearchScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    // Panggil BLoC untuk mulai mencari
    context.read<SearchBloc>().add(PerformSearch(query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('MaininAja'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // <-- Rata kiri
          children: [
            
            // --- 1. JUDUL "Search Result for..." (Sekarang Rata Kiri) ---
            Padding(
              // Beri padding horizontal agar tidak mepet layar
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(
                "Search Result for ''$query''",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16.0),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[850]!,
                        highlightColor: Colors.grey[700]!,
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 180,
                            childAspectRatio: 2 / 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: 12, // Tampilkan 12 skeleton
                          itemBuilder: (context, index) {
                            return const GameCardSkeleton();
                          },
                        ),
                      );
                    }
                if (state is SearchError) {
                  return Center(child: Text('Gagal memuat data: ${state.message}'));
                }
                if (state is SearchSuccess) {
                  if (state.games.isEmpty) {
                    return const Center(child: Text('Game tidak ditemukan.'));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 2 / 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: state.games.length,
                    itemBuilder: (context, index) {
                      final game = state.games[index];
                      // Kita pakai ulang GameCard yang sudah ada
                      return GameCard(game: game);
                    },
                      );
                    }
                    return const SizedBox.shrink(); // State awal (Initial)
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}