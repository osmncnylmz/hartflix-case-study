import 'package:injectable/injectable.dart';
import '../../../core/storage/secure_token_store.dart';
import '../../movies/data/movie_service.dart';
import '../../movies/data/models/movie_dto.dart';
import 'auth_service.dart';
import '../domain/auth_repository.dart';
import 'models/user_dto.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service;
  final SecureTokenStore _tokens;
  final MovieService _movies;

  AuthRepositoryImpl(this._service, this._tokens, this._movies);

  @override
  Future<void> login({required String email, required String password}) async {
    await _service.login(email: email, password: password);
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _service.register(name: name, email: email, password: password);
  }

  @override
  Future<bool> isLoggedIn() async => (await _tokens.accessToken) != null;

  @override
  Future<void> logout() async => _tokens.clear();

  @override
  Future<UserDto> me() => _service.profile();

  @override
  Future<String> uploadPhoto(String filePath) => _service.uploadPhoto(filePath);

  @override
  Future<List<MovieDto>> myFavorites() => _movies.favoriteList();
}
