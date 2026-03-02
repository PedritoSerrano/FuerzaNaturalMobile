import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuerza_natural_login/core/models/user_model.dart';
import 'package:flutter_fuerza_natural_login/core/services/auth_repository.dart';

part 'perfil_event.dart';
part 'perfil_state.dart';

class PerfilBloc extends Bloc<PerfilEvent, PerfilState> {
  final AuthRepository _repo;

  PerfilBloc({AuthRepository? repo})
      : _repo = repo ?? AuthRepository(),
        super(const PerfilInitial()) {
    on<PerfilLoadRequested>(_onLoadRequested);
    on<PerfilCerrarSesionRequested>(_onCerrarSesion);
  }

  Future<void> _onLoadRequested(
    PerfilLoadRequested event,
    Emitter<PerfilState> emit,
  ) async {
    emit(const PerfilLoading());
    try {
      final user = await _repo.getMe();
      emit(PerfilLoaded(user: user));
    } catch (e) {
      emit(PerfilError(e.toString()));
    }
  }

  Future<void> _onCerrarSesion(
    PerfilCerrarSesionRequested event,
    Emitter<PerfilState> emit,
  ) async {
    await _repo.logout();
    emit(const PerfilSesionCerrada());
  }
}
