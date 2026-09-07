import 'package:flutter_test/flutter_test.dart';
import 'package:sinflix/src/features/movies/data/models/movie_dto.dart';
import 'package:sinflix/src/features/movies/data/movie_service.dart';

void main() {
  group('MovieDto.fromJson', () {
    // The catalogue is served with OMDb-style capitalised keys.
    test('maps the OMDb-style keys onto the DTO', () {
      final dto = MovieDto.fromJson(<String, dynamic>{
        'id': '5d4f9c1a',
        'Title': 'Blade Runner',
        'Year': '1982',
        'Poster': 'https://example.test/poster.jpg',
        'Plot': 'A blade runner must pursue replicants.',
        'isFavorite': true,
        'Images': ['https://example.test/1.jpg', 'https://example.test/2.jpg'],
      });

      expect(dto.id, '5d4f9c1a');
      expect(dto.title, 'Blade Runner');
      expect(dto.year, '1982');
      expect(dto.poster, 'https://example.test/poster.jpg');
      expect(dto.description, 'A blade runner must pursue replicants.');
      expect(dto.isFavorite, isTrue);
      expect(dto.images, hasLength(2));
    });

    test('coerces a numeric id and year to String', () {
      final dto = MovieDto.fromJson(<String, dynamic>{'id': 7, 'Year': 1982});

      expect(dto.id, '7');
      expect(dto.year, '1982');
    });

    test('defaults every missing field instead of throwing', () {
      final dto = MovieDto.fromJson(<String, dynamic>{});

      expect(dto.id, '');
      expect(dto.title, '');
      expect(dto.year, '');
      expect(dto.poster, '');
      expect(dto.description, '');
      expect(dto.isFavorite, isFalse);
      expect(dto.images, isEmpty);
    });

    test('exposes poster through the posterUrl shorthand', () {
      final dto = MovieDto.fromJson(<String, dynamic>{
        'Poster': 'https://example.test/p.jpg',
      });

      expect(dto.posterUrl, dto.poster);
    });
  });

  group('MovieListEnvelope.fromJson', () {
    test('reads paging from the "pagination" block', () {
      final env = MovieListEnvelope.fromJson(<String, dynamic>{
        'movies': [
          {'id': '1', 'Title': 'A'},
          {'id': '2', 'Title': 'B'},
        ],
        'pagination': {'currentPage': 3, 'maxPage': 9},
      });

      expect(env.movies.map((m) => m.title), ['A', 'B']);
      expect(env.currentPage, 3);
      expect(env.totalPages, 9);
    });

    test('falls back to top-level paging keys', () {
      final env = MovieListEnvelope.fromJson(<String, dynamic>{
        'movies': <dynamic>[],
        'currentPage': 2,
        'totalPages': 5,
      });

      expect(env.currentPage, 2);
      expect(env.totalPages, 5);
    });

    test('defaults to a single empty page when paging is absent', () {
      final env = MovieListEnvelope.fromJson(<String, dynamic>{});

      expect(env.movies, isEmpty);
      expect(env.currentPage, 1);
      expect(env.totalPages, 1);
    });
  });

  group('ToggleFavoriteEnvelope.fromJson', () {
    // `MovieService.toggleFavorite` runs the response through `unwrapData`
    // first, so this is the shape the parser is actually handed in production.
    test('reads the movie and action from an already-unwrapped body', () {
      final env = ToggleFavoriteEnvelope.fromJson(<String, dynamic>{
        'movie': {'id': '1', 'Title': 'A'},
        'action': 'favorited',
      });

      expect(env.movie.id, '1');
      expect(env.movie.title, 'A');
      expect(env.action, 'favorited');
    });

    // Regression guard: the parser used to unwrap `data` a second time, which
    // left `action` empty for every real response and made
    // `MoviesRepositoryImpl.toggleFavorite` always return false.
    test('also accepts a body whose "data" envelope is still attached', () {
      final env = ToggleFavoriteEnvelope.fromJson(<String, dynamic>{
        'data': {
          'movie': {'id': '2', 'Title': 'B'},
          'action': 'unfavorited',
        },
      });

      expect(env.movie.id, '2');
      expect(env.action, 'unfavorited');
    });

    test('degrades to an empty movie and action when the payload is empty', () {
      final env = ToggleFavoriteEnvelope.fromJson(<String, dynamic>{});

      expect(env.movie.id, '');
      expect(env.action, '');
    });
  });
}
