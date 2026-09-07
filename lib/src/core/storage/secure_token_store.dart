import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SecureTokenStore {
  // `encryptedSharedPreferences` is opt-in: without it the Android backend
  // falls back to the legacy KeyStore-wrapped SharedPreferences. The app's
  // minSdk is Flutter's default (24), comfortably above the API 23 this needs.
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  Future<void> saveTokens({required String access, String? refresh}) async {
    await _storage.write(key: _kAccess, value: access);
    if (refresh != null) await _storage.write(key: _kRefresh, value: refresh);
  }

  Future<String?> get accessToken async => _storage.read(key: _kAccess);
  Future<String?> get refreshToken async => _storage.read(key: _kRefresh);

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}
