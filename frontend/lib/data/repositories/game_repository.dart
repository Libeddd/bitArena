import 'package:bitArena/data/models/game_model.dart';

abstract class GameRepository {
  Future<List<GameModel>> getGames({int page = 1});
  
  // --- PERBAIKAN: Perbarui tanda tangan (signature) fungsi ini ---
  Future<List<GameModel>> searchGames({
    required String query,
    Map<String, dynamic> filters = const {},
    int page = 1,
  });
  // --- BATAS PERBAIKAN ---

  Future<GameModel> getGameDetails({required String id});
  Future<List<GameModel>> getFilteredGames(Map<String, dynamic> filters);
}
