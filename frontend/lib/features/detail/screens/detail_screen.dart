// File: lib/features/detail/screens/detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bitarena/app/app_routes.dart';
import 'package:bitarena/features/detail/cubit/detail_cubit.dart';
import 'package:bitarena/data/models/game_model.dart';
import 'package:bitarena/features/wishlist/cubit/wishlist_cubit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatefulWidget {
  final String gameId;
  const DetailScreen({super.key, required this.gameId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DetailCubit>().fetchGameDetails(widget.gameId);
  }

  void _handleWishlistToggle(BuildContext context, GameModel game, bool isCurrentlyWishlisted) {
    context.read<WishlistCubit>().toggleWishlist(game);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !isCurrentlyWishlisted ? "Added to Wishlist" : "Removed from Wishlist",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: !isCurrentlyWishlisted ? Colors.green : Colors.redAccent,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _playVideo(BuildContext context, String? videoUrl, String gameName) async {
    if (videoUrl != null && videoUrl.isNotEmpty) {
      final Uri uri = Uri.parse(videoUrl);
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showErrorSnack("Could not launch video player");
        }
      } catch (e) {
        _showErrorSnack("Error: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("No official trailer. Search on YouTube?"),
          action: SnackBarAction(
            label: "Search",
            textColor: Colors.amber,
            onPressed: () async {
              final query = Uri.encodeComponent("$gameName trailer");
              final ytUrl = Uri.parse("https://www.youtube.com/results?search_query=$query");
              if (await canLaunchUrl(ytUrl)) {
                await launchUrl(ytUrl, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ),
      );
    }
  }

  // Update: Membuka Gallery dengan Widget Baru
  void _openFullScreenGallery(BuildContext context, List<String> images, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenGallery(images: images, initialIndex: index),
      ),
    );
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: BlocBuilder<DetailCubit, DetailState>(
        builder: (context, state) {
          if (state is DetailLoading) return _buildLoadingScreen();
          if (state is DetailError) return _buildErrorScreen(context, state.message);
          if (state is DetailSuccess) return _buildSuccessContent(context, state.game);
          return _buildLoadingScreen();
        },
      ),
    );
  }

  Widget _buildSuccessContent(BuildContext context, GameModel game) {
    final String? videoToPlay = game.trailerUrl ?? game.clip;

    return Stack(
      children: [
        // 1. BACKGROUND IMAGE
        Positioned(
          top: 0, left: 0, right: 0, height: 500,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: game.backgroundImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.black),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      const Color(0xFF121212).withOpacity(0.8),
                      const Color(0xFF121212),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. KONTEN
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                _buildHeaderInfo(game),
                const SizedBox(height: 10),
                Text(game.name, style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1)),
                const SizedBox(height: 24),
                
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isDesktop = constraints.maxWidth > 800;
                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildActionButtons(game), const SizedBox(height: 32), _buildRatingsSection(game), const SizedBox(height: 32), _buildAboutSection(game), const SizedBox(height: 32), _buildSpecsAndDetails(game)])),
                          const SizedBox(width: 40),
                          Expanded(flex: 3, child: _buildMediaGallery(game, videoToPlay)),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildActionButtons(game),
                          const SizedBox(height: 32),
                          _buildMediaGallery(game, videoToPlay),
                          const SizedBox(height: 32),
                          _buildRatingsSection(game),
                          const SizedBox(height: 32),
                          _buildAboutSection(game),
                          const SizedBox(height: 32),
                          _buildSpecsAndDetails(game),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 40),
                _buildDownloadButton(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),

        // 3. BACK BUTTON
        Positioned(
          top: 40, left: 16,
          child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28), onPressed: () => context.pop()),
        ),
      ],
    );
  }

  // --- WIDGETS ---
  Widget _buildHeaderInfo(GameModel game) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12, runSpacing: 12,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          child: Text(game.releasedDate.toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: game.platforms.take(4).map((p) => Padding(padding: const EdgeInsets.only(right: 8.0), child: Icon(_getPlatformIcon(p), color: Colors.white, size: 16))).toList(),
        ),
        if (game.playtime > 0) Text("AVERAGE PLAYTIME: ${game.playtime} HOURS", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
      ],
    );
  }

  Widget _buildActionButtons(GameModel game) {
    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, state) {
        final isWishlisted = context.read<WishlistCubit>().isWishlisted(game.id);
        return OutlinedButton(
          onPressed: () => _handleWishlistToggle(context, game, isWishlisted),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: isWishlisted ? Colors.redAccent : Colors.white24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isWishlisted ? "In Wishlist" : "Add to Wishlist", style: TextStyle(color: isWishlisted ? Colors.redAccent : Colors.white)),
              const SizedBox(width: 8),
              Icon(isWishlisted ? Icons.favorite : Icons.favorite_border, size: 20, color: isWishlisted ? Colors.redAccent : Colors.white),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDownloadButton() {
    return SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.download_rounded), const SizedBox(width: 8), Text('Download Game', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16))])));
  }

  Widget _buildRatingsSection(GameModel game) {
    List<Map<String, dynamic>> ratings = game.ratingsDistribution;
    if (ratings.isEmpty) {
      if (game.rating > 4.5) ratings = [{'title': 'Exceptional', 'percent': 70.0, 'id': 5}, {'title': 'Recommended', 'percent': 20.0, 'id': 4}, {'title': 'Meh', 'percent': 5.0, 'id': 3}, {'title': 'Skip', 'percent': 5.0, 'id': 1}];
      else ratings = [{'title': 'Recommended', 'percent': 60.0, 'id': 4}, {'title': 'Meh', 'percent': 30.0, 'id': 3}, {'title': 'Skip', 'percent': 10.0, 'id': 1}];
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(_getRatingTitle(game.rating), style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(width: 8), Icon(_getRatingIcon(game.rating), color: Colors.amber, size: 24), const SizedBox(width: 16), Text("${game.rating} Rating", style: const TextStyle(color: Colors.white54, fontSize: 14, decoration: TextDecoration.underline, decorationColor: Colors.white54))]), const SizedBox(height: 16), ClipRRect(borderRadius: BorderRadius.circular(4), child: SizedBox(height: 50, child: Row(children: ratings.map((r) => Expanded(flex: (r['percent'] as double).toInt() == 0 ? 1 : (r['percent'] as double).toInt(), child: Container(color: _getRatingColor(r['id'])))).toList()))), const SizedBox(height: 12), Wrap(spacing: 16, runSpacing: 8, children: ratings.map((r) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, color: _getRatingColor(r['id']), size: 10), const SizedBox(width: 6), Text(r['title'].toString().capitalize(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(width: 4), Text("${r['count'] ?? ''}", style: const TextStyle(color: Colors.white54))])).toList())]);
  }

  Widget _buildMediaGallery(GameModel game, String? videoUrl) {
    final List<String> images = game.screenshots.isNotEmpty ? game.screenshots : [game.backgroundImage];
    final String videoThumb = images.first;
    final List<String> gridImages = images.length > 1 ? images.sublist(1) : [];

    return Column(children: [
      InkWell(onTap: () => _playVideo(context, videoUrl, game.name), child: Container(height: 200, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: CachedNetworkImageProvider(videoThumb), fit: BoxFit.cover)), child: Stack(children: [Container(color: Colors.black26), Center(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.9), shape: BoxShape.circle), child: const Icon(Icons.play_arrow, color: Colors.white, size: 32))), if (videoUrl == null) Positioned(bottom: 8, left: 8, child: Container(padding: const EdgeInsets.all(4), color: Colors.black54, child: const Text("No Official Trailer", style: TextStyle(color: Colors.white, fontSize: 10))))]))),
      const SizedBox(height: 12),
      if (gridImages.isNotEmpty) GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 16/9), itemCount: gridImages.length > 4 ? 4 : gridImages.length, itemBuilder: (context, index) => InkWell(onTap: () => _openFullScreenGallery(context, images, index + 1), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: gridImages[index], fit: BoxFit.cover, placeholder: (c, u) => Container(color: Colors.grey[900])))))
    ]);
  }

  Widget _buildAboutSection(GameModel game) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("About", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(height: 8), _ExpandableText(text: game.description)]);
  Widget _buildSpecsAndDetails(GameModel game) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildDetailRow("Platforms", _buildFilterButtons(context: context, items: game.detailedPlatforms, isPlatform: true)), const SizedBox(height: 16), _buildDetailRow("Genres", _buildFilterButtons(context: context, items: game.detailedGenres, isPlatform: false)), const SizedBox(height: 16), _buildDetailRow("Developer", _buildSimpleText(game.developers.join(', '))), const SizedBox(height: 16), _buildDetailRow("Publisher", _buildSimpleText(game.publishers.join(', '))), const SizedBox(height: 32), if (game.pcRequirements['minimum']!.isNotEmpty) ...[Text("System requirements for PC", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(height: 12), Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF202020), borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Minimum:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)), Text(game.pcRequirements['minimum']!, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5)), const SizedBox(height: 16), if (game.pcRequirements['recommended']!.isNotEmpty) ...[Text("Recommended:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)), Text(game.pcRequirements['recommended']!, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5))]])) ]]);
  Widget _buildDetailRow(String label, Widget child) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 100, child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14))), Expanded(child: child)]);
  Widget _buildSimpleText(String text) => Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4));
  Widget _buildFilterButtons({required BuildContext context, required List<Map<String, dynamic>> items, required bool isPlatform}) {if (items.isEmpty) return _buildSimpleText("Unknown"); return Wrap(spacing: 6, runSpacing: 6, children: items.map((item) => InkWell(onTap: () {final Map<String, String> filters = {}; if (isPlatform) filters['parent_platforms'] = item['id'].toString(); else filters['genres'] = item['slug']; context.pushNamed(AppRoutes.browse, queryParameters: {'title': "${item['name']} Games", ...filters});}, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(4)), child: Text(item['name'], style: const TextStyle(color: Colors.white, fontSize: 12))))).toList());}
  IconData _getPlatformIcon(String platform) {final p = platform.toLowerCase(); if (p.contains('pc') || p.contains('windows')) return FontAwesomeIcons.windows; if (p.contains('playstation') || p.contains('ps')) return FontAwesomeIcons.playstation; if (p.contains('xbox')) return FontAwesomeIcons.xbox; if (p.contains('switch') || p.contains('nintendo')) return FontAwesomeIcons.gamepad; if (p.contains('mac') || p.contains('apple')) return FontAwesomeIcons.apple; if (p.contains('linux')) return FontAwesomeIcons.linux; if (p.contains('android')) return FontAwesomeIcons.android; if (p.contains('ios')) return FontAwesomeIcons.appStoreIos; return FontAwesomeIcons.gamepad;}
  String _getRatingTitle(double rating) {if (rating >= 4.5) return "Exceptional"; if (rating >= 3.5) return "Recommended"; if (rating >= 2.5) return "Meh"; return "Skip";}
  IconData _getRatingIcon(double rating) {if (rating >= 4.5) return FontAwesomeIcons.bullseye; if (rating >= 3.5) return FontAwesomeIcons.thumbsUp; if (rating >= 2.5) return FontAwesomeIcons.faceMeh; return FontAwesomeIcons.ban;}
  Color _getRatingColor(int id) {switch (id) {case 5: return const Color(0xFF6DC849); case 4: return const Color(0xFF4D85F0); case 3: return const Color(0xFFFDCA52); case 1: return const Color(0xFFFF4842); default: return Colors.grey;}}
  Widget _buildLoadingScreen() => const Scaffold(backgroundColor: Color(0xFF121212), body: Center(child: CircularProgressIndicator()));
  Widget _buildErrorScreen(BuildContext context, String msg) => Scaffold(appBar: AppBar(backgroundColor: Colors.transparent), backgroundColor: const Color(0xFF121212), body: Center(child: Text("Error: $msg", style: const TextStyle(color: Colors.white))));
}

