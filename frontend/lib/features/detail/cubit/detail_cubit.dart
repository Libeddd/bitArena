// File: lib/features/detail/cubit/detail_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bitArena/data/models/game_model.dart';
import 'package:bitArena/data/repositories/game_repository.dart';

part 'detail_state.dart';

class DetailCubit extends Cubit<DetailState> {
  // POLYMORPHISM: Butuh kontrak repository
  final GameRepository _gameRepository;

  DetailCubit(this._gameRepository) : super(DetailInitial());

  // Fungsi untuk mengambil detail
  void fetchGameDetails(String id) async {
    emit(DetailLoading());
    try {
      // Panggil fungsi dari repository
      final game = await _gameRepository.getGameDetails(id: id);
      emit(DetailSuccess(game));
    } catch (e) {
      emit(DetailError(e.toString()));
    }
  }
}