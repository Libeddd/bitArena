// File: lib/data/models/game_model.dart

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
  final List<Map<String, dynamic>> detailedGenres;
  final List<Map<String, dynamic>> detailedPlatforms;
  final int playtime;
  final List<String> screenshots;
  final String? clip;       // Preview pendek (sering null)
  final String? trailerUrl; // Trailer Full (BARU)
  final List<Map<String, dynamic>> ratingsDistribution;

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
    required this.playtime,
    required this.screenshots,
    this.clip,
    this.trailerUrl,
    required this.ratingsDistribution,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    // Basic Parsing
    final List<String> genreList = (json['genres'] as List? ?? []).map((g) => g['name'] as String).toList();
    final List<Map<String, dynamic>> dGenres = (json['genres'] as List? ?? []).map((g) => {'name': g['name'] as String, 'slug': g['slug'] as String}).toList();
    final List<String> platformList = (json['parent_platforms'] as List? ?? []).map((p) => p['platform']['name'] as String).toList();
    final List<Map<String, dynamic>> dPlatforms = (json['parent_platforms'] as List? ?? []).map((p) => {'name': p['platform']['name'] as String, 'id': p['platform']['id'] as int}).toList();
    final List<String> pubList = (json['publishers'] as List? ?? []).map((p) => p['name'] as String).toList();
    final List<String> devList = (json['developers'] as List? ?? []).map((d) => d['name'] as String).toList();
    final String esrb = json['esrb_rating'] != null ? json['esrb_rating']['name'] : 'Not Rated';

    // Date
    String formattedDate = 'TBA';
    if (json['released'] != null) {
      try {
        final DateTime date = DateTime.parse(json['released']);
        const List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        formattedDate = "${months[date.month - 1]} ${date.day}, ${date.year}";
      } catch (_) {
        formattedDate = json['released'];
      }
    }

    // Requirements
    Map<String, String> specs = {'minimum': '', 'recommended': ''};
    if (json['platforms'] != null) {
      final platformsData = json['platforms'] as List;
      for (var p in platformsData) {
        if (p['platform'] != null && p['platform']['slug'] == 'pc') {
          if (p['requirements'] != null) {
            specs['minimum'] = p['requirements']['minimum'] ?? '';
            specs['recommended'] = p['requirements']['recommended'] ?? '';
          }
        }
      }
    }

    // Ratings
    List<Map<String, dynamic>> ratingsDist = [];
    if (json['ratings'] != null) {
      ratingsDist = (json['ratings'] as List).map((r) => {
        'title': r['title'] as String,
        'count': r['count'] as int,
        'percent': (r['percent'] as num).toDouble(),
        'id': r['id'] as int,
      }).toList();
    }

    // --- VIDEO CLIP (Preview Pendek) ---
    String? clipUrl;
    if (json['clip'] != null && json['clip']['clip'] != null) {
      clipUrl = json['clip']['clip'];
    }

    // --- SCREENSHOTS ---
    List<String> screenList = [];
    if (json['extra_screenshots'] != null) {
      screenList = (json['extra_screenshots'] as List).map((s) => s.toString()).toList();
    } else {
      if (json['background_image'] != null) screenList.add(json['background_image']);
      if (json['background_image_additional'] != null) screenList.add(json['background_image_additional']);
    }

    // --- TRAILER URL (FULL) ---
    // Kita cek apakah ada data 'extra_movies' yang di-inject dari service
    String? trailer;
    if (json['extra_movies'] != null && (json['extra_movies'] as List).isNotEmpty) {
      final firstMovie = json['extra_movies'][0];
      // Ambil kualitas max, jika tidak ada ambil 480
      if (firstMovie['data'] != null) {
        trailer = firstMovie['data']['max'] ?? firstMovie['data']['480'];
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
      playtime: json['playtime'] ?? 0,
      screenshots: screenList,
      clip: clipUrl,
      trailerUrl: trailer, // Field baru
      ratingsDistribution: ratingsDist,
    );
  }

  String get mainGenre => genres.isNotEmpty ? genres.first : 'Game';
  String get publisher => publishers.isNotEmpty ? publishers.first : 'Unknown';

  @override
  List<Object?> get props => [
    id, name, backgroundImage, rating, releasedDate, genres,
    metacritic, added, platforms, publishers, developers, esrbRating, 
    description, pcRequirements, detailedGenres, detailedPlatforms,
    playtime, screenshots, clip, trailerUrl, ratingsDistribution
  ];
}