import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/styles/sinflix_theme.dart';
import '../../../movies/presentation/cubit/movies_cubit.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'explore_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => MoviesCubit())],
      child: Scaffold(
        backgroundColor: Colors.black,
        body: IndexedStack(
          index: index,
          children: const [ExplorePage(), ProfilePage()],
        ),
        bottomNavigationBar: PillsNav(
          index: index,
          onTap: (i) => setState(() => index = i),
        ),
      ),
    );
  }
}
