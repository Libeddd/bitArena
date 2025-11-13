import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bitArena/features/home/bloc/home_bloc.dart';
import 'package:bitArena/features/home/widgets/home_card.dart';
import 'package:bitArena/features/home/widgets/home_banner.dart';
import 'package:bitArena/features/home/widgets/home_sidebar_list.dart';
import 'package:go_router/go_router.dart';
import 'package:bitArena/app/app_routes.dart';
import 'package:shimmer/shimmer.dart';
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

  Widget _buildGenreItem(BuildContext context, String genre) {
    return ListTile(
      title: Text(genre, style: const TextStyle(color: Colors.white)),
      onTap: () {
        // Filter genre tetap pakai BLoC
        context.read<HomeBloc>().add(HomeFilterByGenre(genre: genre));
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games Store'),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1F1F1F),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF2A2A2A)),
              child: Text(
                'Filter Genre',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            _buildGenreItem(context, 'Action'),
            _buildGenreItem(context, 'Shooter'),
            _buildGenreItem(context, 'Adventure'),
            _buildGenreItem(context, 'RPG'),
            _buildGenreItem(context, 'Simulation'),
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
