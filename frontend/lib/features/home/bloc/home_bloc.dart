import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bitArena/data/models/game_model.dart';
import 'package:bitArena/data/repositories/game_repository.dart';

// --- BAGIAN 1: EVENT ---
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object> get props => [];
}

// Event untuk mengambil daftar game awal (halaman 1)
class HomeFetchList extends HomeEvent {}

// Event BARU untuk mengambil halaman berikutnya
class HomeFetchMoreGames extends HomeEvent {}

// Event untuk pencarian (ini akan mematikan pagination)
class HomeSearchGames extends HomeEvent {
  final String query;
  // DIUBAH: Menggunakan named parameter
  const HomeSearchGames({required this.query});

  @override
  List<Object> get props => [query];
}

// Event untuk filter berdasarkan genre
class HomeFilterByGenre extends HomeEvent {
  final String genre;
  // DIUBAH: Menggunakan named parameter
  const HomeFilterByGenre({required this.genre});

  @override
  List<Object> get props => [genre];
}

// --- BAGIAN 2: STATE ---
abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {} // Hanya untuk loading awal

class HomeSuccess extends HomeState {
  final List<GameModel> games;
  final int currentPage;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const HomeSuccess({
    this.games = const [],
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  HomeSuccess copyWith({
    List<GameModel>? games,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return HomeSuccess(
      games: games ?? this.games,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [games, currentPage, hasReachedMax, isLoadingMore];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}

// --- BAGIAN 3: BLOC ---
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GameRepository _gameRepository;

  HomeBloc(this._gameRepository) : super(HomeInitial()) {
    on<HomeFetchList>(_onFetchHomeList);
    on<HomeFetchMoreGames>(_onFetchMoreGames);
    on<HomeSearchGames>(_onSearchGames);
    on<HomeFilterByGenre>(_onFilterByGenre);
  }

  Future<void> _onFetchHomeList(
    HomeFetchList event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final games = await _gameRepository.getGames(page: 1);
      emit(
        HomeSuccess(games: games, currentPage: 1, hasReachedMax: games.isEmpty),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onFetchMoreGames(
    HomeFetchMoreGames event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeSuccess) {
      if (currentState.hasReachedMax || currentState.isLoadingMore) return;

      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final newPage = currentState.currentPage + 1;
        final newGames = await _gameRepository.getGames(page: newPage);

        if (newGames.isEmpty) {
          emit(
            currentState.copyWith(hasReachedMax: true, isLoadingMore: false),
          );
        } else {
          emit(
            currentState.copyWith(
              games: List.of(currentState.games)..addAll(newGames),
              currentPage: newPage,
              isLoadingMore: false,
            ),
          );
        }
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> _onSearchGames(
    HomeSearchGames event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // Pastikan Anda memanggil event.query di sini
      final games = await _gameRepository.searchGames(query: event.query);
      emit(HomeSuccess(games: games, currentPage: 1, hasReachedMax: true));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onFilterByGenre(
    HomeFilterByGenre event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // DIPERBAIKI: Menambahkan "genre:"
      final games = await _gameRepository.getGamesByGenre(genre: event.genre);
      emit(HomeSuccess(games: games, currentPage: 1, hasReachedMax: true));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
