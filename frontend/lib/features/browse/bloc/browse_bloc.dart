// File: lib/features/browse/bloc/browse_bloc.dart (FILE BARU)
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bitarena/data/models/game_model.dart';
import 'package:bitarena/data/repositories/game_repository.dart';

// --- EVENT ---
abstract class BrowseEvent extends Equatable {
  const BrowseEvent();
  @override
  List<Object> get props => [];
}

class FetchFilteredGames extends BrowseEvent {
  final Map<String, dynamic> filters;
  const FetchFilteredGames(this.filters);
  @override
  List<Object> get props => [filters];
}

class FetchMoreFilteredGames extends BrowseEvent {}

// --- STATE ---
abstract class BrowseState extends Equatable {
  const BrowseState();
  @override
  List<Object> get props => [];
}

class BrowseInitial extends BrowseState {}
class BrowseLoading extends BrowseState {}

class BrowseSuccess extends BrowseState {
  final List<GameModel> games;
  final int currentPage;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final Map<String, dynamic> currentFilters;

  const BrowseSuccess({
    this.games = const [],
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    required this.currentFilters,
  });

  BrowseSuccess copyWith({
    List<GameModel>? games,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
    Map<String, dynamic>? currentFilters,
  }) {
    return BrowseSuccess(
      games: games ?? this.games,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentFilters: currentFilters ?? this.currentFilters,
    );
  }

  @override
  List<Object> get props => [games, currentPage, hasReachedMax, isLoadingMore, currentFilters];
}

class BrowseError extends BrowseState {
  final String message;
  const BrowseError(this.message);
  @override
  List<Object> get props => [message];
}

// --- BLOC ---
class BrowseBloc extends Bloc<BrowseEvent, BrowseState> {
  final GameRepository _gameRepository;

  BrowseBloc(this._gameRepository) : super(BrowseInitial()) {
    on<FetchFilteredGames>(_onFetchFilteredGames);
    on<FetchMoreFilteredGames>(_onFetchMoreFilteredGames);
  }

  Future<void> _onFetchFilteredGames(
    FetchFilteredGames event,
    Emitter<BrowseState> emit,
  ) async {
    emit(BrowseLoading());
    try {
      final filters = Map<String, dynamic>.from(event.filters);
      filters['page'] = 1;
      
      final games = await _gameRepository.getFilteredGames(filters);
      emit(BrowseSuccess(
        games: games,
        currentPage: 1,
        hasReachedMax: games.isEmpty,
        currentFilters: event.filters, // Simpan filter asli
      ));
    } catch (e) {
      emit(BrowseError(e.toString()));
    }
  }

  Future<void> _onFetchMoreFilteredGames(
    FetchMoreFilteredGames event,
    Emitter<BrowseState> emit,
  ) async {
    final currentState = state;
    if (currentState is BrowseSuccess) {
      if (currentState.hasReachedMax || currentState.isLoadingMore) return;

      emit(currentState.copyWith(isLoadingMore: true));
      try {
        final newPage = currentState.currentPage + 1;
        final filters = Map<String, dynamic>.from(currentState.currentFilters);
        filters['page'] = newPage;

        final newGames = await _gameRepository.getFilteredGames(filters);
        
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