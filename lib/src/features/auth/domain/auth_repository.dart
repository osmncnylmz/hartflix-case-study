import '../../movies/data/models/movie_dto.dart';
import '../data/models/user_dto.dart';

abstract class AuthRepository {
  Future<void> login({required String email, required String password});
  Future<void> register({
    required String name,
    required String email,
    required String password,
  });
  Future<bool> isLoggedIn();
  Future<void> logout();
  Future<UserDto> me();
  Future<String> uploadPhoto(String filePath);
  Future<List<MovieDto>> myFavorites();
}
