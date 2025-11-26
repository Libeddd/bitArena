import 'package:equatable/equatable.dart';

class GameModel extends Equatable {
  final int id;
  final String name;
  final String backgroundImage;
  final double rating;
  final String releasedDate;
  final List<String> genres;
  final int metacritic;
  final int added;
  final List<String> platforms; 
  final List<String> publishers;
  final List<String> developers;
  final String esrbRating;
  final String description;
  final Map<String, String> pcRequirements;

  // --- FIELD BARU UNTUK NAVIGASI ---
  // Menyimpan data lengkap (name, slug, id) agar bisa di-klik
  final List<Map<String, dynamic>> detailedGenres;
  final List<Map<String, dynamic>> detailedPlatforms;

  const GameModel({
    required this.id,
    required this.name,
    required this.backgroundImage,
    required this.rating,
    required this.releasedDate,
    required this.genres,
    required this.metacritic,
    required this.added,
    required this.platforms,
    required this.publishers,
    required this.developers,
    required this.esrbRating,
    required this.description,
    required this.pcRequirements,
    required this.detailedGenres,
    required this.detailedPlatforms,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    // 1. Genres (Simple)
    final List<String> genreList = (json['genres'] as List? ?? [])
        .map((g) => g['name'] as String).toList();
    
    // 1b. Detailed Genres (For Navigation) -> Butuh Slug
    final List<Map<String, dynamic>> dGenres = (json['genres'] as List? ?? [])
        .map((g) => {
          'name': g['name'] as String,
          'slug': g['slug'] as String, // Slug dipakai untuk filter API
        }).toList();

    // 2. Platforms (Simple)
    final List<String> platformList = (json['parent_platforms'] as List? ?? [])
        .map((p) => p['platform']['name'] as String).toList();

    final List<Map<String, dynamic>> dPlatforms = (json['parent_platforms'] as List? ?? [])
        .map((p) => {
          'name': p['platform']['name'] as String,
          'id': p['platform']['id'] as int, // ID dipakai untuk filter API
        }).toList();
        
    // 3. Publishers
    final List<String> pubList = (json['publishers'] as List? ?? [])
        .map((p) => p['name'] as String).toList();

    // 4. Developers
    final List<String> devList = (json['developers'] as List? ?? [])
        .map((d) => d['name'] as String).toList();

    // 5. ESRB
    final String esrb = json['esrb_rating'] != null 
        ? json['esrb_rating']['name'] 
        : 'Not Rated';

    // 6. Release Date
    String formattedDate = 'TBA';
    if (json['released'] != null) {
      try {
        final DateTime date = DateTime.parse(json['released']);
        const List<String> months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        formattedDate = "${months[date.month - 1]} ${date.day}, ${date.year}";
      } catch (_) {
        formattedDate = json['released'];
      }
    }

    // 7. PC Requirements
    Map<String, String> specs = {'minimum': '', 'recommended': ''};
    if (json['platforms'] != null) {
      final platformsData = json['platforms'] as List;
      for (var p in platformsData) {
        final platformInfo = p['platform'];
        if (platformInfo != null && platformInfo['slug'] == 'pc') {
          final requirements = p['requirements'];
          if (requirements != null) {
            specs['minimum'] = requirements['minimum'] ?? '';
            specs['recommended'] = requirements['recommended'] ?? '';
          }
        }
      }
    }

    return GameModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      backgroundImage: json['background_image'] ?? 'https://via.placeholder.com/150',
      rating: (json['rating'] ?? 0.0).toDouble(),
      releasedDate: formattedDate,
      genres: genreList,
      metacritic: json['metacritic'] ?? 0,
      added: json['added'] ?? 0,
      platforms: platformList,
      publishers: pubList,
      developers: devList,
      esrbRating: esrb,
      description: json['description_raw'] ?? json['description'] ?? '',
      pcRequirements: specs,
      detailedGenres: dGenres,
      detailedPlatforms: dPlatforms,
    );
  }

  String get mainGenre => genres.isNotEmpty ? genres.first : 'Game';
  String get publisher => publishers.isNotEmpty ? publishers.first : 'Unknown';

  @override
  List<Object?> get props => [
    id, name, backgroundImage, rating, releasedDate, genres,
    metacritic, added, platforms, publishers, developers, esrbRating, 
    description, pcRequirements, detailedGenres, detailedPlatforms
  ];
}