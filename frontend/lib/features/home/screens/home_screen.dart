import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bitArena/features/home/bloc/home_bloc.dart';
import 'package:bitArena/features/home/widgets/home_card.dart';
import 'package:bitArena/features/home/widgets/home_banner.dart';
import 'package:bitArena/features/home/widgets/home_sidebar_list.dart';
import 'package:go_router/go_router.dart';
import 'package:bitArena/app/app_routes.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bitArena/features/home/widgets/game_card_skeleton.dart';
import 'package:bitArena/features/home/widgets/home_banner_skeleton.dart';
import 'package:bitArena/features/home/widgets/home_sidebar_skeleton.dart';

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

  String _getDatesForFilter(String filter) {
    final now = DateTime.now();
    String from, to;
    to = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    switch (filter) {
      case 'last-30-days':
        final last30 = now.subtract(const Duration(days: 30));
        from = "${last30.year}-${last30.month.toString().padLeft(2, '0')}-${last30.day.toString().padLeft(2, '0')}";
        break;
      case 'this-week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        from = "${startOfWeek.year}-${startOfWeek.month.toString().padLeft(2, '0')}-${startOfWeek.day.toString().padLeft(2, '0')}";
        break;
      case 'next-week':
        final nextWeek = now.add(const Duration(days: 7));
        from = to; // Mulai dari hari ini
        to = "${nextWeek.year}-${nextWeek.month.toString().padLeft(2, '0')}-${nextWeek.day.toString().padLeft(2, '0')}";
        break;
      default:
        from = to;
    }
    return "$from,$to";
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'bitArena',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        // --- BATAS PERBAIKAN ---
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color.fromARGB(255, 0, 0, 0)),
              child: Text(
                'bitArena', // Menggunakan judul dari main.dart
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // --- Section 1: Home, About, Contact ---
            const _MenuItem(icon: Icons.home_outlined, title: 'Home', filters: {}), // Tanpa filter
            const _MenuItem(icon: Icons.info_outline, title: 'About', filters: {}), // Tanpa filter
            const _MenuItem(icon: Icons.mail_outline, title: 'Contact', filters: {}), // Tanpa filter
            
            const Divider(color: Colors.black26),

            // --- Section 2: New Releases ---
            _buildSectionTitle('New Releases'),
            _MenuItem(
              icon: Icons.star_outline,
              title: 'Last 30 Days',
              filters: {'dates': _getDatesForFilter('last-30-days')},
            ),
            _MenuItem(
              icon: Icons.watch_later_outlined,
              title: 'This Week',
              filters: {'dates': _getDatesForFilter('this-week')},
            ),
            _MenuItem(
              icon: Icons.fast_forward_outlined,
              title: 'Next Week',
              filters: {'dates': _getDatesForFilter('next-week')},
            ),

            const Divider(color: Colors.black26),

            // --- Section 3: Platforms ---
            _buildSectionTitle('Platforms'),
            // ID Platform dari API RAWG: 4 = PC, 18 = PS4, 1 = Xbox One
            const _MenuItem(icon: FontAwesomeIcons.windows, title: 'PC', filters: {'platforms': '4'}),
            const _MenuItem(icon: FontAwesomeIcons.playstation, title: 'Playstation 4', filters: {'platforms': '18'}),
            const _MenuItem(icon: FontAwesomeIcons.xbox, title: 'Xbox One', filters: {'platforms': '1'}),

            const Divider(color: Colors.black26),

            // --- Section 4: Genres ---
            _buildSectionTitle('Genres'),
            // Kita panggil _MenuItem, sama seperti Platforms
            _MenuItem(
              icon: FontAwesomeIcons.bomb, // Ikon untuk Action
              title: 'Action',
              filters: {'genres': 'action'},
            ),
            _MenuItem(
              icon: FontAwesomeIcons.crosshairs, // Ikon untuk Shooter
              title: 'Shooter',
              filters: {'genres': 'shooter'},
            ),
            _MenuItem(
              icon: FontAwesomeIcons.mapLocationDot, // Ikon untuk Adventure
              title: 'Adventure',
              filters: {'genres': 'adventure'},
            ),
            _MenuItem(
              icon: FontAwesomeIcons.shieldHalved, // Ikon untuk RPG
              title: 'RPG',
              filters: {'genres': 'role-playing-games-rpg'},
            ),
            _MenuItem(
              icon: FontAwesomeIcons.car, // Ikon untuk Simulation
              title: 'Simulation',
              filters: {'genres': 'simulation'},
            ),
          ],
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 300,
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
                      // DIUBAH KEMBALI: Pakai GoRouter untuk pindah halaman
                      context.push('${AppRoutes.search}/$query');
                    } else {
                      // Jika kosong, refresh halaman
                      context.read<HomeBloc>().add(HomeFetchList());
                    }
                  },
                ),
              ),
            ),
          ),

          // Konten Scrollable
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading || state is HomeInitial) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[850]!,
                          highlightColor: Colors.grey[700]!,
                          child: Container(
                            height: 400,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: const Row(
                              children: [
                                Expanded(flex: 3, child: HomeBannerSkeleton()),
                                SizedBox(width: 16),
                                Expanded(flex: 1, child: HomeSidebarSkeleton()),
                              ],
                            ),
                          ),
                        );
                      }
                      if (state is HomeSuccess) {
                        final bannerGames = state.games.take(5).toList();
                        final sidebarGames = state.games
                            .skip(5)
                            .take(5)
                            .toList();

                        return Container(
                          height: 400,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: HomeBannerCarousel(games: bannerGames),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: HomeSidebarList(games: sidebarGames),
                              ),
                            ],
                          ),
                        );
                      }
                      return Container(
                        height: 400,
                        alignment: Alignment.center,
                        child: const Text('Gagal memuat banner'),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'All Games',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading || state is HomeInitial) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[850]!,
                          highlightColor: Colors.grey[700]!,
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 400,
                                  childAspectRatio: 1.05,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: 6,
                            itemBuilder: (context, index) =>
                                const GameCardSkeleton(),
                          ),
                        );
                      }
                      if (state is HomeError) {
                        return Center(
                          child: Text('Gagal memuat data: ${state.message}'),
                        );
                      }
                      if (state is HomeSuccess) {
                        if (state.games.isEmpty) {
                          return const Center(
                            child: Text('Game tidak ditemukan.'),
                          );
                        }

                        // Mengubah logika ini agar banner dan grid tidak tumpang tindih
                        final gridGames = state.games.skip(10).toList();

                        return Column(
                          children: [
                            GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 400,
                                    childAspectRatio: 1.05,
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
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
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
              'title': pageTitle, // Kirim judul
              ...widget.filters,      // Kirim filter
            },
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}