part of 'home_bloc.dart'; // Bagian dari file BLoC

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<GameModel> games; // (Asumsi model sudah dibuat)
  const HomeSuccess(this.games);

  @override
  List<Object> get props => [games];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}