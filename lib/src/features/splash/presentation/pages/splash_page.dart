import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _fallback;

  @override
  void initState() {
    super.initState();

    // Fallback: 2 sn içinde auth durumu gelmezse login'e geç
    _fallback = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go('/login');
    });
  }

  @override
  void dispose() {
    _fallback?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (!mounted) return;
        if (state.status == 'authenticated') {
          _fallback?.cancel();
          context.go('/home');
        } else if (state.status == 'unauthenticated') {
          _fallback?.cancel();
          context.go('/login');
        }
      },
      child: const Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(
          child: Image(
            image: AssetImage('assets/sin_flix_splash.png'),
            fit: BoxFit.cover, // tam ekran
          ),
        ),
      ),
    );
  }
}
