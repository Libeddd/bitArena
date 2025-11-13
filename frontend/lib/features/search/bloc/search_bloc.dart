// File: lib/features/search/bloc/search_bloc.dart (FILE BARU)

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bitArena/data/models/game_model.dart';
import 'package:bitArena/data/repositories/game_repository.dart';

// --- BAGIAN 1: EVENT ---
abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object> get props => [];
}

// Event untuk melakukan pencarian
class PerformSearch extends SearchEvent {
  final String query;
  const PerformSearch(this.query);

  @override
  List<Object> get props => [query];
}

// --- BAGIAN 2: STATE ---
abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}
class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<GameModel> games;
  const SearchSuccess(this.games);

  @override
  List<Object> get props => [games];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}

// --- BAGIAN 3: BLOC ---
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final GameRepository _gameRepository;

  SearchBloc(this._gameRepository) : super(SearchInitial()) {
    on<PerformSearch>(_onPerformSearch);
  }

  Future<void> _onPerformSearch(
    PerformSearch event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    try {
      final games = await _gameRepository.searchGames(query: event.query);
      emit(SearchSuccess(games));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}