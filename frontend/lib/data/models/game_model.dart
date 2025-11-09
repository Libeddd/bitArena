// File: lib/data/models/game_model.dart (UPGRADED)

import 'package:equatable/equatable.dart';

class GameModel extends Equatable {
  final int id;
  final String name;
  final String backgroundImage;
  final double rating;
  final String releasedDate; // <-- BARU: Untuk tahun (2025)
  final List<String> genres; // <-- BARU: Untuk kategori (Horror)

  const GameModel({
    required this.id,
    required this.name,
    required this.backgroundImage,
    required this.rating,
    required this.releasedDate,
    required this.genres,
  });

  // Factory constructor untuk parsing JSON
  factory GameModel.fromJson(Map<String, dynamic> json) {
    // Ekstrak list genre (kategori)
    final List<String> genreList = (json['genres'] as List? ?? [])
        .map((genre) => genre['name'] as String)
        .toList();
    
    // Ekstrak tahun rilis
    final String release = json['released'] ?? 'N/A';
    final String year = release.split('-').first; // Ambil tahunnya saja

    return GameModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      backgroundImage: json['background_image'] ?? 'https://via.placeholder.com/150',
      rating: (json['rating'] ?? 0.0).toDouble(),
      releasedDate: year, // Simpan tahunnya
      genres: genreList, // Simpan list kategori
    );
  }

  // Helper untuk mendapatkan kategori pertama (cth: "Horror")
  String get mainGenre => genres.isNotEmpty ? genres.first : 'Game';

  @override
  List<Object?> get props => [id, name, backgroundImage, rating, releasedDate, genres];
}