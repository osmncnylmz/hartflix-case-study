import '../data/models/movie_dto.dart';
import 'movies_page.dart';

export 'movies_page.dart';

abstract class MoviesRepository {
  /// One page of the catalogue. The implementation trims each page to the
  /// fixed page size used by the Explore feed.
  Future<MoviesPage> page({int page = 1});

  /// The movies the signed-in user has favourited.
  Future<List<MovieDto>> favorites();

  /// Toggles the favourite flag for [movieId] and returns the new state
  /// (`true` when the movie is now a favourite).
  Future<bool> toggleFavorite(String movieId);

  /// A de-duplicated random selection drawn from across the catalogue.
  Future<List<MovieDto>> randomMovies({int count = 6});
}
