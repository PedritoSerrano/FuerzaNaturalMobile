import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/auth/auth_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/explorar/explorar_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/navigation/navigation_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/reservas/mis_reservas_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/ui/explorar_page.dart';
import 'package:flutter_fuerza_natural_login/features/ui/reservas_page.dart';
import 'package:flutter_fuerza_natural_login/features/ui/perfil_page.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId =
        authState is AuthAuthenticated ? authState.user.id : null;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MisReservasBloc()
            ..add(const MisReservasLoadRequested()),
        ),
        BlocProvider(
          create: (_) => ExplorarBloc(currentUserId: userId)
            ..add(const ExplorarLoadRequested()),
        ),
      ],
      child: BlocListener<NavigationBloc, NavigationState>(
        listenWhen: (prev, curr) => prev.currentIndex != curr.currentIndex,
        listener: (context, state) {
          // Reload the page that just became visible
          switch (state.currentIndex) {
            case 0:
              context
                  .read<ExplorarBloc>()
                  .add(const ExplorarLoadRequested());
            case 1:
              context
                  .read<MisReservasBloc>()
                  .add(const MisReservasLoadRequested());
          }
        },
        child: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) {
            return Scaffold(
              body: IndexedStack(
                index: state.currentIndex,
                children: const [
                  ExplorarPage(),
                  ReservasPage(),
                  PerfilPage(),
                ],
              ),
              bottomNavigationBar:
                  _BottomNav(currentIndex: state.currentIndex),
            );
          },
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) =>
            context.read<NavigationBloc>().add(NavigationTabChanged(i)),
        selectedItemColor: const Color(0xFF1e5a3a),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
