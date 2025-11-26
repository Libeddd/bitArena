// File: lib/features/wishlist/cubit/wishlist_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bitarena/data/models/game_model.dart';

// --- STATE ---
class WishlistState extends Equatable {
  final List<GameModel> wishlist;

  const WishlistState({this.wishlist = const []});

  @override
  List<Object> get props => [wishlist];
}

// --- CUBIT ---
class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit() : super(const WishlistState());

  void toggleWishlist(GameModel game) {
    final List<GameModel> currentList = List.from(state.wishlist);
    
    // Cek apakah game sudah ada di wishlist berdasarkan ID
    final index = currentList.indexWhere((g) => g.id == game.id);

    if (index >= 0) {
      // Jika ada, hapus (Remove)
      currentList.removeAt(index);
    } else {
      // Jika tidak ada, tambah (Add)
      currentList.add(game);
    }

    emit(WishlistState(wishlist: currentList));
  }

  // Helper untuk mengecek status di UI
  bool isWishlisted(int gameId) {
    return state.wishlist.any((game) => game.id == gameId);
  }
}