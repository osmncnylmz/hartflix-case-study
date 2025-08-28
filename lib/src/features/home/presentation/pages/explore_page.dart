import 'dart:math' as math;
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../movies/presentation/cubit/movies_cubit.dart';
import '../../../movies/data/models/movie_dto.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with AutomaticKeepAliveClientMixin {
  final PageController _controller = PageController(viewportFraction: 1.0);
  int _index = 0;

  static const int _pageSize = 5; // 5-5-5 görünüm

  final Set<String> _optimisticAdd = {};
  final Set<String> _optimisticRemove = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<MoviesCubit>();
      cubit.loadFirstPage();
      cubit.hydrateFavorites();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<MoviesCubit>().refresh();
    if (!mounted) return;
    setState(() => _index = 0);
    _controller.jumpToPage(0); // yenilemeden sonra kaydırmayı sıfırla
  }

  void _maybeLoadNext(int i, int len, MoviesState state) {
    if (!state.loadingMore && state.hasMore && i >= len - 2) {
      context.read<MoviesCubit>().loadNextPage();
    }
  }

  void _handlePageChanged(int i, int total, MoviesState state) {
    setState(() => _index = i);
    _maybeLoadNext(i, total, state);

    if (!state.hasMore && total > 0 && i == total - 1) {
      Future.microtask(() {
        if (!mounted) return;
        _controller.animateToPage(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  /// Etkin (UI'da görünen) favori durumu:
  /// server ∪ optimisticAdd \ optimisticRemove
  bool _effectiveFav(String id, MoviesState state) {
    final server = state.favIds.contains(id);
    if (_optimisticRemove.contains(id)) return false;
    if (_optimisticAdd.contains(id)) return true;
    return server;
  }

  /// Favori toggle: anında UI + sağlam geri alma
  Future<void> _toggleFav(String id) async {
    final cubit = context.read<MoviesCubit>();
    final serverIsFav = cubit.state.favIds.contains(id);

    // Hedefi belirle ve anında UI'a yansıt
    setState(() {
      if (serverIsFav) {
        // çıkar
        _optimisticRemove.add(id);
        _optimisticAdd.remove(id);
      } else {
        // ekle
        _optimisticAdd.add(id);
        _optimisticRemove.remove(id);
      }
    });

    HapticFeedback.lightImpact();

    try {
      await cubit.toggleFavorite(id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (serverIsFav) {
          _optimisticRemove.remove(id);
        } else {
          _optimisticAdd.remove(id);
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Favori güncellenemedi')));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocConsumer<MoviesCubit, MoviesState>(
      listenWhen: (prev, curr) => prev.favIds != curr.favIds,
      listener: (context, state) {
        final toRemoveFromAdd = <String>{};
        for (final id in _optimisticAdd) {
          if (state.favIds.contains(id)) toRemoveFromAdd.add(id);
        }
        final toRemoveFromRemove = <String>{};
        for (final id in _optimisticRemove) {
          if (!state.favIds.contains(id)) toRemoveFromRemove.add(id);
        }
        if (toRemoveFromAdd.isNotEmpty || toRemoveFromRemove.isNotEmpty) {
          setState(() {
            _optimisticAdd.removeAll(toRemoveFromAdd);
            _optimisticRemove.removeAll(toRemoveFromRemove);
          });
        }
      },
      builder: (context, state) {
        final items = state.items;
        final loading = state.loading && items.isEmpty;

        final currentPackStart = (_index ~/ _pageSize) * _pageSize;
        final currentPackCount = math.min(
          _pageSize,
          math.max(0, items.length - currentPackStart),
        );
        final indexInPack = math.min(
          math.max(0, _index - currentPackStart),
          math.max(0, currentPackCount - 1),
        );

        if (loading) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                CupertinoSliverRefreshControl(onRefresh: _refresh),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        (kBottomNavigationBarHeight + 8),
                    child: Stack(
                      children: [
                        if (items.isEmpty)
                          const Center(
                            child: Text(
                              'Gösterilecek film bulunamadı',
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        else
                          PageView.builder(
                            controller: _controller,
                            itemCount: items.length,
                            onPageChanged: (i) =>
                                _handlePageChanged(i, items.length, state),
                            itemBuilder: (ctx, i) {
                              final m = items[i];
                              final isFav = _effectiveFav(m.id, state);

                              return _HeroCard(
                                movie: m,
                                isFavorite: isFav,
                                onMore: () => _showDetails(context, m),
                                onToggleFavorite: () => _toggleFav(m.id),
                              );
                            },
                          ),

                        if (state.loadingMore)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 24,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.4),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Yükleniyor...',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _Dots(count: currentPackCount, index: indexInPack),
          ),
        );
      },
    );
  }

  void _showDetails(BuildContext context, MovieDto m) {
    final title = _safeTitle(m);
    final desc = _safeDesc(m);
    final imgs = _safeImages(m);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scroll) {
            return SingleChildScrollView(
              controller: scroll,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (imgs.isNotEmpty)
                      SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: imgs.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: _fixUrl(imgs[i]),
                              fit: BoxFit.cover,
                              width: 240,
                              height: 160,
                              placeholder: (_, __) =>
                                  Container(color: Colors.black26),
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(desc, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Yardımcılar (null-safe & güvenli URL)

String _safeTitle(MovieDto m) {
  try {
    final t = (m.title ?? '').trim();
    return t.isEmpty ? '—' : t;
  } catch (_) {
    return '—';
  }
}

String _safeDesc(MovieDto m) {
  try {
    final d = (m.description ?? '').trim();
    return d;
  } catch (_) {
    return '';
  }
}

List<String> _safeImages(MovieDto m) {
  try {
    final list = (m.images ?? const <String>[]);
    return list.where((e) => e.isNotEmpty).toList();
  } catch (_) {
    return const <String>[];
  }
}

/// http -> https
String _fixUrl(String url) {
  if (url.startsWith('http://')) return url.replaceFirst('http://', 'https://');
  return url;
}

/// IMDB eski hostları 403 verebiliyor; https zorunlu; poster→images fallback
String? _bestPoster(MovieDto m) {
  final List<String> imgs = _safeImages(m);
  final String poster = (m.posterUrl ?? '').trim();

  final candidates = <String>[if (poster.isNotEmpty) poster, ...imgs];

  for (final raw in candidates) {
    final fixed = _fixUrl(raw);
    final uri = Uri.tryParse(fixed);
    if (uri == null) continue;
    if (uri.scheme != 'https') continue;

    final host = uri.host.toLowerCase();
    if (host.contains('ia.media-imdb.com')) continue; // 403’leri atla

    return fixed;
  }
  return null;
}

class _HeroCard extends StatefulWidget {
  final MovieDto movie;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onMore;

  const _HeroCard({
    required this.movie,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onMore,
  });

  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard> {
  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w800,
      color: Colors.white,
    );
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(.9));

    final posterOrFallback = _bestPoster(widget.movie);
    final title = _safeTitle(widget.movie);
    final desc = _safeDesc(widget.movie);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (posterOrFallback != null)
          CachedNetworkImage(
            imageUrl: posterOrFallback,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.black12),
            errorWidget: (_, __, ___) =>
                const Icon(Icons.broken_image, color: Colors.white54, size: 40),
          )
        else
          Container(
            color: Colors.black26,
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
            ),
          ),

        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54, Colors.black87],
              ),
            ),
          ),
        ),

        Positioned(
          right: 16,
          bottom: 120,
          child: SizedBox(
            width: 84,
            height: 84,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: widget.onToggleFavorite,
              child: Align(
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          key: ValueKey<bool>(widget.isFavorite),
                          widget.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.isFavorite ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          left: 16,
          right: 16,
          bottom: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'N',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: bodyStyle,
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: widget.onMore,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  'Daha Fazlası',
                  style: bodyStyle?.copyWith(
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  final int count; // 1..5
  final int index; // 0..count-1
  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
