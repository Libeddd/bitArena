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
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bitarena/features/auth/cubit/auth_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  
  // Ambil user saat ini dari Firebase
  final User? currentUser = FirebaseAuth.instance.currentUser;

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
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      
      // --- DRAWER DIPERBARUI ---
      drawer: Drawer(
        backgroundColor: const Color(0xFF1F1F1F),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            StreamBuilder<User?>(
              initialData: FirebaseAuth.instance.currentUser,
              stream: FirebaseAuth.instance.userChanges(), 
              builder: (context, snapshot) {
                final currentUser = snapshot.data;
                if (currentUser == null) {
                   return const UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: Color(0xFF1F1F1F)),
                    accountName: Text("Tamu", style: TextStyle(color: Colors.white)),
                    accountEmail: Text("Silakan login", style: TextStyle(color: Colors.grey)),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.login, color: Colors.white),
                    ),
                  );
                }

                final String initials = (currentUser.displayName != null && currentUser.displayName!.isNotEmpty)
                    ? currentUser.displayName![0].toUpperCase()
                    : 'U';

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF1F1F1F)),
                  accountName: Text(
                    currentUser.displayName ?? 'Pengguna', // Hapus tanda tanya
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  accountEmail: Text(
                    currentUser.email ?? 'No Email',
                    style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12),
                  ),
                 currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.blueAccent, // Warna background avatar tetap
                    child: Text(
                      initials,
                      style: GoogleFonts.poppins(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white
                      ),
                    ),
                  ),
                );
              },
            ),
            
            _buildSectionTitle('Platforms'),
            const _MenuItem(icon: FontAwesomeIcons.windows, title: 'PC', filters: {'platforms': '4'}),
            const _MenuItem(icon: FontAwesomeIcons.playstation, title: 'Playstation 4', filters: {'platforms': '18'}),
            const _MenuItem(icon: FontAwesomeIcons.xbox, title: 'Xbox One', filters: {'platforms': '1'}),
            
            const Divider(color: Colors.black26),

            _buildSectionTitle('Genres'),
            const _MenuItem(icon: FontAwesomeIcons.bomb, title: 'Action', filters: {'genres': 'action'}),
            const _MenuItem(icon: FontAwesomeIcons.crosshairs, title: 'Shooter', filters: {'genres': 'shooter'}),
            const _MenuItem(icon: FontAwesomeIcons.mapLocationDot, title: 'Adventure', filters: {'genres': 'adventure'}),
            const _MenuItem(icon: FontAwesomeIcons.shieldHalved, title: 'RPG', filters: {'genres': 'role-playing-games-rpg'}),
            const _MenuItem(icon: FontAwesomeIcons.car, title: 'Simulation', filters: {'genres': 'simulation'}),

            const Divider(color: Colors.black26),

            ListTile(
              leading: const Icon(Icons.favorite_outline, color: Colors.grey, size: 20),
              title: Text(
                'My Wishlist',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
              ),
              onTap: () {
                Navigator.pop(context); // Tutup Drawer
                context.pushNamed(AppRoutes.wishlist); // Pindah ke Wishlist
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white70),
              title: Text(
                'About Us',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                context.push(AppRoutes.aboutUs); // Pindah ke halaman About Us
              },
            ),

            const Divider(color: Colors.black26),

            // 2. TOMBOL LOGOUT
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

                  // --- 2. FEATURED GAMES ---
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
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[850]!,
                          highlightColor: Colors.grey[700]!,
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200, 
                              childAspectRatio: 0.6,   
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: 4, 
                            itemBuilder: (context, index) => const GameCardSkeleton(),
                          ),
                        );
                      }
                      if (state is HomeSuccess) {
                        final featuredGames = state.games.skip(5).take(5).toList();
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200, 
                            childAspectRatio: 0.6,   
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: featuredGames.length,
                          itemBuilder: (context, index) {
                            final game = featuredGames[index];
                            return GameCard(game: game); 
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // --- 3. TRENDING GAMES ---
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
                            itemBuilder: (context, index) => const HomeCardSkeleton(),
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

                        final gridGames = state.games.skip(10).toList();

                        return Column(
                          children: [
                            GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                childAspectRatio: 1.0,
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

// --- WIDGET _MenuItem ---
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
          if (Scaffold.of(context).hasDrawer) {
            Navigator.pop(context);
          }

          if (widget.filters.isEmpty) {
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
              ...widget.filters.map((k, v) => MapEntry(k, v.toString())),
            },
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}