import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/movie_dto.dart';
import '../../domain/movies_repository.dart';
import '../../../../app/di/injection.dart';

part 'movies_state.dart';

class MoviesCubit extends Cubit<MoviesState> {
  final MoviesRepository _repo = getIt<MoviesRepository>();
  MoviesCubit() : super(const MoviesState.initial());

  // Dahili liste ve sayfa bilgisi
  final List<MovieDto> _items = [];
  int _page = 1;
  int _maxPage = 1;

  /// İlk sayfayı yükle (Explore açılış + Pull-to-refresh sonrası)
  Future<void> loadFirstPage() async {
    emit(state.copyWith(loading: true, loadingMore: false));

    try {
      _page = 1;
      _items.clear();

      final p = await _repo.page(page: _page);
      _maxPage = p.totalPages;
      _items.addAll(p.items);

      emit(
        state.copyWith(
          loading: false,
          items: List<MovieDto>.unmodifiable(_items),
          page: _page,
          hasMore: _page < _maxPage,
        ),
      );

      // Sonraki çağrılar için sayaç
      _page = (_page < _maxPage) ? _page + 1 : _page;
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
  }

  /// Sonsuz kaydırma: sonraki sayfayı ekle
  Future<void> loadNextPage() async {
    if (state.loadingMore || !state.hasMore) return;

    emit(state.copyWith(loadingMore: true));

    try {
      final p = await _repo.page(page: _page);
      _maxPage = p.totalPages;

      _items.addAll(p.items);

      if (_page < _maxPage) {
        _page += 1;
      }

      emit(
        state.copyWith(
          loadingMore: false,
          items: List<MovieDto>.unmodifiable(_items),
          page: (_page > _maxPage) ? _maxPage : _page,
          hasMore: (_page <= _maxPage),
        ),
      );
    } catch (_) {
      emit(state.copyWith(loadingMore: false));
    }
  }

  /// Pull-to-refresh
  Future<void> refresh() async {
    await loadFirstPage();
    await hydrateFavorites();
  }

  /// Rastgele filmler (başka ekranlar için)
  Future<void> loadRandom({int count = 6}) async {
    if (state.loading) return;
    emit(state.copyWith(loading: true, loadingMore: false));

    try {
      final rndList = await _repo.randomMovies(count: count);
      _items
        ..clear()
        ..addAll(rndList);

      _page = 1;
      _maxPage = 1;

      emit(
        state.copyWith(
          loading: false,
          items: List<MovieDto>.unmodifiable(_items),
          page: 1,
          hasMore: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
  }

  /// Favori toggle
  ///
  /// [MoviesRepository.toggleFavorite] returns the *new* state (`true` when the
  /// movie is now a favourite), so it is applied directly instead of being
  /// treated as a success flag — reading it as "did it work?" meant an
  /// un-favourite left the id in [MoviesState.favIds].
  /// Errors are left to propagate: the Explore page rolls its optimistic
  /// change back when this throws.
  Future<void> toggleFavorite(String movieId) async {
    final isFavoriteNow = await _repo.toggleFavorite(movieId);

    final favs = Set<String>.from(state.favIds);
    if (isFavoriteNow) {
      favs.add(movieId);
    } else {
      favs.remove(movieId);
    }
    emit(state.copyWith(favIds: favs));
  }

  /// Favorileri doldur
  Future<void> hydrateFavorites() async {
    try {
      final favs = await _repo.favorites();
      emit(state.copyWith(favIds: favs.map((e) => e.id).toSet()));
    } catch (_) {
      // sessiz geç
    }
  }

  /// Favoriler sayfası (tam liste)
  Future<void> loadFavorites() async {
    emit(state.copyWith(loading: true, loadingMore: false));
    try {
      final favs = await _repo.favorites();
      _items
        ..clear()
        ..addAll(favs);

      _page = 1;
      _maxPage = 1;

      emit(
        state.copyWith(
          loading: false,
          items: List<MovieDto>.unmodifiable(_items),
          favIds: favs.map((e) => e.id).toSet(),
          page: 1,
          hasMore: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
  }
}
