part of 'movies_cubit.dart';

class MoviesState extends Equatable {
  final List<MovieDto> items;

  final Set<String> favIds;

  final bool loading;

  final int page;

  final bool hasMore;

  final bool loadingMore;

  const MoviesState({
    required this.items,
    required this.favIds,
    required this.loading,
    required this.page,
    required this.hasMore,
    required this.loadingMore,
  });

  const MoviesState.initial()
    : items = const [],
      favIds = const {},
      loading = false,
      page = 1,
      hasMore = true,
      loadingMore = false;

  MoviesState copyWith({
    List<MovieDto>? items,
    Set<String>? favIds,
    bool? loading,
    int? page,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return MoviesState(
      items: items ?? this.items,
      favIds: favIds ?? this.favIds,
      loading: loading ?? this.loading,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  @override
  List<Object?> get props => [
    items,
    favIds,
    loading,
    page,
    hasMore,
    loadingMore,
  ];
}
