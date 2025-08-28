import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../storage/secure_token_store.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(SecureTokenStore tokens) {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://caseapi.servicelabs.tech',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokens.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    return dio;
  }
}
