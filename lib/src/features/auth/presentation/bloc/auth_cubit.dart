import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/auth_repository.dart';
import '../../../../app/di/injection.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo = getIt<AuthRepository>();

  AuthCubit() : super(const AuthState.unknown());

  Future<void> check() async {
    final ok = await _repo.isLoggedIn();
    emit(ok ? const AuthState.authenticated() : const AuthState.unauthenticated());
  }

  Future<void> login(String email, String password) async {
    emit(const AuthState.loading());
    try {
      await _repo.login(email: email, password: password);
      emit(const AuthState.authenticated());
    } catch (e) {
      emit(AuthState.failure('Giriş başarısız: $e'));
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> register(String name, String email, String password) async {
    emit(const AuthState.loading());
    try {
      await _repo.register(name: name, email: email, password: password);
      emit(const AuthState.authenticated());
    } catch (e) {
      emit(AuthState.failure('Kayıt başarısız: $e'));
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(const AuthState.unauthenticated());
  }
}
