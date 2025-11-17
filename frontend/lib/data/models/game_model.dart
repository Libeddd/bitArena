// File: lib/data/models/game_model.dart (UPGRADED)

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
  final String publisher;

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
    required this.publisher,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    // Ekstrak list genre (kategori)
    final List<String> genreList = (json['genres'] as List? ?? [])
        .map((genre) => genre['name'] as String)
        .toList();
    
    final String release = json['released'] ?? 'N/A';
    final String year = release.split('-').first;

    final List<String> platformList = (json['parent_platforms'] as List? ?? [])
        .map((p) => p['platform']['name'] as String)
        .toList();
    final List publisherList = (json['publishers'] as List? ?? []);
    final String publisherName = publisherList.isNotEmpty 
        ? publisherList[0]['name'] as String 
        : 'Unknown';

    return GameModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      backgroundImage: json['background_image'] ?? 'https://via.placeholder.com/150',
      rating: (json['rating'] ?? 0.0).toDouble(),
      releasedDate: year,
      genres: genreList,
      metacritic: json['metacritic'] ?? 0,
      added: json['added'] ?? 0,
      platforms: platformList,
      publisher: publisherName,
    );
  }

  String get mainGenre => genres.isNotEmpty ? genres.first : 'Game';

  @override
  List<Object?> get props => [
    id, name, backgroundImage, rating, releasedDate, genres,
    metacritic, added, platforms, publisher];
}