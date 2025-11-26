import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bitarena/app/app_routes.dart'; 
import 'package:bitarena/core/network/dio_client.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bitarena/data/repositories/game_repository.dart';
import 'package:bitarena/data/services/game_api_service.dart';
import 'package:bitarena/features/auth/cubit/auth_cubit.dart';
import 'package:bitarena/features/detail/cubit/detail_cubit.dart';
import 'package:bitarena/features/wishlist/cubit/wishlist_cubit.dart';
import 'package:bitarena/features/home/bloc/home_bloc.dart';
import 'package:bitarena/features/search/bloc/search_bloc.dart';
import 'package:bitarena/features/browse/bloc/browse_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bitarena/firebase_options.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );

  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  
  usePathUrlStrategy();
  final DioClient dioClient = DioClient();
  final GameRepository gameRepository = GameApiService(dioClient);

  runApp(MyApp(gameRepository: gameRepository));
}

class MyApp extends StatelessWidget {
  final GameRepository gameRepository;

  const MyApp({super.key, required this.gameRepository});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: gameRepository,
      child: MultiBlocProvider(
        providers: [
          
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(), 
          ),
          
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(
              
              context.read<GameRepository>(),
            ),
          ),
          
          BlocProvider<DetailCubit>(
            create: (context) => DetailCubit(
              context.read<GameRepository>(),
              ),
          ),

          BlocProvider<SearchBloc>(
            create: (context) => SearchBloc(
              context.read<GameRepository>(),
            ),
          ),

        BlocProvider<BrowseBloc>(
            create: (context) => BrowseBloc(
              context.read<GameRepository>(),
            ),
          ),

        BlocProvider<WishlistCubit>(
            create: (context) => WishlistCubit(),
          ),
        ],
        child: MaterialApp.router(
          title: 'bitArena',
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF121212),
            textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme
            )
          ),
          debugShowCheckedModeBanner: false,        
          routerConfig: AppRoutes.router,
        ),
      ),
    );
  }
}
