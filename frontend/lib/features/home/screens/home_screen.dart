import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/home/bloc/home_bloc.dart';
import 'package:frontend/features/home/widgets/game_card.dart';
// Import GameCard widget
// Import DetailScreen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games Store'),
        backgroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          // --- FITUR SEARCHING ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari game (cth: "Cyberpunk")...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (query) {
                // Panggil event BLoC
                if (query.isNotEmpty) {
                  context.read<HomeBloc>().add(SearchGames(query));
                } else {
                  // Jika kosong, fetch game awal lagi
                  context.read<HomeBloc>().add(FetchHomeGames());
                }
              },
            ),
          ),
          
          // --- KONTEN UTAMA (BLOC BUILDER) ---
          Expanded(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                // Tampilkan UI berdasarkan state
                if (state is HomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (state is HomeError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                
                if (state is HomeSuccess) {
                  // Tampilan "Cardstyle center"
                  // Kita gunakan GridView agar mirip Epic Games
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 kolom di HP
                      childAspectRatio: 0.7, // Rasio kartu
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: state.games.length,
                    itemBuilder: (context, index) {
                      final game = state.games[index];
                      // Panggil widget GameCard
                      return GameCard(game: game);
                    },
                  );
                }
                
                // State awal (HomeInitial)
                return const Center(child: Text('Selamat datang!'));
              },
            ),
          ),
        ],
      ),
    );
  }
}