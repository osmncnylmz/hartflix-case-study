import '../data/models/movie_dto.dart';

abstract class MoviesRepository {
  Future<MoviesPage> page({int page = 1});

  Future<List<MovieDto>> favorites();

  Future<bool> toggleFavorite(String movieId);

  /// Explore için rastgele filmler
  Future<List<MovieDto>> randomMovies({int count = 6});
}

class MoviesPage {
  final List<MovieDto> items;
  final int currentPage;
  final int totalPages;

  MoviesPage({
    required this.items,
    required this.currentPage,
    required this.totalPages,
  });
}
