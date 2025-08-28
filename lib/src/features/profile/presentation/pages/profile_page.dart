import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sinflix/src/features/home/presentation/widgets/limited_offer_sheet.dart';
import 'package:sinflix/src/features/movies/data/models/movie_dto.dart';
import '../../../../shared/styles/sinflix_theme.dart';
import '../../../auth/domain/auth_repository.dart';
import '../../../../app/di/injection.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../presentation/pages/profile_upload_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _repo = getIt<AuthRepository>();

  List<MovieDto> favs = [];
  String? name, email, photo, userId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final me = await _repo.me(); // GET /user/profile
      final list = await _repo.myFavorites(); // GET /movie/favorites
      setState(() {
        userId = me.id;
        name = me.name;
        email = me.email;
        photo = me.photoUrl;
        favs = (list as List)
            .map((e) => e is MovieDto ? e : MovieDto.fromJson(e))
            .toList();
      });
    } catch (e) {
      setState(() => _error = 'Profil veya favoriler alınamadı: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmLogout() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Çıkış yapılsın mı?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          style: TextStyle(color: Colors.white70),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç', style: TextStyle(fontSize: 15)),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.logout, size: 18, color: Colors.white),
            label: const Text(
              'Çıkış',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (res == true && mounted) {
      context.read<AuthCubit>().logout();
    }
  }

  void _openLimitedOffer() {
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
          initialChildSize: 0.65,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, scroll) => SingleChildScrollView(
            controller: scroll,
            child: const LimitedOfferSheet(),
          ),
        );
      },
    );
  }

  Future<void> _openUploader() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfileUploadPage()));
    if (mounted) _load(); // foto yükleme dönüşü tazele
  }

  void _openMovieDetail(MovieDto m) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: Colors.black,
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Üst bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
                  child: Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _confirmLogout,
                        child: Ink(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2A2A2A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Profil Detayı',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _openLimitedOffer,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: SinflixTheme.red,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.local_offer,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Sınırlı Teklif',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Kullanıcı bilgileri
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: const Color(0xFF2A2A2A),
                        foregroundImage: (photo != null && photo!.isNotEmpty)
                            ? NetworkImage(_fixUrl(photo!))
                            : null,
                        child: (photo == null || photo!.isEmpty)
                            ? const Icon(
                                Icons.person,
                                size: 34,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name?.trim().isNotEmpty == true
                                  ? name!.trim()
                                  : '-',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (email ?? '').trim(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "ID: ${userId ?? '-'}",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: SinflixTheme.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _openUploader,
                        child: const Text('Fotoğraf Ekle'),
                      ),
                    ],
                  ),
                ),
              ),

              // Hata/boş/loader durumları
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white70,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _load,
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
                    child: Row(
                      children: [
                        Text(
                          "Beğendiğim Filmler",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${favs.length})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Boş durum
                if (favs.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'Henüz favori eklenmemiş.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((ctx, i) {
                        final m = favs[i];
                        final poster = _bestPoster(m);
                        final title = _safeTitle(m);
                        final year = (m.year ?? '').trim();

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () =>
                                _openMovieDetail(m), // <-- tüm kart tıklanır
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Poster
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: poster != null
                                        ? CachedNetworkImage(
                                            imageUrl: poster,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            placeholder: (_, __) => Container(
                                              color: Colors.black26,
                                            ),
                                            errorWidget: (_, __, ___) =>
                                                Container(
                                                  color: Colors.black26,
                                                  alignment: Alignment.center,
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.white54,
                                                  ),
                                                ),
                                          )
                                        : Container(
                                            color: Colors.black26,
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: Colors.white54,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Metinler
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (year.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          year,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: favs.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: .72,
                          ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Yardımcılar

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
