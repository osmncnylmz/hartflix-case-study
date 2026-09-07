import 'package:flutter_test/flutter_test.dart';
import 'package:sinflix/src/features/movies/data/models/movie_dto.dart';
import 'package:sinflix/src/features/movies/presentation/cubit/movies_cubit.dart';

MovieDto _movie(String id) =>
    MovieDto.fromJson(<String, dynamic>{'id': id, 'Title': 'Movie $id'});

void main() {
  group('MoviesState', () {
    test('starts empty, idle and open to a first page', () {
      const state = MoviesState.initial();

      expect(state.items, isEmpty);
      expect(state.favIds, isEmpty);
      expect(state.loading, isFalse);
      expect(state.loadingMore, isFalse);
      expect(state.page, 1);
      expect(state.hasMore, isTrue);
    });

    test('copyWith replaces only the fields it is given', () {
      const initial = MoviesState.initial();

      final next = initial.copyWith(loading: true, page: 4);

      expect(next.loading, isTrue);
      expect(next.page, 4);
      expect(next.hasMore, initial.hasMore);
      expect(next.items, same(initial.items));
      expect(next.favIds, same(initial.favIds));
    });

    test('is compared by value, not identity', () {
      final a = const MoviesState.initial().copyWith(
        items: [_movie('1')],
        favIds: {'1'},
      );
      final b = const MoviesState.initial().copyWith(
        items: [_movie('1')],
        favIds: {'1'},
      );

      // MovieDto has no value equality, so identical DTO instances are what
      // makes two states equal.
      expect(a == b, isFalse);

      final shared = _movie('1');
      final c = const MoviesState.initial().copyWith(items: [shared]);
      final d = const MoviesState.initial().copyWith(items: [shared]);
      expect(c, equals(d));
    });

    test('a differing flag makes two states unequal', () {
      const a = MoviesState.initial();
      final b = a.copyWith(loadingMore: true);

      expect(a, isNot(equals(b)));
    });
  });
}
