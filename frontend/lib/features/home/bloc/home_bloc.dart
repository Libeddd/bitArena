// File: lib/features/home/bloc/home_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bitarena/data/models/game_model.dart';
import 'package:bitarena/data/repositories/game_repository.dart';

// --- BAGIAN 1: EVENT ---
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object> get props => [];
}

class HomeFetchList extends HomeEvent {}
class HomeFetchMoreGames extends HomeEvent {}

class HomeSearchGames extends HomeEvent {
  final String query;
  const HomeSearchGames({required this.query});
  @override
  List<Object> get props => [query];
}

class HomeFilterByGenre extends HomeEvent {
  final String genre;
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
class HomeLoading extends HomeState {} 

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
  }

  Future<void> _onFetchHomeList(
    HomeFetchList event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // 1. Ambil List Game Awal (Data Standar: Nama, Gambar, Rating)
      // API ini BELUM memuat deskripsi/about
      List<GameModel> games = await _gameRepository.getGames(page: 1);

      // --- PERBAIKAN KHUSUS BANNER ---
      // Kita ambil detail lengkap untuk 3 game teratas agar Banner punya Deskripsi & Trailer
      if (games.isNotEmpty) {
        final int bannerCount = games.length > 3 ? 3 : games.length;
        
        // Siapkan request paralel agar loading tidak terlalu lama
        final List<Future<GameModel>> detailFutures = [];
        for (int i = 0; i < bannerCount; i++) {
          detailFutures.add(_gameRepository.getGameDetails(id: games[i].id.toString()));
        }

        try {
          // Tunggu semua detail (Description, Clip, Screenshots) selesai dimuat
          final List<GameModel> detailedGames = await Future.wait(detailFutures);
          
          // Replace object game di list dengan versi yang punya detail lengkap
          for (int i = 0; i < bannerCount; i++) {
            games[i] = detailedGames[i];
          }
        } catch (e) {
          // Jika gagal ambil detail, biarkan tampil tanpa deskripsi (jangan crash)
          print("Warning: Gagal memuat detail banner: $e");
        }
      }
      // -------------------------------

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
      final games = await _gameRepository.searchGames(query: event.query);
      emit(HomeSuccess(games: games, currentPage: 1, hasReachedMax: true));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}