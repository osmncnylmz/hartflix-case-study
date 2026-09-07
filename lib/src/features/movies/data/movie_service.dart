import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/network/json_utils.dart';
import 'models/movie_dto.dart';

@LazySingleton()
class MovieService {
  final Dio _dio;
  MovieService(this._dio);

  Future<MovieListEnvelope> listMovies({required int page}) async {
    final res = await _dio.get('/movie/list', queryParameters: {'page': page});

    return unwrapData<MovieListEnvelope>(
      res.data,
      (json) => MovieListEnvelope.fromJson(json),
    );
  }

  Future<List<MovieDto>> favoriteList() async {
    final res = await _dio.get('/movie/favorites');

    final list = res.data["data"] as List<dynamic>? ?? const [];

    return list
        .map((e) => MovieDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ToggleFavoriteEnvelope> toggleFavorite(String movieId) async {
    final res = await _dio.post('/movie/favorite/$movieId');
    return unwrapData<ToggleFavoriteEnvelope>(
      res.data,
      (json) => ToggleFavoriteEnvelope.fromJson(json),
    );
  }

  /// Rastgele [count] film. Tek sayfa yetmediği için farklı sayfalara
  /// dağılır; postersizler elenir, aynı id iki kez girmez.
  Future<List<MovieDto>> randomMovies({int count = 6}) async {
    final first = await listMovies(page: 1);
    final totalPages = first.totalPages <= 0 ? 1 : first.totalPages;

    final rnd = math.Random();
    final picked = <MovieDto>[];
    final seenIds = <String>{};

    bool accept(MovieDto m) {
      final poster = (m.posterUrl).toString().trim();
      return poster.isNotEmpty && seenIds.add(m.id);
    }

    final seed = [...first.movies]..shuffle(rnd);
    for (final m in seed) {
      if (accept(m)) picked.add(m);
      if (picked.length == count) return picked;
    }

    // Eksik kalanı rastgele sayfalardan tamamla. safety olmazsa, çoğu sayfası
    // postersiz gelen bir katalogda while sonsuza kadar dönüyor.
    int safety = totalPages * 2 + 4;

    while (picked.length < count && safety-- > 0) {
      final page = 1 + rnd.nextInt(totalPages);
      final env = await listMovies(page: page);
      if (env.movies.isEmpty) {
        if (totalPages == 1) break;
        continue;
      }

      final list = [...env.movies]..shuffle(rnd);
      for (final m in list) {
        if (accept(m)) picked.add(m);
        if (picked.length == count) break;
      }
    }

    return picked;
  }
}

class MovieListEnvelope {
  final List<MovieDto> movies;
  final int totalPages;
  final int currentPage;

  MovieListEnvelope({
    required this.movies,
    required this.totalPages,
    required this.currentPage,
  });

  factory MovieListEnvelope.fromJson(Map<String, dynamic> json) {
    final moviesJson = (json['movies'] as List<dynamic>? ?? const []);
    final pagination =
        (json['pagination'] as Map<String, dynamic>? ?? const {});

    return MovieListEnvelope(
      movies: moviesJson
          .map((e) => MovieDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: (pagination['maxPage'] ?? json['totalPages'] ?? 1) as int,
      currentPage:
          (pagination['currentPage'] ?? json['currentPage'] ?? 1) as int,
    );
  }
}

class ToggleFavoriteEnvelope {
  final MovieDto movie;
  final String action; // "favorited" | "unfavorited"

  ToggleFavoriteEnvelope({required this.movie, required this.action});

  factory ToggleFavoriteEnvelope.fromJson(Map<String, dynamic> json) {
    // Buraya gelen gövde unwrapData'dan geçmiş oluyor; data'yı ikinci kez
    // soymak action'ı hep boş bırakıyor, yani toggleFavorite daima false.
    // Her iki şekli de kabul et.
    final nested = json['data'];
    final data = nested is Map<String, dynamic> ? nested : json;

    final movie = data['movie'];
    return ToggleFavoriteEnvelope(
      movie: MovieDto.fromJson(
        movie is Map<String, dynamic> ? movie : const <String, dynamic>{},
      ),
      action: (data['action'] ?? '').toString(),
    );
  }
}
