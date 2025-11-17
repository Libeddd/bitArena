import 'package:bitArena/core/network/dio_client.dart';
import 'package:bitArena/data/models/game_model.dart';
import 'package:bitArena/data/repositories/game_repository.dart';

// INHERITANCE: Mengimplementasikan kontrak GameRepository
abstract class GameRepositoryImpl implements GameRepository {
  final DioClient _dioClient;

  GameRepositoryImpl(this._dioClient);

  @override
  Future<List<GameModel>> getGames({int page = 1}) async {
    try {
      final response = await _dioClient.get(
        'games',
        queryParameters: {'page': page, 'page_size': 20},
      );

      final List results = response.data['results'] as List;
      return results.map((game) => GameModel.fromJson(game)).toList();
    } catch (e) {
      throw Exception('Gagal memuat game: $e');
    }
  }

  @override
  Future<GameModel> getGameDetails({required String id}) async {
    try {
      final response = await _dioClient.get('games/$id');
      return GameModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Gagal memuat detail game: $e');
    }
  }

  /// 🔽 Tambahan baru untuk filter berdasarkan genre
  @override
  Future<List<GameModel>> getGamesByGenre({
    required String genre,
    int page = 1,
  }) async {
    try {
      final response = await _dioClient.get(
        'games',
        queryParameters: {'genres': genre, 'page': page, 'page_size': 20},
      );
      final List results = response.data['results'] as List;
      return results.map((game) => GameModel.fromJson(game)).toList();
    } catch (e) {
      throw Exception('Gagal memuat game berdasarkan genre: $e');
    }
  }
}