extension StringExtension on String { String capitalize() => "${this[0].toUpperCase()}${substring(1)}"; }

class _ExpandableText extends StatefulWidget { final String text; const _ExpandableText({required this.text}); @override State<_ExpandableText> createState() => _ExpandableTextState(); }
class _ExpandableTextState extends State<_ExpandableText> { bool _isExpanded = false; @override Widget build(BuildContext context) { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [AnimatedSize(duration: const Duration(milliseconds: 300), child: Text(widget.text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5), maxLines: _isExpanded ? null : 4, overflow: _isExpanded ? TextOverflow.visible : TextOverflow.fade)), const SizedBox(height: 8), GestureDetector(onTap: () => setState(() => _isExpanded = !_isExpanded), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)), child: Text(_isExpanded ? "Show less" : "Show more", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11))))]); } }

// --- NEW WIDGET: FULL SCREEN GALLERY WITH UI OVERLAY ---
class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. MAIN IMAGE SLIDER
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index],
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                  ),
                ),
              );
            },
          ),

          // 2. TOP CONTROLS (ARROWS & CLOSE)
          Positioned(
            top: 20, // Safe area margin
            left: 0,
            right: 0,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Empty space to balance Row if needed, or purely absolute positioning
                  const SizedBox(width: 48), 

                  // Center Arrows
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: _currentIndex > 0 ? Colors.white : Colors.white38),
                          onPressed: _goToPrevious,
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: Icon(Icons.chevron_right, color: _currentIndex < widget.images.length - 1 ? Colors.white : Colors.white38),
                          onPressed: _goToNext,
                        ),
                      ],
                    ),
                  ),

                  // Close Button (Right)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. BOTTOM THUMBNAIL STRIP
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100, // Height of the strip container
              color: Colors.black.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.images.length + 1, // +1 for the '...' menu icon
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  // Last item: Menu icon
                  if (index == widget.images.length) {
                    return Container(
                      width: 60,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.more_horiz, color: Colors.white),
                    );
                  }

                  final bool isSelected = index == _currentIndex;
                  return GestureDetector(
                    onTap: () {
                      _pageController.jumpToPage(index);
                    },
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6), // Slightly less to fit inside border
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            isSelected ? Colors.transparent : Colors.black.withOpacity(0.5),
                            BlendMode.darken,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.images[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey[900]),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}