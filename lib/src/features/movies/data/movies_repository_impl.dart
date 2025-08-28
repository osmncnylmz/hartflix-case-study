import 'package:injectable/injectable.dart';
import 'movie_service.dart';
import '../domain/movies_repository.dart';
import 'models/movie_dto.dart';

@LazySingleton(as: MoviesRepository)
class MoviesRepositoryImpl implements MoviesRepository {
  final MovieService _api;
  MoviesRepositoryImpl(this._api);

  @override
  Future<MoviesPage> page({int page = 1}) async {
    final env = await _api.listMovies(page: page);
    final items = env.movies.take(5).toList();
    return MoviesPage(
      items: items,
      currentPage: env.currentPage,
      totalPages: env.totalPages,
    );
  }

  @override
  Future<List<MovieDto>> favorites() => _api.favoriteList();

  @override
  Future<bool> toggleFavorite(String movieId) async {
    final resp = await _api.toggleFavorite(movieId);
    return resp.action == "favorited";
  }

  @override
  Future<List<MovieDto>> randomMovies({int count = 6}) {
    return _api.randomMovies(count: count);
  }
}
