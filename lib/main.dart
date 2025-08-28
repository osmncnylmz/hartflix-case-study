import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'src/app/di/injection.dart';
import 'src/app/router/app_router.dart';
import 'src/app/bloc_observer/app_bloc_observer.dart';
import 'src/features/auth/presentation/bloc/auth_cubit.dart';
import 'src/shared/styles/sinflix_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: SinflixTheme.bg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  Bloc.observer = AppBlocObserver();
  await configureDependencies();

  runApp(const SinflixApp());
}

class SinflixApp extends StatelessWidget {
  const SinflixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit()..check(),
      child: Builder(
        builder: (ctx) {
          final router = AppRouter().build(ctx);
          return MaterialApp.router(
            title: 'SINFLIX',
            debugShowCheckedModeBanner: false,
            theme: SinflixTheme.theme(),
            routerConfig: router,
            // iOS'daki "glow" yerine daha pürüzsüz bir kaydırma
            scrollBehavior: const _NoGlowScrollBehavior(),
          );
        },
      ),
    );
  }
}

class _NoGlowScrollBehavior extends MaterialScrollBehavior {
  const _NoGlowScrollBehavior();
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // glow kaldır
  }
}
