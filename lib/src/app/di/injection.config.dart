// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:sinflix/src/core/network/dio_module.dart' as _i140;
import 'package:sinflix/src/core/storage/secure_token_store.dart' as _i762;
import 'package:sinflix/src/features/auth/data/auth_repository_impl.dart'
    as _i684;
import 'package:sinflix/src/features/auth/data/auth_service.dart' as _i523;
import 'package:sinflix/src/features/auth/domain/auth_repository.dart' as _i608;
import 'package:sinflix/src/features/movies/data/movie_service.dart' as _i786;
import 'package:sinflix/src/features/movies/data/movies_repository_impl.dart'
    as _i890;
import 'package:sinflix/src/features/movies/domain/movies_repository.dart'
    as _i868;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i762.SecureTokenStore>(() => _i762.SecureTokenStore());
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dio(gh<_i762.SecureTokenStore>()),
    );
    gh.lazySingleton<_i786.MovieService>(
      () => _i786.MovieService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i523.AuthService>(
      () => _i523.AuthService(gh<_i361.Dio>(), gh<_i762.SecureTokenStore>()),
    );
    gh.lazySingleton<_i868.MoviesRepository>(
      () => _i890.MoviesRepositoryImpl(gh<_i786.MovieService>()),
    );
    gh.lazySingleton<_i608.AuthRepository>(
      () => _i684.AuthRepositoryImpl(
        gh<_i523.AuthService>(),
        gh<_i762.SecureTokenStore>(),
        gh<_i786.MovieService>(),
      ),
    );
    return this;
  }
}

class _$NetworkModule extends _i140.NetworkModule {}
