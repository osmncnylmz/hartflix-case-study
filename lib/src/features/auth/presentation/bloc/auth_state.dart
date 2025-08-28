part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final String status;
  final String? message;

  const AuthState._(this.status, [this.message]);

  const AuthState.unknown() : this._('unknown');
  const AuthState.loading() : this._('loading');
  const AuthState.authenticated() : this._('authenticated');
  const AuthState.unauthenticated() : this._('unauthenticated');
  const AuthState.failure(String msg) : this._('failure', msg);

  bool get isAuthed => status == 'authenticated';

  @override
  List<Object?> get props => [status, message];
}
