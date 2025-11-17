// File: lib/features/search/screens/search_screen.dart (REVISI TOTAL)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bitArena/features/home/widgets/game_card.dart';
import 'package:bitArena/features/search/bloc/search_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bitArena/features/home/widgets/game_card_skeleton.dart';

// --- 1. UBAH JADI STATEFULWIDGET ---
class SearchScreen extends StatefulWidget {
  final String query;
  const SearchScreen({super.key, required this.query});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // --- 2. TAMBAHKAN CONTROLLER & STATE FILTER ---
  final _scrollController = ScrollController();
  
  // Data untuk Dropdown (Gunakan ID/Slug dari API RAWG)
  final Map<String, String> genres = {
    'All Genres': '',
    'Action': 'action',
    'Shooter': 'shooter',
    'Adventure': 'adventure',
    'RPG': 'role-playing-games-rpg',
    'Simulation': 'simulation',
  };
  final Map<String, String> platforms = {
    'All Platforms': '',
    'PC': '4',
    'PlayStation': '187', // Grup PS5, PS4
    'Xbox': '186', // Grup Xbox Series, Xbox One
  };
  final Map<String, String> sorting = {
    'Relevance': '',
    'Name': 'name',
    'Release Date': '-released', // '-' berarti terbaru dulu
  };

  // State lokal untuk menyimpan pilihan filter
  String _selectedGenre = '';
  String _selectedPlatform = '';
  String _selectedSorting = '';

  // --- 3. TAMBAHKAN LIFECYCLE METHODS ---
  @override
  void initState() {
    super.initState();
    // Panggil BLoC untuk mulai mencari
    _fetchData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  // --- 4. TAMBAHKAN FUNGSI HELPER ---

  // Fungsi untuk pagination
  void _onScroll() {
    final currentState = context.read<SearchBloc>().state;
    if (currentState is SearchSuccess) {
      // Jika 300px dari bawah, muat lebih banyak
      if (_scrollController.position.extentAfter < 300) {
        context.read<SearchBloc>().add(FetchMoreSearchResults());
      }
    }
  }

  // Fungsi untuk memicu BLoC dengan filter terbaru
  void _fetchData() {
    final filters = <String, dynamic>{};
    if (_selectedGenre.isNotEmpty) {
      filters['genres'] = _selectedGenre;
    }
    if (_selectedPlatform.isNotEmpty) {
      filters['platforms'] = _selectedPlatform;
    }
    if (_selectedSorting.isNotEmpty) {
      filters['ordering'] = _selectedSorting;
    }
    
    // Panggil event pencarian baru dengan query dan filter
    context.read<SearchBloc>().add(PerformSearch(widget.query, filters));
  }

  @override
  Widget build(BuildContext context) {
    // HAPUS PANGGILAN BLOC DARI SINI
    // context.read<SearchBloc>().add(PerformSearch(query));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'bitArena',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      
      // --- 5. HUBUNGKAN SCROLL CONTROLLER ---
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // --- Judul "Search Result for..." (Tidak Berubah) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(
                "Search Result for '${widget.query}'", // Perbaiki tanda kutip
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // --- 6. TAMBAHKAN UI FILTER BARU ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  _buildFilterDropdown(
                    label: 'Genre',
                    items: genres,
                    selectedValue: _selectedGenre,
                    onChanged: (value) {
                      setState(() => _selectedGenre = value ?? '');
                      _fetchData(); // Panggil ulang pencarian
                    },
                  ),
                  _buildFilterDropdown(
                    label: 'Platform',
                    items: platforms,
                    selectedValue: _selectedPlatform,
                    onChanged: (value) {
                      setState(() => _selectedPlatform = value ?? '');
                      _fetchData(); // Panggil ulang pencarian
                    },
                  ),
                  _buildFilterDropdown(
                    label: 'Sort By',
                    items: sorting,
                    selectedValue: _selectedSorting,
                    onChanged: (value) {
                      setState(() => _selectedSorting = value ?? '');
                      _fetchData(); // Panggil ulang pencarian
                    },
                  ),
                ],
              ),
            ),
            // --- BATAS UI FILTER ---

            const SizedBox(height: 16.0),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    // Gunakan helper untuk loading
                    if (state is SearchLoading) {
                      return _buildSkeletonGrid();
                    }
                    if (state is SearchError) {
                      return Center(child: Text('Gagal memuat data: ${state.message}'));
                    }
                    // Gunakan helper untuk hasil
                    if (state is SearchSuccess) {
                      if (state.games.isEmpty) {
                        return const Center(child: Text('Game tidak ditemukan.'));
                      }
                      return _buildGameGrid(state);
                    }
                    // Tampilkan skeleton saat state Initial
                    return _buildSkeletonGrid();
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

  // --- 7. TAMBAHKAN HELPER WIDGETS DI SINI ---

  // Helper widget untuk Dropdown
  Widget _buildFilterDropdown({
    required String label,
    required Map<String, String> items,
    required String selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          onChanged: onChanged,
          dropdownColor: const Color(0xFF2A2A2A),
          style: const TextStyle(color: Colors.white),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
          hint: Text(label, style: TextStyle(color: Colors.grey[400])),
          items: items.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.value,
              child: Text(entry.key),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Helper untuk Skeleton Grid
  Widget _buildSkeletonGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          childAspectRatio: 0.6, // Gunakan rasio yang benar (0.6)
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 12,
        itemBuilder: (context, index) => const GameCardSkeleton(),
      ),
    );
  }

  // Helper untuk Game Grid
  Widget _buildGameGrid(SearchSuccess state) {
    return Column(
      children: [
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 0.6, // Gunakan rasio yang benar (0.6)
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: state.games.length,
          itemBuilder: (context, index) {
            final game = state.games[index];
            return GameCard(game: game);
          },
        ),
        // Tampilkan loading di bawah jika sedang pagination
        if (state.isLoadingMore && !state.hasReachedMax)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}