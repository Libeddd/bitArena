// File: lib/data/models/game_model.dart

import 'package:equatable/equatable.dart';

// Menggunakan Equatable agar BLoC bisa membandingkan state
class GameModel extends Equatable {
  final int id;
  final String name;
  final String backgroundImage;
  final double rating;

  const GameModel({
    required this.id,
    required this.name,
    required this.backgroundImage,
    required this.rating,
  });

  // Factory constructor untuk parsing JSON dari API
  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      // API RAWG terkadang tidak mengirim gambar
      backgroundImage: json['background_image'] ?? 'https://via.placeholder.com/150',
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, name, backgroundImage, rating];
}