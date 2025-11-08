// File: lib/features/detail/cubit/detail_state.dart

part of 'detail_cubit.dart'; // Akan terhubung ke Cubit

abstract class DetailState extends Equatable {
  const DetailState();
  @override
  List<Object> get props => [];
}

class DetailInitial extends DetailState {}
class DetailLoading extends DetailState {}

class DetailSuccess extends DetailState {
  // Kita gunakan GameModel yang sudah kita buat
  final GameModel game;
  const DetailSuccess(this.game);

  @override
  List<Object> get props => [game];
}

class DetailError extends DetailState {
  final String message;
  const DetailError(this.message);

  @override
  List<Object> get props => [message];
}