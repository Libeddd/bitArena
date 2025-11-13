import 'package:bitArena/data/models/game_model.dart';

/// Ini adalah kontrak (Abstract Class)
/// Semua implementasi repository harus mengikuti ini
abstract class GameRepository {
  Future<List<GameModel>> getGames({int page = 1});
  Future<List<GameModel>> searchGames({required String query});
  Future<GameModel> getGameDetails({required String id});
  Future<List<GameModel>> getGamesByGenre({
    required String genre,
    int page = 1,
  });
}
