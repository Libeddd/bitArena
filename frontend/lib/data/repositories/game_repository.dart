// File: lib/data/repositories/game_repository.dart

import 'package:frontend/data/models/game_model.dart';

// Ini adalah "Kontrak" (Abstract)
// BLoC akan bergantung pada ini, bukan pada implementasinya
abstract class GameRepository {
  Future<List<GameModel>> getGames({int page = 1});
  Future<List<GameModel>> searchGames({required String query});
  Future<GameModel> getGameDetails({required String id});
}