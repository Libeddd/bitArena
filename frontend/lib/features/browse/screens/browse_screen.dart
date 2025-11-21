// File: lib/features/browse/screens/browse_screen.dart (FILE BARU)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bitarena/features/browse/bloc/browse_bloc.dart';
import 'package:bitarena/features/home/widgets/home_card.dart'; // <-- UI KARTU BARU ANDA
import 'package:bitarena/features/home/widgets/home_card_skeleton.dart'; // <-- UI SKELETON
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

class BrowseScreen extends StatefulWidget {
  final String title;
  final Map<String, dynamic> filters;

  const BrowseScreen({
    super.key,
    required this.title,
    required this.filters,
  });

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Panggil BLoC untuk mulai mencari
    context.read<BrowseBloc>().add(FetchFilteredGames(widget.filters));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentState = context.read<BrowseBloc>().state;
    if (currentState is BrowseSuccess) {
      if (_scrollController.position.extentAfter < 300) {
        context.read<BrowseBloc>().add(FetchMoreFilteredGames());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'bitArena',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Center( // <-- BUNGKUS DENGAN CENTER
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    fontSize: 32, // Ukuran font besar
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Konten Grid
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: BlocBuilder<BrowseBloc, BrowseState>(
                  builder: (context, state) {
                    if (state is BrowseLoading || state is BrowseInitial) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[850]!,
                        highlightColor: Colors.grey[700]!,
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            childAspectRatio: 1.05,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: 12,
                          itemBuilder: (context, index) {
                            // Panggil skeleton Anda
                            return const HomeCardSkeleton(); 
                          },
                        ),
                      );
                    }
                    if (state is BrowseError) {
                      return Center(child: Text('Gagal memuat data: ${state.message}'));
                    }
                    if (state is BrowseSuccess) {
                      if (state.games.isEmpty) {
                        return const Center(child: Text('Game tidak ditemukan.'));
                      }
                      
                      return Column(
                        children: [
                          GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              childAspectRatio: 1.05,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: state.games.length,
                            itemBuilder: (context, index) {
                              final game = state.games[index];
                              // Panggil kartu Anda
                              return HomeCard(game: game); 
                            },
                          ),
                          if (state.isLoadingMore && !state.hasReachedMax)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
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