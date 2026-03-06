import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_fuerza_natural_login/core/services/api_service.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/auth/auth_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/navigation/navigation_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/ui/login_page.dart';
import 'package:flutter_fuerza_natural_login/features/ui/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
            seedColor: const Color(0xFF1e5a3a),
            primary: const Color(0xFF1e5a3a),
          ).copyWith(
            
            outline: const Color(0xFFBDBDBD),
            outlineVariant: const Color(0xFFE0E0E0),
            surfaceContainerHighest: const Color(0xFFF0F0F0),
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
          dividerTheme: const DividerThemeData(color: Color(0xFFE0E0E0)),
        ),
        home: const _AppRouter(),
      ),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  StreamSubscription<void>? _unauthorizedSub;
  bool _forcingLogout = false;

  @override
  void initState() {
    super.initState();
    _unauthorizedSub = ApiService().unauthorizedStream.listen((_) {
      if (mounted && !_forcingLogout) {
        _forcingLogout = true;
        context.read<AuthBloc>().add(const AuthForceLogout());
        
        Future.delayed(const Duration(seconds: 2), () => _forcingLogout = false);
      }
    });
  }

  @override
  void dispose() {
    _unauthorizedSub?.cancel();
    super.dispose();
  }

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
            return BlocProvider(
              create: (_) => NavigationBloc(),
              child: const MainShell(),
            );
          }

          
          return const LoginPage();
        },
      ),
    );
  }
}
