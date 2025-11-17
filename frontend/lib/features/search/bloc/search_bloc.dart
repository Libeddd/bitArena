// File: lib/features/search/bloc/search_bloc.dart (FILE BARU)

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bitArena/data/models/game_model.dart';
import 'package:bitArena/data/repositories/game_repository.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object> get props => [];
}

// Event untuk pencarian baru (atau saat filter berubah)
class PerformSearch extends SearchEvent {
  final String query;
  final Map<String, dynamic> filters;
  const PerformSearch(this.query, this.filters);
  @override
  List<Object> get props => [query, filters];
}

// Event untuk pagination
class FetchMoreSearchResults extends SearchEvent {}

// --- 2. STATE ---
abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}
class SearchLoading extends SearchState {}

// State Success sekarang melacak semua filter dan pagination
class SearchSuccess extends SearchState {
  final List<GameModel> games;
  final int currentPage;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String currentQuery;
  final Map<String, dynamic> currentFilters;

  const SearchSuccess({
    this.games = const [],
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    required this.currentQuery,
    required this.currentFilters,
  });

  SearchSuccess copyWith({
    List<GameModel>? games,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return SearchSuccess(
      games: games ?? this.games,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentQuery: currentQuery, // Selalu teruskan nilai lama
      currentFilters: currentFilters, // Selalu teruskan nilai lama
    );
  }

  @override
  List<Object> get props => [games, currentPage, hasReachedMax, isLoadingMore, currentQuery, currentFilters];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
  @override
  List<Object> get props => [message];
}

// --- 3. BLOC ---
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final GameRepository _gameRepository;

  SearchBloc(this._gameRepository) : super(SearchInitial()) {
    on<PerformSearch>(_onPerformSearch);
    on<FetchMoreSearchResults>(_onFetchMoreSearchResults);
  }

  // Handler untuk pencarian baru
  Future<void> _onPerformSearch(
    PerformSearch event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    try {
      final games = await _gameRepository.searchGames(
        query: event.query,
        filters: event.filters,
        page: 1,
      );
      emit(SearchSuccess(
        games: games,
        currentPage: 1,
        hasReachedMax: games.isEmpty,
        currentQuery: event.query,
        currentFilters: event.filters,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  // Handler untuk pagination
  Future<void> _onFetchMoreSearchResults(
    FetchMoreSearchResults event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is SearchSuccess) {
      if (currentState.hasReachedMax || currentState.isLoadingMore) return;

      emit(currentState.copyWith(isLoadingMore: true));
      try {
        final newPage = currentState.currentPage + 1;
        final newGames = await _gameRepository.searchGames(
          query: currentState.currentQuery,
          filters: currentState.currentFilters,
          page: newPage,
        );
        
        if (newGames.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true, isLoadingMore: false));
        } else {
          emit(currentState.copyWith(
            games: List.of(currentState.games)..addAll(newGames),
            currentPage: newPage,
            isLoadingMore: false,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }
}