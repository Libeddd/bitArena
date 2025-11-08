import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/data/models/game_model.dart';
import 'package:frontend/data/repositories/game_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GameRepository _gameRepository; // <-- POLYMORPHISM

  HomeBloc(this._gameRepository) : super(HomeInitial()) {
    // POLYMORPHISM: BLoC tidak tahu implementasinya (Impl),
    // BLoC hanya tahu kontraknya (GameRepository).
    
    on<FetchHomeGames>(_onFetchHomeGames);
    on<SearchGames>(_onSearchGames);
  }

  Future<void> _onFetchHomeGames(
    FetchHomeGames event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final games = await _gameRepository.getGames();
      emit(HomeSuccess(games));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onSearchGames(
    SearchGames event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading()); // Tampilkan loading saat mencari
    try {
      final games = await _gameRepository.searchGames(query: event.query);
      emit(HomeSuccess(games));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}