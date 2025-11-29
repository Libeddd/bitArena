// File: lib/features/home/screens/home_screen.dart

import 'package:bitarena/features/home/widgets/game_card.dart';
import 'package:bitarena/features/home/widgets/home_card_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bitarena/features/home/bloc/home_bloc.dart';
import 'package:bitarena/features/home/widgets/home_card.dart';
import 'package:bitarena/features/home/widgets/home_banner.dart';
import 'package:go_router/go_router.dart';
import 'package:bitarena/app/app_routes.dart';
import 'package:shimmer/shimmer.dart';
import 'package:bitarena/features/home/widgets/game_card_skeleton.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bitarena/features/auth/cubit/auth_cubit.dart';
import 'dart:ui'; // Wajib untuk scroll desktop

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  
  bool _isPlatformsExpanded = false;
  bool _isGenresExpanded = false;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeFetchList());
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
    });
  }

  Future<void> _refreshUserData() async {
    await FirebaseAuth.instance.currentUser?.reload();
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

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _getDateRangeForMonth(int monthIndex) {
    final now = DateTime.now();
    final year = now.year;
    final start = DateTime(year, monthIndex, 1);
    final end = DateTime(year, monthIndex + 1, 0); 
    return "${_formatDate(start)},${_formatDate(end)}";
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final last30Days = now.subtract(const Duration(days: 30));
    final nextWeekStart = now.add(const Duration(days: 7));
    final nextWeekEnd = now.add(const Duration(days: 14));
    final currentYear = now.year;

    // Variabel Responsif
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 800;
    final double cardWidth = isDesktop ? 280 : 200;
    final double cardHeight = isDesktop ? 380 : 290;

    const double kMaxWidth = 1350.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('bitArena', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      
      drawer: Drawer(
        backgroundColor: const Color(0xFF1F1F1F),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // USER HEADER
            StreamBuilder<User?>(
              initialData: FirebaseAuth.instance.currentUser,
              stream: FirebaseAuth.instance.userChanges(), 
              builder: (context, snapshot) {
                final currentUser = snapshot.data;
                if (currentUser == null) {
                   return const UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: Color(0xFF1F1F1F)),
                    accountName: Text("Guest", style: TextStyle(color: Colors.white)),
                    accountEmail: Text("Please login", style: TextStyle(color: Colors.grey)),
                    currentAccountPicture: CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.login, color: Colors.white)),
                  );
                }
                final String initials = (currentUser.displayName != null && currentUser.displayName!.isNotEmpty)
                    ? currentUser.displayName![0].toUpperCase() : 'U';

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF1F1F1F)),
                  accountName: Text(currentUser.displayName ?? 'User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  accountEmail: Text(currentUser.email ?? '', style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12)),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.blueAccent, 
                    child: Text(initials, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                );
              },
            ),

            const _MenuItem(icon: Icons.home_outlined, title: 'Home', filters: {}),
            
            // MY WISHLIST
            ListTile(
              leading: const Icon(Icons.favorite_outline, color: Colors.grey, size: 20),
              title: Text('My Wishlist', style: GoogleFonts.poppins(color: Colors.white, fontSize: 15)),
              onTap: () { Navigator.pop(context); context.pushNamed(AppRoutes.wishlist); },
            ),

            // ABOUT (DI BAWAH WISHLIST)
            const _MenuItem(icon: Icons.info_outline, title: 'About', filters: {}),
            const Divider(color: Colors.white10, thickness: 1),

            // --- NEW RELEASES ---
            _buildSectionHeader('New Releases'),
            _MenuItem(icon: Icons.star, title: 'Last 30 days', filters: {'dates': "${_formatDate(last30Days)},${_formatDate(now)}", 'ordering': '-released'}),
            _MenuItem(icon: Icons.local_fire_department, title: 'This week', filters: {'dates': "${_formatDate(now.subtract(const Duration(days: 7)))},${_formatDate(now.add(const Duration(days: 7)))}", 'ordering': '-added'}),
            _MenuItem(icon: Icons.fast_forward, title: 'Next week', filters: {'dates': "${_formatDate(nextWeekStart)},${_formatDate(nextWeekEnd)}", 'ordering': '-added'}),
            
            // RELEASE CALENDAR
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.grey, size: 20),
              title: Text('Release calendar', style: GoogleFonts.poppins(color: Colors.white, fontSize: 15)),
              onTap: () {
                Navigator.pop(context);
                final DateTime now = DateTime.now();
                final int currentMonthIndex = now.month - 1; 
                const List<String> fullMonths = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
                final String currentMonthName = fullMonths[currentMonthIndex];

                context.pushNamed(
                  AppRoutes.browse,
                  queryParameters: {
                    'title': 'Release calendar - $currentMonthName ${now.year}',
                    'dates': _getDateRangeForMonth(now.month), 
                    'ordering': 'released',
                    'show_calendar': 'true',
                    'initial_index': currentMonthIndex.toString(),
                  },
                );
              },
            ),

            const Divider(color: Colors.white10, thickness: 1),

            // --- TOP ---
            _buildSectionHeader('Top'),
            _MenuItem(icon: FontAwesomeIcons.trophy, title: 'Best of the year', filters: {'dates': "$currentYear-01-01,$currentYear-12-31", 'ordering': '-rating'}),
            _MenuItem(icon: Icons.bar_chart, title: 'Popular in $currentYear', filters: {'dates': "$currentYear-01-01,$currentYear-12-31", 'ordering': '-added'}),
            _MenuItem(icon: FontAwesomeIcons.crown, title: 'All time top 250', filters: {'ordering': '-rating', 'page_size': '40'}),

            const Divider(color: Colors.white10, thickness: 1),

            // --- PLATFORMS ---
            _buildExpandableSection(
              title: 'Platforms',
              isExpanded: _isPlatformsExpanded,
              onToggle: () => setState(() => _isPlatformsExpanded = !_isPlatformsExpanded),
              items: [
                _MenuItem(icon: FontAwesomeIcons.windows, title: 'PC', filters: {'parent_platforms': '1'}),
                _MenuItem(icon: FontAwesomeIcons.playstation, title: 'PlayStation 4', filters: {'platforms': '18'}),
                _MenuItem(icon: FontAwesomeIcons.xbox, title: 'Xbox One', filters: {'platforms': '1'}),
                _MenuItem(icon: FontAwesomeIcons.gamepad, title: 'Nintendo Switch', filters: {'platforms': '7'}),
                if (_isPlatformsExpanded) ...[
                  _MenuItem(icon: FontAwesomeIcons.apple, title: 'iOS', filters: {'platforms': '3'}),
                  _MenuItem(icon: FontAwesomeIcons.android, title: 'Android', filters: {'platforms': '21'}),
                  _MenuItem(icon: FontAwesomeIcons.linux, title: 'Linux', filters: {'platforms': '6'}),
                  _MenuItem(icon: FontAwesomeIcons.laptop, title: 'macOS', filters: {'platforms': '5'}),
                ]
              ],
            ),

            // --- GENRES ---
            _buildExpandableSection(
              title: 'Genres',
              isExpanded: _isGenresExpanded,
              onToggle: () => setState(() => _isGenresExpanded = !_isGenresExpanded),
              items: [
                const _MenuItem(icon: FontAwesomeIcons.bomb, title: 'Action', filters: {'genres': 'action'}),
                const _MenuItem(icon: FontAwesomeIcons.chessRook, title: 'Strategy', filters: {'genres': 'strategy'}),
                const _MenuItem(icon: FontAwesomeIcons.shieldHalved, title: 'RPG', filters: {'genres': 'role-playing-games-rpg'}),
                const _MenuItem(icon: FontAwesomeIcons.crosshairs, title: 'Shooter', filters: {'genres': 'shooter'}),
                const _MenuItem(icon: FontAwesomeIcons.mapLocationDot, title: 'Adventure', filters: {'genres': 'adventure'}),
                const _MenuItem(icon: FontAwesomeIcons.puzzlePiece, title: 'Puzzle', filters: {'genres': 'puzzle'}),
                if (_isGenresExpanded) ...[
                  const _MenuItem(icon: FontAwesomeIcons.flagCheckered, title: 'Racing', filters: {'genres': 'racing'}),
                  const _MenuItem(icon: FontAwesomeIcons.futbol, title: 'Sports', filters: {'genres': 'sports'}),
                  const _MenuItem(icon: FontAwesomeIcons.userGroup, title: 'Massively Multiplayer', filters: {'genres': 'massively-multiplayer'}),
                  const _MenuItem(icon: FontAwesomeIcons.ghost, title: 'Indie', filters: {'genres': 'indie'}),
                ]
              ],
            ),

            const Divider(color: Colors.white10, thickness: 1),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text('Logout', style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthCubit>().logout();
                context.go(AppRoutes.login);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center( // Center widget untuk menengahkan search bar
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kMaxWidth), // Batas lebar
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search store',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
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
            ),
          ),

          Expanded(
            child: Center( // Center widget untuk menengahkan konten utama
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kMaxWidth), // Batas lebar
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BANNER
                     BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading || state is HomeInitial) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[850]!, 
                          highlightColor: Colors.grey[700]!, 
                          child: Container(height: 530, width: double.infinity, color: Colors.grey[850])
                        );
                      }
                      if (state is HomeSuccess) {
                        // Ambil 3 game untuk Banner
                        final bannerGames = state.games.take(3).toList();
                        if (bannerGames.isEmpty) return const SizedBox.shrink();

                        // PERBAIKAN: Langsung panggil widget tanpa LayoutBuilder
                        // Widget FeaturedGamesSection sudah otomatis mengatur Desktop/Mobile
                        return FeaturedGamesSection(
                          games: bannerGames,
                          height: 530, 
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                      // FEATURED GAMES (HORIZONTAL)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Featured Games', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      BlocBuilder<HomeBloc, HomeState>(
                        builder: (context, state) {
                          if (state is HomeLoading || state is HomeInitial) {
                            return SizedBox(
                              height: cardHeight,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: 7,
                                separatorBuilder: (context, index) => const SizedBox(width: 16),
                                itemBuilder: (context, index) => SizedBox(width: cardWidth, child: const GameCardSkeleton()),
                              ),
                            );
                          }
                          if (state is HomeSuccess) {
                            final featuredGames = state.games.skip(5).take(7).toList();
                            return SizedBox(
                              height: cardHeight,
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context).copyWith(
                                  dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
                                ),
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  itemCount: featuredGames.length,
                                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                                  itemBuilder: (context, index) => SizedBox(width: cardWidth, child: GameCard(game: featuredGames[index])),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // ALL GAMES (GRID)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('All Games', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      BlocBuilder<HomeBloc, HomeState>(
                        builder: (context, state) {
                          if (state is HomeLoading || state is HomeInitial) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[850]!, highlightColor: Colors.grey[700]!,
                              child: GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0), physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 400, childAspectRatio: 0.9, crossAxisSpacing: 16, mainAxisSpacing: 16),
                                itemCount: 6, itemBuilder: (context, index) => const HomeCardSkeleton(),
                              ),
                            );
                          }
                          if (state is HomeError) return Center(child: Text('Failed to load games: ${state.message}'));
                          if (state is HomeSuccess) {
                            if (state.games.isEmpty) return const Center(child: Text('No games found.'));
                            final gridGames = state.games.skip(12).toList();
                            return Column(
                              children: [
                                GridView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0), physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
                                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 400, childAspectRatio: 0.9, crossAxisSpacing: 16, mainAxisSpacing: 16),
                                  itemCount: gridGames.length, itemBuilder: (context, index) => HomeCard(game: gridGames[index]),
                                ),
                                if (state.isLoadingMore && !state.hasReachedMax)
                                  const Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Center(child: CircularProgressIndicator())),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildExpandableSection({required String title, required bool isExpanded, required VoidCallback onToggle, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        ...items,
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(4)), child: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: Colors.white)),
                const SizedBox(width: 12),
                Text(isExpanded ? "Hide" : "Show all", style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final Map<String, dynamic> filters;

  const _MenuItem({required this.icon, required this.title, required this.filters});

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
        leading: FaIcon(widget.icon, color: _isHovered ? Colors.white : Colors.grey[400], size: 20),
        title: Text(widget.title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15)),
        onTap: () {
          // --- FIX NAVIGASI ABOUT DI SINI ---
          if (widget.title == 'About') {
            Navigator.pop(context);
            context.pushNamed(AppRoutes.aboutUs);
            return;
          }
          // ----------------------------------

          if (widget.filters.isEmpty) {
            Navigator.pop(context);
            return;
          }
          
          String finalTitle = widget.title;
          if (widget.filters.keys.any((k) => k.contains('genres') || k.contains('platforms'))) {
             if (!finalTitle.toLowerCase().contains('games')) {
               finalTitle = "$finalTitle Games";
             }
          }

          context.pushNamed(
            AppRoutes.browse,
            queryParameters: {
              'title': finalTitle, 
              ...widget.filters.map((k, v) => MapEntry(k, v.toString())),
            },
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}