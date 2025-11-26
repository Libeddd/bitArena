// File: lib/features/detail/screens/detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bitarena/app/app_routes.dart'; // Import Routes
import 'package:bitarena/features/detail/cubit/detail_cubit.dart';
import 'package:bitarena/data/models/game_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailScreen extends StatelessWidget {
  final String gameId;
  const DetailScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    context.read<DetailCubit>().fetchGameDetails(gameId);

    return Scaffold(
      body: BlocBuilder<DetailCubit, DetailState>(
        builder: (context, state) {
          if (state is DetailLoading) return _buildLoadingScreen();
          if (state is DetailError) return _buildErrorScreen(context, state.message);
          if (state is DetailSuccess) return _buildSuccessScreen(context, state.game);
          return _buildLoadingScreen();
        },
      ),
    );
  }

  // --- LOADING & ERROR SCREEN ---
  Widget _buildLoadingScreen() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250.0,
          backgroundColor: const Color(0xFF1F1F1F),
          flexibleSpace: Shimmer.fromColors(
            baseColor: Colors.grey[850]!,
            highlightColor: Colors.grey[700]!,
            child: Container(color: Colors.grey[850]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Shimmer.fromColors(
               baseColor: Colors.grey[850]!,
               highlightColor: Colors.grey[700]!,
               child: Container(height: 100, color: Colors.grey[850]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF1F1F1F)),
      body: Center(child: Text("Error: $message", style: const TextStyle(color: Colors.white))),
    );
  }
  // ----------------------------------------------

  Widget _buildSuccessScreen(BuildContext context, GameModel game) {
    return CustomScrollView(
      slivers: [
        // HEADER GAMBAR
        SliverAppBar(
          expandedHeight: 300.0,
          floating: false,
          pinned: true,
          backgroundColor: const Color(0xFF121212),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              game.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 5, color: Colors.black.withOpacity(0.8))],
              ),
            ),
            background: CachedNetworkImage(
              imageUrl: game.backgroundImage,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.4),
              colorBlendMode: BlendMode.darken,
            ),
          ),
        ),

        // KONTEN UTAMA
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // 1. ABOUT SECTION
                Text(
                  "About",
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                _ExpandableText(text: game.description),
                
                const SizedBox(height: 32),

                // 2. GRID INFO SECTION
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- KOLOM KIRI ---
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // PLATFORMS (BISA DIKLIK)
                          _buildGridItem(
                            label: "Platforms",
                            child: _buildClickableRow(
                              context: context,
                              items: game.detailedPlatforms,
                              isPlatform: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // GENRE (BISA DIKLIK)
                          _buildGridItem(
                            label: "Genre",
                            child: _buildClickableRow(
                              context: context,
                              items: game.detailedGenres,
                              isPlatform: false,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildGridItem(
                            label: "Developer",
                            child: _buildSimpleText(game.developers.isNotEmpty ? game.developers.join(', ') : 'Unknown'),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildGridItem(
                            label: "Age rating",
                            child: _buildSimpleText(game.esrbRating),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),

                    // --- KOLOM KANAN ---
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGridItem(
                            label: "Metascore",
                            child: _buildMetascoreBox(game.metacritic),
                          ),
                          const SizedBox(height: 16),
                          _buildGridItem(
                            label: "Release date",
                            child: _buildSimpleText(game.releasedDate),
                          ),
                          const SizedBox(height: 16),
                          _buildGridItem(
                            label: "Publisher",
                            child: _buildSimpleText(game.publishers.isNotEmpty ? game.publishers.join(', ') : 'Unknown'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                
                // 3. SYSTEM REQUIREMENTS
                _buildSystemRequirementsSection(game),

                const SizedBox(height: 40),
                _buildDownloadButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET HELPER ---
  
  Widget _buildGridItem({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

  // Widget Teks Biasa (Untuk Dev, Publisher, Date)
  Widget _buildSimpleText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        decoration: TextDecoration.underline, 
        decorationColor: Colors.white,
        decorationThickness: 1.5,
        height: 1.3,
      ),
    );
  }

  // --- LOGIKA KLIK (NAVIGASI) ---
  Widget _buildClickableRow({
    required BuildContext context,
    required List<Map<String, dynamic>> items,
    required bool isPlatform,
  }) {
    if (items.isEmpty) return _buildSimpleText("Unknown");

    return Wrap(
      spacing: 4,
      children: items.asMap().entries.map((entry) {
        final int index = entry.key;
        final Map<String, dynamic> item = entry.value;
        final String name = item['name'];
        final bool isLast = index == items.length - 1;

        return InkWell(
          onTap: () {
            // Logika Filter
            final Map<String, String> filters = {};
            String title = "";

            if (isPlatform) {
              // Filter by Parent Platform ID
              filters['parent_platforms'] = item['id'].toString();
              title = "$name Games";
            } else {
              // Filter by Genre Slug
              filters['genres'] = item['slug'];
              title = "$name Games";
            }

            // Navigasi ke BrowseScreen
            context.pushNamed(
              AppRoutes.browse,
              queryParameters: {
                'title': title,
                ...filters,
              },
            );
          },
          child: Text(
            "$name${isLast ? '' : ','}", // Tambah koma kecuali item terakhir
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
              decorationThickness: 1.5,
              height: 1.3,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetascoreBox(int score) {
    if (score == 0) return const Text("N/A", style: TextStyle(color: Colors.white));
    Color color = score >= 75 ? const Color(0xFF6DC849) : (score >= 50 ? Colors.yellow : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        score.toString(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildSystemRequirementsSection(GameModel game) {
    if (game.pcRequirements['minimum']!.isEmpty && game.pcRequirements['recommended']!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("System requirements for PC", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF202020), borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (game.pcRequirements['minimum']!.isNotEmpty) ...[
                 Text("Minimum:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                 const SizedBox(height: 4),
                 Text(game.pcRequirements['minimum']!, style: const TextStyle(color: Colors.grey, height: 1.5, fontSize: 13)),
                 const SizedBox(height: 16),
              ],
              if (game.pcRequirements['recommended']!.isNotEmpty) ...[
                 Text("Recommended:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                 const SizedBox(height: 4),
                 Text(game.pcRequirements['recommended']!, style: const TextStyle(color: Colors.grey, height: 1.5, fontSize: 13)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download_rounded),
            const SizedBox(width: 8),
            Text('Download Game', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// --- EXPANDABLE TEXT ---
class _ExpandableText extends StatefulWidget {
  final String text;
  const _ExpandableText({required this.text});
  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.topCenter,
          child: Text(
            widget.text,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
            maxLines: _isExpanded ? null : 4,
            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.fade,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Text(
              _isExpanded ? "Show less" : "Show more",
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }
}