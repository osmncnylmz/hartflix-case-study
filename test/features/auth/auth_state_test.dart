import 'package:flutter_test/flutter_test.dart';
import 'package:sinflix/src/features/auth/presentation/bloc/auth_cubit.dart';

void main() {
  group('AuthState', () {
    // The router keys its redirects off these exact status strings.
    test('exposes the status string the router redirects on', () {
      expect(const AuthState.unknown().status, 'unknown');
      expect(const AuthState.loading().status, 'loading');
      expect(const AuthState.authenticated().status, 'authenticated');
      expect(const AuthState.unauthenticated().status, 'unauthenticated');
      expect(const AuthState.failure('nope').status, 'failure');
    });

    test('isAuthed is true only for the authenticated state', () {
      expect(const AuthState.authenticated().isAuthed, isTrue);
      expect(const AuthState.unknown().isAuthed, isFalse);
      expect(const AuthState.loading().isAuthed, isFalse);
      expect(const AuthState.unauthenticated().isAuthed, isFalse);
      expect(const AuthState.failure('nope').isAuthed, isFalse);
    });

    test('carries a message only on failure', () {
      expect(const AuthState.failure('boom').message, 'boom');
      expect(const AuthState.authenticated().message, isNull);
    });

    test('is compared by value', () {
      expect(const AuthState.authenticated(), const AuthState.authenticated());
      expect(const AuthState.failure('a'), isNot(const AuthState.failure('b')));
      expect(
        const AuthState.unknown(),
        isNot(const AuthState.unauthenticated()),
      );
    });
  });
}
