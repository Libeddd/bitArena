import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bitArena/features/detail/cubit/detail_cubit.dart';
import 'package:bitArena/data/models/game_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailScreen extends StatelessWidget {
  final String gameId;
  const DetailScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    // Panggil Cubit untuk fetch data saat halaman ini dibuka
    context.read<DetailCubit>().fetchGameDetails(gameId);

    return Scaffold(
      // Menggunakan BlocBuilder untuk membangun UI berdasarkan state
      body: BlocBuilder<DetailCubit, DetailState>(
        builder: (context, state) {
          // 1. Loading State
          if (state is DetailLoading) {
            return _buildLoadingScreen();
          }

          // 2. Error State
          if (state is DetailError) {
            return _buildErrorScreen(context, state.message);
          }

          // 3. Success State
          if (state is DetailSuccess) {
            return _buildSuccessScreen(context, state.game);
          }

          return _buildLoadingScreen();
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250.0,
          floating: false,
          pinned: true,
          backgroundColor: const Color(0xFF1F1F1F),
          flexibleSpace: Shimmer.fromColors(
            baseColor: Colors.grey[850]!,
            highlightColor: Colors.grey[700]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[850]!,
                  highlightColor: Colors.grey[700]!,
                  child: Container(
                    width: 200,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: Colors.grey[850]!,
                  highlightColor: Colors.grey[700]!,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error Loading Game',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<DetailCubit>().fetchGameDetails(gameId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context, GameModel game) {
    return CustomScrollView(
      slivers: [
        // App Bar dengan gambar background yang bisa collapse
        SliverAppBar(
          expandedHeight: 300.0,
          floating: false,
          pinned: true,
          backgroundColor: const Color(0xFF1F1F1F),
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
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.broken_image, color: Colors.white, size: 50),
              ),
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Konten detail game
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating dan Info Utama
                _buildGameInfoSection(game),
                const SizedBox(height: 24),

                // Platform
                _buildPlatformSection(game),
                const SizedBox(height: 24),

                // Genres
                _buildGenreSection(game),
                const SizedBox(height: 24),

                // Release Date dan Additional Info
                _buildAdditionalInfoSection(game),
                const SizedBox(height: 32),

                // Download Button
                _buildDownloadButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameInfoSection(GameModel game) {
    return Row(
      children: [
        // Rating
        _buildInfoChip(
          icon: Icons.star,
          value: game.rating.toString(),
          label: 'Rating',
          color: Colors.amber,
        ),
        const SizedBox(width: 16),

        // Metacritic Score
        if (game.metacritic > 0)
          _buildInfoChip(
            icon: Icons.score,
            value: game.metacritic.toString(),
            label: 'Metacritic',
            color: _getMetacriticColor(game.metacritic),
          ),
        const SizedBox(width: 16),

        // Release Year
        _buildInfoChip(
          icon: Icons.calendar_today,
          value: game.releasedDate,
          label: 'Released',
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildPlatformSection(GameModel game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Platforms',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: game.platforms.map((platform) {
            return Chip(
              backgroundColor: const Color(0xFF2A2A2A),
              label: Text(
                platform,
                style: const TextStyle(color: Colors.white),
              ),
              avatar: Icon(
                _getPlatformIcon(platform),
                color: Colors.white,
                size: 16,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenreSection(GameModel game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genres',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: game.genres.map((genre) {
            return Chip(
              backgroundColor: const Color(0xFF2A2A2A),
              label: Text(
                genre,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection(GameModel game) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Information',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Community Rating', '${game.rating}/5'),
          _buildInfoRow('Metacritic Score', game.metacritic > 0 ? game.metacritic.toString() : 'N/A'),
          _buildInfoRow('Release Date', game.releasedDate),
          _buildInfoRow('Added by Users', '${game.added} users'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement download functionality
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download_rounded),
            const SizedBox(width: 8),
            Text(
              'Download Game',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMetacriticColor(int score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.yellow;
    return Colors.red;
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'pc':
      case 'windows':
        return FontAwesomeIcons.windows;
      case 'playstation':
      case 'ps4':
      case 'ps5':
        return FontAwesomeIcons.playstation;
      case 'xbox':
        return FontAwesomeIcons.xbox;
      case 'nintendo':
      case 'switch':
        return FontAwesomeIcons.gamepad;
      case 'linux':
        return FontAwesomeIcons.linux;
      case 'apple':
      case 'macos':
        return FontAwesomeIcons.apple;
      default:
        return FontAwesomeIcons.gamepad;
    }
  }
}