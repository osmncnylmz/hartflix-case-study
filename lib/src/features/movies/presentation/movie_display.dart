import '../data/models/movie_dto.dart';

/// API bazı poster/avatar URL'lerini hâlâ http:// veriyor, iOS ATS de onları
/// kesiyor.
String httpsUrl(String url) =>
    url.startsWith('http://') ? url.replaceFirst('http://', 'https://') : url;

extension MovieDisplay on MovieDto {
  /// Başlığı boş gelen kayıtlar var; grid'de hücre boş kalmasın.
  String get displayTitle {
    final t = title.trim();
    return t.isEmpty ? '—' : t;
  }

  /// Poster + Images içinden gerçekten yüklenebilecek ilk URL.
  /// `ia.media-imdb.com` eski host'u 403 dönüyor, https olmayanı da ATS
  /// engelliyor; ikisi de elenirse Images'a düşüyoruz, o da yoksa null.
  String? get bestPosterUrl {
    final candidates = <String>[
      if (poster.trim().isNotEmpty) poster.trim(),
      ...images.where((e) => e.isNotEmpty),
    ];

    for (final raw in candidates) {
      final fixed = httpsUrl(raw);
      final uri = Uri.tryParse(fixed);
      if (uri == null || uri.scheme != 'https') continue;
      if (uri.host.toLowerCase().contains('ia.media-imdb.com')) continue;
      return fixed;
    }
    return null;
  }
}
