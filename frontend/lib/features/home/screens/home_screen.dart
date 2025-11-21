import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bitArena/features/home/bloc/home_bloc.dart';
import 'package:bitArena/features/home/widgets/home_card.dart';
import 'package:bitArena/features/home/widgets/game_card.dart';
import 'package:bitArena/features/home/widgets/home_banner.dart';
import 'package:go_router/go_router.dart';
import 'package:bitArena/app/app_routes.dart';
import 'package:shimmer/shimmer.dart';
import 'package:bitArena/features/home/widgets/game_card_skeleton.dart';
import 'package:bitArena/features/home/widgets/home_banner_skeleton.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeFetchList());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentState = context.read<HomeBloc>().state;
    if (currentState is HomeSuccess) {
      if (_scrollController.position.extentAfter < 300) {
        context.read<HomeBloc>().add(HomeFetchMoreGames());
      }
    }
  }

  // Helper untuk Judul
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper widget untuk MenuItem di Drawer
  // (Anda bisa memindahkannya ke file terpisah atau biarkan di bawah file ini seperti sebelumnya)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'bitArena',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      
      // --- DRAWER (Tidak Berubah) ---
      drawer: Drawer(
        backgroundColor: const Color(0xFF1F1F1F), // Hitam senada
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1F1F1F)),
              child: Text(
                'bitArena', 
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const _MenuItem(icon: Icons.home_outlined, title: 'Home', filters: {}),
            const _MenuItem(icon: Icons.info_outline, title: 'About', filters: {}),
            const _MenuItem(icon: Icons.mail_outline, title: 'Contact', filters: {}),
            const Divider(color: Colors.black26),
            
            _buildSectionTitle('Platforms'),
            const _MenuItem(icon: FontAwesomeIcons.windows, title: 'PC', filters: {'platforms': '4'}),
            const _MenuItem(icon: FontAwesomeIcons.playstation, title: 'Playstation 4', filters: {'platforms': '18'}),
            const _MenuItem(icon: FontAwesomeIcons.xbox, title: 'Xbox', filters: {'platforms': '1'}),
            const Divider(color: Colors.black26),

            _buildSectionTitle('Genres'),
            const _MenuItem(icon: FontAwesomeIcons.bomb, title: 'Action', filters: {'genres': 'action'}),
            const _MenuItem(icon: FontAwesomeIcons.crosshairs, title: 'Shooter', filters: {'genres': 'shooter'}),
            const _MenuItem(icon: FontAwesomeIcons.mapLocationDot, title: 'Adventure', filters: {'genres': 'adventure'}),
            const _MenuItem(icon: FontAwesomeIcons.shieldHalved, title: 'RPG', filters: {'genres': 'role-playing-games-rpg'}),
            const _MenuItem(icon: FontAwesomeIcons.car, title: 'Simulation', filters: {'genres': 'simulation'}),
          ],
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search store',
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  context.push('${AppRoutes.search}/$query');
                } else {
                  context.read<HomeBloc>().add(HomeFetchList());
                }
              },
            ),
          ),

          // --- KONTEN SCROLLABLE ---
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- 1. BANNER SECTION ---
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading || state is HomeInitial) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[850]!,
                          highlightColor: Colors.grey[700]!,
                          child: Container(
                            height: 400,
                            width: double.infinity, 
                            color: Colors.grey[850],
                          ),
                        );
                      }
                      if (state is HomeSuccess) {
                        final bannerGames = state.games.take(5).toList();
                        return SizedBox(
                          height: 400,
                          width: double.infinity,
                          child: HomeBannerCarousel(games: bannerGames),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // --- 2. FEATURED GAMES (BEKAS SIDEBAR) ---
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Featured Games',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),

                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading || state is HomeInitial) {
                        // Skeleton Grid untuk Featured
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[850]!,
                          highlightColor: Colors.grey[700]!,
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200, // Ukuran kartu
                              childAspectRatio: 0.6,   // Kotak (sesuai desain baru)
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: 4, 
                            itemBuilder: (context, index) => const GameCardSkeleton(),
                          ),
                        );
                      }
                      if (state is HomeSuccess) {
                        // Ambil 5 game setelah banner (bekas sidebar)
                        final sidebarGames = state.games.skip(5).take(5).toList();

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200, 
                            childAspectRatio: 0.6, // Sesuaikan rasio kartu HomeCard
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: sidebarGames.length,
                          itemBuilder: (context, index) {
                            final game = sidebarGames[index];
                            // Gunakan HomeCard (desain baru seperti searching)
                            return GameCard(game: game);
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // --- 3. TRENDING GAMES (GRID UTAMA) ---
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'All Games',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),

                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading || state is HomeInitial) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[850]!,
                          highlightColor: Colors.grey[700]!,
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              childAspectRatio: 1.0,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: 6,
                            itemBuilder: (context, index) => const GameCardSkeleton(),
                          ),
                        );
                      }
                      if (state is HomeError) {
                        return Center(child: Text('Gagal memuat data: ${state.message}'));
                      }
                      if (state is HomeSuccess) {
                        if (state.games.isEmpty) {
                          return const Center(child: Text('Game tidak ditemukan.'));
                        }

                        // Ambil sisa game (setelah 10 game pertama)
                        final gridGames = state.games.skip(10).toList();

                        return Column(
                          children: [
                            GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                childAspectRatio: 1.0, // Sesuaikan rasio
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: gridGames.length,
                              itemBuilder: (context, index) {
                                final game = gridGames[index];
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET _MenuItem (Helper untuk Drawer) ---
class _MenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final Map<String, dynamic> filters;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.filters,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      
      child: ListTile(
        leading: FaIcon(
          widget.icon,
          color: _isHovered ? Colors.white : Colors.grey[400],
          size: 20,
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
        ),
        onTap: () {
          if (widget.filters.isEmpty) {
            Navigator.pop(context);
            return;
          }
          
          String pageTitle = widget.title;
          if (widget.filters.containsKey('platforms') || widget.filters.containsKey('genres')) {
            pageTitle = '${widget.title} Games';
          }

          context.pushNamed(
            AppRoutes.browse,
            queryParameters: {
              'title': pageTitle, 
              ...widget.filters,
            },
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}