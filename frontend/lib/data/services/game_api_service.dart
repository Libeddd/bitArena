// File: lib/data/services/game_api_service.dart

import 'package:bitarena/core/network/dio_client.dart';
import 'package:bitarena/data/models/game_model.dart';
import 'package:bitarena/data/repositories/game_repository.dart';

class GameApiService implements GameRepository {
  final DioClient _dioClient;
  GameApiService(this._dioClient);

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
      // Panggil 3 endpoint secara paralel untuk performa lebih cepat
      final results = await Future.wait([
        _dioClient.get('games/$id'),             // 0: Detail
        _dioClient.get('games/$id/screenshots'), // 1: Screenshots
        _dioClient.get('games/$id/movies'),      // 2: Trailers (Movies)
      ]);
      
      final detailData = results[0].data as Map<String, dynamic>;
      final screenshotsData = results[1].data;
      final moviesData = results[2].data;

      // 1. Inject Screenshots ke data detail
      if (screenshotsData != null && screenshotsData['results'] != null) {
        final List screens = screenshotsData['results'] as List;
        final List<String> screenUrls = screens.map((s) => s['image'] as String).toList();
        detailData['extra_screenshots'] = screenUrls;
      }

      // 2. Inject Movies (Trailer) ke data detail
      if (moviesData != null && moviesData['results'] != null) {
         final List movies = moviesData['results'] as List;
         detailData['extra_movies'] = movies;
      }

      return GameModel.fromJson(detailData);
    } catch (e) {
      throw Exception('Gagal memuat detail game: $e');
    }
  }

  @override
  Future<List<GameModel>> getFilteredGames(Map<String, dynamic> filters) async {
    try {
      final response = await _dioClient.get('games', queryParameters: filters);
      final List results = response.data['results'] as List;
      return results.map((game) => GameModel.fromJson(game)).toList();
    } catch (e) {
      throw Exception('Gagal memfilter game: $e');
    }
  }

  @override
  Future<List<GameModel>> searchGames({
    required String query,
    Map<String, dynamic> filters = const {},
    int page = 1,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'search': query, 'page': page};
      queryParameters.addAll(filters);
      final response = await _dioClient.get('games', queryParameters: queryParameters);
      final List results = response.data['results'] as List;
      return results.map((game) => GameModel.fromJson(game)).toList();
    } catch (e) {
      throw Exception('Gagal mencari game: $e');
    }
  }
  
  @override
  Future<List<GameModel>> getGamesByGenre({required String genre, int page = 1}) async {
      return getFilteredGames({'genres': genre, 'page': page});
  }
}