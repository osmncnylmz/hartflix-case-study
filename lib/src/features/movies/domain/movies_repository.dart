import '../data/models/movie_dto.dart';

abstract class MoviesRepository {
  /// Explore'un sabit sayfa boyutuna kırpılmış tek sayfa
  Future<MoviesPage> page({int page = 1});

  Future<List<MovieDto>> favorites();

  /// Toggle sonrası yeni durumu döner ("artık favori mi"), başarı flag'i değil
  Future<bool> toggleFavorite(String movieId);

  /// Explore için rastgele filmler, tekrarsız
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
