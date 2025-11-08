import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/data/models/game_model.dart';
import 'package:frontend/data/repositories/game_repository.dart';

// INHERITANCE: Mengimplementasikan kontrak
class GameRepositoryImpl implements GameRepository {
  final DioClient _dioClient;

  // Dependency di-inject lewat constructor
  GameRepositoryImpl(this._dioClient);

  @override
  Future<List<GameModel>> getGames({int page = 1}) async {
    try {
      final response = await _dioClient.get(
        'games',
        queryParameters: {'page': page, 'page_size': 20},
      );
      
      final List results = response.data['results'] as List;
      // Parsing data (disarankan membuat model terpisah)
      return results.map((game) => GameModel.fromJson(game)).toList();
    } catch (e) {
      throw Exception('Gagal memuat game: $e');
    }
  }

  @override
  Future<List<GameModel>> searchGames({required String query}) async {
    try {
      final response = await _dioClient.get(
        'games',
        queryParameters: {'search': query},
      );
      final List results = response.data['results'] as List;
      return results.map((game) => GameModel.fromJson(game)).toList();
    } catch (e) {
      throw Exception('Gagal mencari game: $e');
    }
  }

  @override
  Future<GameModel> getGameDetails({required String id}) async {
    // ... Logika untuk ambil detail
    throw UnimplementedError();
  }
}