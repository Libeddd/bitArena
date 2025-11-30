// File: lib/features/home/widgets/home_banner.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:bitarena/data/models/game_model.dart';
import 'package:go_router/go_router.dart';
import 'package:bitarena/app/app_routes.dart';

// --- WIDGET UTAMA (RESPONSIF: DESKTOP & MOBILE) ---
class FeaturedGamesSection extends StatefulWidget {
  final List<GameModel> games;
  final double height; // Tinggi untuk Desktop

  const FeaturedGamesSection({
    super.key,
    required this.games,
    this.height = 530.0,
  });

  @override
  State<FeaturedGamesSection> createState() => _FeaturedGamesSectionState();
}

class _FeaturedGamesSectionState extends State<FeaturedGamesSection> with SingleTickerProviderStateMixin {
  final CarouselSliderController _carouselController = CarouselSliderController();
  late AnimationController _progressController;
  
  int _currentIndex = 0; 
  final Duration _autoPlayInterval = const Duration(seconds: 6);
  final Duration _slideAnimationDuration = const Duration(milliseconds: 600);
  final Curve _slideCurve = Curves.easeOutCubic;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this, duration: _autoPlayInterval);

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _carouselController.nextPage(
          duration: _slideAnimationDuration, 
          curve: _slideCurve
        );
      }
    });

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _onSlideChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _progressController.reset();
    _progressController.forward();
  }

  void _onSideItemTap(int index, String gameId) {
    // KONDISI 1: Jika game yang diklik TIDAK sedang tampil di banner utama
    if (_currentIndex != index) {
      // Geser banner ke game tersebut
      _carouselController.animateToPage(
        index, 
        duration: _slideAnimationDuration, 
        curve: _slideCurve
      );
    }
    else {
      // Langsung buka halaman detail
      context.push('${AppRoutes.detail}/$gameId');
    }
  }

  void _jumpToPage(int index) {
    if (_currentIndex != index) {
      _carouselController.animateToPage(
        index, 
        duration: _slideAnimationDuration, 
        curve: _slideCurve
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil 3 game untuk ditampilkan
    final displayGames = widget.games.take(3).toList();
    if (displayGames.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 800;

        // --- TAMPILAN DESKTOP (ROW) ---
        if (isDesktop) {
          return SizedBox(
            height: widget.height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Kiri
                Expanded(
                  flex: 3,
                  child: _buildMainCarousel(displayGames, 520),
                ),
                const SizedBox(width: 24),
                // List Kanan Vertikal
                Expanded(
                  flex: 1,
                  child: Column(
                    children: List.generate(displayGames.length, (index) {
                      final game = displayGames[index];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _SideListCard(
                            game: displayGames[index],
                            isActive: index == _currentIndex,
                            progressAnimation: _progressController,
                            onTap: () => _onSideItemTap(index, game.id.toString()),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        } 
        
        // --- TAMPILAN MOBILE (COLUMN) ---
        else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Atas
              _buildMainCarousel(displayGames, 380), // Tinggi banner di mobile agak kecil
              
              const SizedBox(height: 16),
              
              // List Bawah Horizontal (Seperti "yang lama")
              SizedBox(
                height: 180, // Tinggi list horizontal
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayGames.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final game = displayGames[index];
                    return SizedBox(
                      width: 130, // Lebar item list
                      child: _SideListCard(
                        game: displayGames[index],
                        isActive: index == _currentIndex,
                        progressAnimation: _progressController,
                        onTap: () => _onSideItemTap(index, game.id.toString()),
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

  // Helper untuk Carousel Utama agar tidak duplikasi kode
  Widget _buildMainCarousel(List<GameModel> games, double height) {
    return Listener(
      onPointerDown: (_) => _progressController.stop(),
      onPointerUp: (_) {
        if (!_progressController.isCompleted) _progressController.forward();
      },
      child: CarouselSlider.builder(
        carouselController: _carouselController,
        itemCount: games.length,
        itemBuilder: (context, index, realIndex) {
          return _BigBannerCard(
            game: games[index],
            progressAnimation: _progressController,
            isActive: index == _currentIndex,
          );
        },
        options: CarouselOptions(
          height: height,
          autoPlay: false, // Manual via AnimationController
          viewportFraction: 1.0,
          enlargeCenterPage: false,
          enableInfiniteScroll: true,
          onPageChanged: (index, reason) => _onSlideChanged(index),
          scrollPhysics: const NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }
}

// --- WIDGET HELPER: BANNER BESAR (GARIS PROGRESS) ---
class _BigBannerCard extends StatelessWidget {
  final GameModel game;
  final Animation<double> progressAnimation;
  final bool isActive;

  const _BigBannerCard({
    required this.game,
    required this.progressAnimation,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.detail}/${game.id}'),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: game.backgroundImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[900]),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                    stops: const [0.0, 0.6],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar
                    Text(
                      game.description, // Pastikan ini description_raw (clean text) dari model
                      style: const TextStyle(
                        color: Colors.white70, // Warna agak abu agar kontras dengan judul
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 3, // Batasi 3 baris
                      overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET HELPER: LIST KECIL (SHIMMER) ---
class _SideListCard extends StatelessWidget {
  final GameModel game;
  final bool isActive;
  final Animation<double> progressAnimation;
  final VoidCallback onTap;

  const _SideListCard({
    required this.game,
    required this.isActive,
    required this.progressAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: game.backgroundImage,
                fit: BoxFit.cover,
                // Di Mobile maupun Desktop, item non-aktif agak gelap
                color: isActive ? null : Colors.black.withOpacity(0.5),
                colorBlendMode: isActive ? null : BlendMode.darken,
              ),
              
              Container(
                color: Colors.black.withOpacity(0.3),
                padding: const EdgeInsets.all(12.0),
                alignment: Alignment.bottomLeft,
                child: Text(
                  game.name,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 13
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Efek Shimmer
              if (isActive)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: progressAnimation,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progressAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.2),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}