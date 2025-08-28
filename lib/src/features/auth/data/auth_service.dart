import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/storage/secure_token_store.dart';
import '../../../core/network/json_utils.dart';
import 'models/user_dto.dart';

@lazySingleton
class AuthService {
  final Dio _dio;
  final SecureTokenStore _tokens;
  AuthService(this._dio, this._tokens);

  Future<UserDto> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      '/user/login',
      data: {'email': email, 'password': password},
    );

    final user = unwrapData<UserDto>(res.data, (json) {
      final token = json['token'] as String?;
      if (token != null && token.isNotEmpty) {
        _tokens.saveTokens(access: token);
      }
      return UserDto(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        photoUrl: json['photoUrl'] as String?,
      );
    });

    return user;
  }

  Future<UserDto> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      '/user/register',
      data: {'name': name, 'email': email, 'password': password},
    );

    final user = unwrapData<UserDto>(res.data, (json) {
      final token = json['token'] as String?;
      if (token != null && token.isNotEmpty) {
        _tokens.saveTokens(access: token);
      }
      return UserDto(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        photoUrl: json['photoUrl'] as String?,
      );
    });

    return user;
  }

  Future<UserDto> profile() async {
    final res = await _dio.get('/user/profile');
    return unwrapData<UserDto>(res.data, (json) => UserDto.fromJson(json));
  }

  Future<String> uploadPhoto(String filePath) async {
    final fileName = filePath.split('/').last;
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final res = await _dio.post('/user/upload_photo', data: form);
    return unwrapData<String>(
      res.data,
      (json) => (json['photoUrl'] ?? '').toString(),
    );
  }
}
