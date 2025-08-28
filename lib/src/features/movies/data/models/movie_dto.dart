class MovieDto {
  final String id;
  final String title;
  final String year;
  final String poster;
  final String description;
  final bool isFavorite;
  final List<String> images;

  MovieDto({
    required this.id,
    required this.title,
    required this.year,
    required this.poster,
    required this.description,
    required this.isFavorite,
    this.images = const [],
  });

  factory MovieDto.fromJson(Map<String, dynamic> json) {
    return MovieDto(
      id: json["id"]?.toString() ?? "",
      title: json["Title"] ?? "",
      year: json["Year"]?.toString() ?? "",
      poster: json["Poster"] ?? "",
      description: json["Plot"] ?? "",
      isFavorite: json["isFavorite"] ?? false,
      images:
          (json["Images"] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [], //
    );
  }

  String get posterUrl => poster; // UI için kısayol
}
