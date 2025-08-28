import '../data/models/movie_dto.dart';

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
