import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bitArena/app/app_routes.dart'; 
import 'package:bitArena/core/network/dio_client.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bitArena/data/repositories/game_repository.dart';
import 'package:bitArena/data/services/game_api_service.dart';
import 'package:bitArena/features/auth/cubit/auth_cubit.dart';
import 'package:bitArena/features/detail/cubit/detail_cubit.dart';
import 'package:bitArena/features/home/bloc/home_bloc.dart';
import 'package:bitArena/features/search/bloc/search_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
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
