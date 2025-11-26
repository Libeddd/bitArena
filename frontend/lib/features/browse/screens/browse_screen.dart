// File: lib/features/browse/screens/browse_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bitarena/features/browse/bloc/browse_bloc.dart';
import 'package:bitarena/features/home/widgets/home_card.dart';
import 'package:bitarena/features/home/widgets/home_card_skeleton.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

class BrowseScreen extends StatefulWidget {
  final String title;
  final Map<String, dynamic> filters;

  const BrowseScreen({
    super.key,
    required this.title,
    required this.filters,
  });

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _scrollController = ScrollController();
  int? _selectedMonthIndex; // 0 = Jan, 11 = Dec

  @override
  void initState() {
    super.initState();
    
    // Cek apakah ada initial_index yang dikirim dari sidebar (Release Calendar)
    if (widget.filters['initial_index'] != null) {
      _selectedMonthIndex = int.parse(widget.filters['initial_index']);
    }

    context.read<BrowseBloc>().add(FetchFilteredGames(widget.filters));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentState = context.read<BrowseBloc>().state;
    if (currentState is BrowseSuccess) {
      if (_scrollController.position.extentAfter < 300) {
        context.read<BrowseBloc>().add(FetchMoreFilteredGames());
      }
    }
  }

  void _onMonthSelected(int index) {
    setState(() {
      _selectedMonthIndex = index;
    });

    final now = DateTime.now();
    final year = now.year;
    final month = index + 1;
    
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    
    final String formattedStart = "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
    final String formattedEnd = "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";

    final newFilters = Map<String, dynamic>.from(widget.filters);
    newFilters['dates'] = "$formattedStart,$formattedEnd";
    
    context.read<BrowseBloc>().add(FetchFilteredGames(newFilters));
  }

  @override
  Widget build(BuildContext context) {
    final bool showCalendar = widget.filters['show_calendar'] == 'true';
    final currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'bitArena',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: Column(
        children: [
          // HEADER TITLE (Menggunakan Nama Bulan LENGKAP)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                _selectedMonthIndex != null && showCalendar
                    ? "Release calendar - ${_getFullMonthName(_selectedMonthIndex!)} $currentYear" 
                    : widget.title,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // CALENDAR MONTH SELECTOR (Menggunakan Nama Bulan SINGKAT)
          if (showCalendar) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: List.generate(12, (index) {
                  final isSelected = _selectedMonthIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: InkWell(
                      onTap: () => _onMonthSelected(index),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getShortMonthName(index), // Gunakan singkatan (Jan, Feb)
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
          ],

          const SizedBox(height: 16.0),

          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: BlocBuilder<BrowseBloc, BrowseState>(
                  builder: (context, state) {
                    if (state is BrowseLoading || state is BrowseInitial) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[850]!,
                        highlightColor: Colors.grey[700]!,
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            childAspectRatio: 1.05,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: 12,
                          itemBuilder: (context, index) => const HomeCardSkeleton(),
                        ),
                      );
                    }
                    if (state is BrowseError) {
                      return Center(child: Text('Failed to load games: ${state.message}'));
                    }
                    if (state is BrowseSuccess) {
                      if (state.games.isEmpty) {
                        return const Center(child: Text('No games found for this period.'));
                      }
                      
                      return ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(bottom: 20),
                        children: [
                          GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              childAspectRatio: 1.05,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: state.games.length,
                            itemBuilder: (context, index) {
                              final game = state.games[index];
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk Nama Bulan Singkat (Tombol)
  String _getShortMonthName(int index) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[index];
  }

  // Helper untuk Nama Bulan Lengkap (Judul)
  String _getFullMonthName(int index) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[index];
  }
}