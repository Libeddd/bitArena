part of 'home_bloc.dart'; // Bagian dari file BLoC

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object> get props => [];
}

// Event saat halaman dimuat
class FetchHomeGames extends HomeEvent {}

// Event saat pengguna mengetik di search bar
class SearchGames extends HomeEvent {
  final String query;
  const SearchGames(this.query);

  @override
  List<Object> get props => [query];
}