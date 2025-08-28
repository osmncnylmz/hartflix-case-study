import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_shell.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'go_router_refresh.dart';

class AppRouter {
  GoRouter build(BuildContext context) {
    final auth = context.read<AuthCubit>();

    bool _isAuth(GoRouterState s) =>
        s.matchedLocation == '/login' || s.matchedLocation == '/register';

    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(auth.stream),
      redirect: (ctx, state) async {
        final status = auth
            .state
            .status; // 'unknown' | 'authenticated' | 'unauthenticated'

        // Auth durumu bilinmiyorken sadece splash'ta kal
        if (status == 'unknown') {
          return state.matchedLocation == '/splash' ? null : '/splash';
        }

        if (status == 'authenticated' &&
            (state.matchedLocation == '/splash' || _isAuth(state))) {
          return '/home';
        }

        if (status == 'unauthenticated' &&
            !(state.matchedLocation == '/splash' || _isAuth(state))) {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
        GoRoute(path: '/home', builder: (_, __) => const HomeShell()),
      ],
    );
  }
}
