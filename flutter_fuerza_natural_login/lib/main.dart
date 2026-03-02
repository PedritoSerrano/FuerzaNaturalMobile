import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/auth/auth_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/navigation/navigation_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/explorar/explorar_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/perfil/perfil_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/fincas/mis_fincas_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/reservas/mis_reservas_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/ui/login_page.dart';
import 'package:flutter_fuerza_natural_login/features/ui/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TEMPORAL: limpia token guardado para forzar login
  await const FlutterSecureStorage().deleteAll();
  runApp(const FuerzaNaturalApp());
}

class FuerzaNaturalApp extends StatelessWidget {
  const FuerzaNaturalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc()..add(const AuthCheckRequested()),
      child: MaterialApp(
        title: 'Fuerza Natural',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            primary: const Color(0xFF2E7D32),
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const _AppRouter(),
      ),
    );
  }
}

/// Listens to AuthBloc and decides whether to show LoginPage or MainShell.
class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, current) => current is AuthError,
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Scaffold(
              backgroundColor: Color(0xFF1e5a3a),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.terrain, color: Colors.white, size: 64),
                    SizedBox(height: 20),
                    CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              ),
            );
          }

          if (state is AuthAuthenticated) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => NavigationBloc()),
                BlocProvider(
                  create: (_) =>
                      ExplorarBloc()..add(const ExplorarLoadRequested()),
                ),
                BlocProvider(
                  create: (_) =>
                      PerfilBloc()..add(const PerfilLoadRequested()),
                ),
                BlocProvider(
                  create: (_) =>
                      MisFincasBloc()..add(const MisFincasLoadRequested()),
                ),
                BlocProvider(
                  create: (_) =>
                      MisReservasBloc()..add(const MisReservasLoadRequested()),
                ),
              ],
              child: const MainShell(),
            );
          }

          // AuthUnauthenticated o AuthError → mostrar LoginPage
          return const LoginPage();
        },
      ),
    );
  }
}

