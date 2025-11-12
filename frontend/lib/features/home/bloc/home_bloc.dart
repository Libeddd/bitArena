// File: lib/features/home/bloc/home_bloc.dart (REVISI PAGINATION)

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/data/models/game_model.dart';
import 'package:frontend/data/repositories/game_repository.dart';

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
  const HomeSearchGames(this.query);

  @override
  List<Object> get props => [query];
}

// --- BAGIAN 2: STATE ---
abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {} // Hanya untuk loading awal

// State Success sekarang JAUH LEBIH PINTAR
class HomeSuccess extends HomeState {
  final List<GameModel> games;      // Semua game yang sudah dimuat
  final int currentPage;          // Halaman terakhir yang dimuat
  final bool hasReachedMax;       // Hentikan jika sudah tidak ada data lagi
  final bool isLoadingMore;       // Tanda sedang memuat halaman berikutnya

  const HomeSuccess({
    this.games = const [],
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  // Fungsi 'copyWith' untuk mempermudah update state
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

  // Handler untuk event 'HomeFetchList' (Halaman 1)
  Future<void> _onFetchHomeList(
    HomeFetchList event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading()); // Tampilkan skeleton besar
    try {
      // Ambil data (pastikan service Anda sudah di-update untuk 'page_size: 40')
      final games = await _gameRepository.getGames(page: 1); 
      emit(HomeSuccess(
        games: games,
        currentPage: 1,
        hasReachedMax: games.isEmpty,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  // Handler BARU untuk 'HomeFetchMoreGames' (Halaman 2, 3, ...)
  Future<void> _onFetchMoreGames(
    HomeFetchMoreGames event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeSuccess) {
      // Jangan lakukan apa-apa jika sudah maks atau sedang loading
      if (currentState.hasReachedMax || currentState.isLoadingMore) return;

      // 1. Set state ke 'sedang loading'
      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final newPage = currentState.currentPage + 1;
        final newGames = await _gameRepository.getGames(page: newPage);
        
        if (newGames.isEmpty) {
          // Tidak ada game baru, kita sudah di halaman terakhir
          emit(currentState.copyWith(
            hasReachedMax: true,
            isLoadingMore: false,
          ));
        } else {
          // Ada game baru, tambahkan ke list
          emit(currentState.copyWith(
            games: List.of(currentState.games)..addAll(newGames),
            currentPage: newPage,
            isLoadingMore: false,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
        // Sebaiknya, Anda juga menangani error saat loading lebih banyak
      }
    }
  }

  // Handler untuk 'HomeSearchGames'
  Future<void> _onSearchGames(
    HomeSearchGames event,
    Emitter<HomeState> emit,
  ) async {
    // Pencarian TIDAK MENGGUNAKAN pagination
    // Ia akan mengganti state dan mematikan 'hasReachedMax'
    emit(HomeLoading());
    try {
      final games = await _gameRepository.searchGames(query: event.query);
      emit(HomeSuccess(
        games: games,
        currentPage: 1,
        hasReachedMax: true, // Matikan pagination untuk hasil search
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}