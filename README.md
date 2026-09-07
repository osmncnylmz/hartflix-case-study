# Hartflix — Flutter Case Study

A Flutter client for the SINFLIX case-study brief. It signs a user in against a
hosted REST API, keeps the session token in the platform keychain, and drives a
full-screen swipeable movie feed with server-backed favourites plus a profile
screen with photo upload. (The brief's product name is SINFLIX, which is why the
Dart package is `sinflix` and the classes are `Sinflix*`; see
[About the name](#about-the-name).)

The backend is the public case API at `https://caseapi.servicelabs.tech`. No
server-side code lives here.

Every user-facing string in the app is Turkish, as the brief asks. So are the
code comments. This README and the commit messages are in English.

## Running it

Requires the Flutter SDK. `pubspec.yaml` declares the floor the committed
`pubspec.lock` resolves to, Dart >= 3.12 and Flutter >= 3.44. Everything here
was built and checked on Flutter 3.47.0 / Dart 3.13.0 stable, which is what CI
pins too.

```bash
git clone https://github.com/osmncnylmz/hartflix-case-study.git
cd hartflix-case-study

flutter pub get
flutter run
```

That is the whole setup. `build_runner` is not part of it, because every
generated file (`*.freezed.dart`, `*.g.dart`,
`lib/src/app/di/injection.config.dart`) is committed. There is no `.env`, no API
key and no local backend to start. Create an account from the **Kayıt Ol**
screen on first launch.

You only need to regenerate after editing something annotated `@freezed`,
`@JsonSerializable` or `@injectable`:

```bash
dart run build_runner build
```

Commit the regenerated files with your change. `--delete-conflicting-outputs`
has been a no-op since build_runner 2.7, which made conflicting outputs always
get deleted; the flag is still accepted and ignored.

The launcher icon and the splash screen are one-off tooling steps rather than
part of the build:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Checks

These are the four commands CI runs, in order:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

`flutter analyze` reports nothing at all: no infos, no warnings. `flutter test`
is 30 tests across five files.

* `test/core/json_test.dart` covers `unwrapData`'s envelope handling and
  `StringOrIntConverter`.
* `test/features/movies/movie_parsing_test.dart` covers the JSON mapping for
  `MovieDto`, `MovieListEnvelope` and `ToggleFavoriteEnvelope`, including a
  regression guard for the double-unwrap described under
  [The API](#the-api).
* `test/features/movies/movies_state_test.dart` covers `MoviesState` defaults,
  `copyWith` and value equality.
* `test/features/auth/auth_state_test.dart` pins the status strings the router
  redirects on.
* `test/shared/sinflix_field_test.dart` drives `SinflixField` and
  `SocialButton` as widgets.

The suite is deliberately hermetic. Nothing in it touches the network.

The `analyzer: exclude:` block in `analysis_options.yaml` covers no Dart source
here; every `.dart` file is under `lib/` or `test/`. It stays committed because
`flutter pub get` on 3.47 re-adds it anyway.

## Architecture

```
lib/
├── main.dart                        # bootstrap: overlay style, DI, MaterialApp.router
└── src/
    ├── app/
    │   ├── di/                      # get_it instance + generated injection.config.dart
    │   └── router/                  # GoRouter config + ChangeNotifier bridge for a Stream
    ├── core/
    │   ├── json/                    # StringOrIntConverter
    │   ├── network/                 # Dio module (base URL, timeouts, auth interceptor), unwrapData
    │   └── storage/                 # SecureTokenStore (flutter_secure_storage)
    ├── features/
    │   ├── auth/
    │   │   ├── data/                # AuthService (Dio), AuthRepositoryImpl, freezed DTOs
    │   │   ├── domain/              # AuthRepository interface
    │   │   └── presentation/        # AuthCubit + AuthState, login & register pages
    │   ├── movies/
    │   │   ├── data/                # MovieService, MovieDto, envelopes, MoviesRepositoryImpl
    │   │   ├── domain/              # MoviesRepository interface, MoviesPage
    │   │   └── presentation/        # MoviesCubit + MoviesState, poster/title helpers
    │   ├── home/presentation/       # HomeShell (bottom nav), ExplorePage, limited-offer sheet
    │   ├── profile/presentation/    # ProfilePage, ProfileUploadPage
    │   └── splash/presentation/     # SplashPage
    └── shared/
        ├── styles/                  # SinflixTheme, PillsNav bottom navigation
        └── widgets/                 # SinflixField, SocialButton
```

Not every feature has all three layers. `auth` and `movies` own the network
contracts, so they get `data` / `domain` / `presentation`. `home`, `profile` and
`splash` are pure presentation: they compose widgets over the two repositories
above rather than owning data of their own.

### Which direction the dependencies point

The behaviour is inverted; the data types are not.

Cubits depend only on the abstract `AuthRepository` and `MoviesRepository` in
`domain`. The concrete `*RepositoryImpl` classes are bound to those interfaces
with `@LazySingleton(as: ...)` and resolved through `get_it`, so no presentation
code constructs or calls a `data/` implementation directly.

The DTOs are the exception. `MovieDto` is a data-layer type used as the shared
model across layers and across features: `MoviesCubit`, `ExplorePage` and
`ProfilePage` all import it, `AuthRepository.myFavorites()` returns
`List<MovieDto>`, and `AuthRepositoryImpl` takes the movies feature's
`MovieService` as a constructor argument to serve it. Stricter layering would
map the DTOs onto per-feature domain entities. For a case study this size the
extra mapping was not worth the indirection.

### Auth and routing

1. `SecureTokenStore` persists the access token via `flutter_secure_storage`
   (Keychain on iOS, EncryptedSharedPreferences on Android). The Android backend
   is opted into explicitly with
   `aOptions: AndroidOptions(encryptedSharedPreferences: true)`, which is *not*
   the plugin default; the default is the legacy KeyStore-wrapped
   `SharedPreferences`. It needs API 23+, and the app's `minSdk` is Flutter's
   default of 24.
2. `NetworkModule.dio` registers a request interceptor that reads that token and
   sets `Authorization: Bearer <token>` on every outgoing request. Base URL is
   `https://caseapi.servicelabs.tech`, with a 10s connect and 20s receive
   timeout.
3. `AuthCubit` exposes a status string: `unknown`, `loading`, `authenticated`,
   `unauthenticated`, `failure`.
4. `GoRouterRefreshStream` adapts the cubit's `Stream` into the `Listenable`
   that `GoRouter.refreshListenable` expects, so the `redirect` re-runs whenever
   auth changes. `unknown` pins you to `/splash`, `authenticated` pushes you off
   `/splash` and the auth pages to `/home`, and `unauthenticated` sends
   everything else to `/login`.

`SplashPage` also arms a 2-second fallback timer that navigates to `/login` if
no auth status has arrived, so a hung network call cannot strand the user on the
splash screen.

### The API

| Method | Endpoint | Used by |
| --- | --- | --- |
| `POST` | `/user/login` | `AuthService.login` |
| `POST` | `/user/register` | `AuthService.register` |
| `GET` | `/user/profile` | `AuthService.profile` |
| `POST` | `/user/upload_photo` | `AuthService.uploadPhoto` (multipart) |
| `GET` | `/movie/list?page=N` | `MovieService.listMovies` |
| `GET` | `/movie/favorites` | `MovieService.favoriteList` |
| `POST` | `/movie/favorite/{id}` | `MovieService.toggleFavorite` |

Successful responses are wrapped as `{"response": {...}, "data": {...}}`.
`unwrapData` in `core/network/json_utils.dart` strips that envelope and falls
back to the raw body when it is absent.

`ToggleFavoriteEnvelope.fromJson` used to strip it a second time. Since the body
it receives has already been unwrapped, the second `json['data']` lookup missed,
`action` came back as `''` for every real response, and
`MoviesRepositoryImpl.toggleFavorite` therefore returned `false` forever, which
in turn left un-favourited ids sitting in `MoviesState.favIds`. The parser now
accepts either shape, and the test file pins both.

## Screens

**Splash.** Full-bleed splash asset while `AuthCubit.check()` decides where to
go.

Login and register share a layout: dark card on black, `Form` validation (the
email must contain `@`, the password must be at least 6 characters), an inline
loading state on the submit button, errors surfaced through a `SnackBar`.

**Explore** is where most of the behaviour is. A full-screen horizontal
`PageView` of posters; pull-to-refresh is a `CupertinoSliverRefreshControl`; the
next page is fetched once you are within two cards of the end. The page-dot
indicator counts within packs of five, matching the five items per page
`MoviesRepositoryImpl` yields. Tapping the heart applies the change locally
first, with a haptic tick, then calls the API and rolls the local change back if
the call throws. `MovieDto.bestPosterUrl` upgrades `http://` URLs to `https://`,
rejects anything that is still not `https`, and skips the legacy
`ia.media-imdb.com` host that answers 403, falling back to the `Images` array
when the primary poster is unusable.

**Profile.** Avatar, name, e-mail and id above a two-column grid of favourites
loaded from `/movie/favorites`; pull-to-refresh reloads both. Logout goes
through a confirmation dialog. The "Sınırlı Teklif" bottom sheet and its token
bundles are static.

Profile upload picks an image from the gallery at 80% quality and posts it as
multipart to `/user/upload_photo`.

## Why these packages

State lives in cubits (`flutter_bloc`, `bloc`), which keeps paging, favourites
and auth out of the widgets. `equatable` gives those states value equality, so
`listenWhen` and `buildWhen` filter on real changes instead of firing on every
emit. The auth gate is a routing concern, so `go_router`'s `redirect` plus
`refreshListenable` expresses "the session decides what is reachable" in one
place rather than scattering `Navigator` calls through the pages.

`dio` rather than `package:http` for two reasons. The bearer token has to go on
every outgoing request, and an interceptor is the one place to put that without
threading a header map through every service method. The photo upload is
multipart, which `FormData` and `MultipartFile` do directly.

An access token sitting in plain `SharedPreferences` is readable by anything
that reaches the app's data directory, so it goes through
`flutter_secure_storage` instead.

`get_it` with `injectable` generates the wiring from annotations, so adding a
service does not mean hand-editing a registration file. Everything is
`@lazySingleton`, which is what makes the Dio client and the token store shared
rather than per-call.

`freezed` and `json_serializable` produce the immutable auth DTOs with their
generated `fromJson`, `copyWith` and equality. `StringOrIntConverter` sits in
that pipeline to absorb the user id, which the API returns as a string on some
endpoints and a number on others.

`cached_network_image` earns its place on Explore, where disk caching and a
per-image placeholder are what keep swiping usable over a slow connection. The
rest is unremarkable: `google_fonts` for Inter without committing font binaries,
`image_picker` for the gallery, `flutter_lints` as the lint baseline, and
`flutter_launcher_icons` plus `flutter_native_splash` to generate the platform
icon and splash assets from the two files in `assets/`.

## About the name

The repository is `hartflix-case-study`, the Dart package is `sinflix`, and the
code is full of `Sinflix*` identifiers. SINFLIX is the product name given in the
brief, and it is what the theme (`SinflixTheme`), the shared widgets
(`SinflixField`), the asset filenames and the bundle identifier
`app.sinflix.sinflix` all use. `hartflix-case-study` is only the name of the
GitHub repository hosting the submission.

Renaming the Dart package on its own would have made things *less* consistent:
it would stop matching the bundle identifier, the theme classes and the assets.
Renaming all of them would change the app's install identity (`applicationId`,
`PRODUCT_BUNDLE_IDENTIFIER`), which is not something to do to a submitted case
study. So the brief's name stayed everywhere inside the app.

## Known gaps

* The social login buttons and "Şifremi unuttum?" are UI only, with empty
  callbacks. No OAuth, no password reset.
* The limited-offer sheet is a mock. Package prices and bonus figures are
  hardcoded, and there is no purchase or IAP integration.
* Logout is local: it clears the stored token and does not call a logout
  endpoint.
* `MoviesCubit.loadRandom` and `loadFavorites` are unused. They are implemented
  all the way down to `MovieService.randomMovies`, but no screen calls them;
  `ProfilePage` reads favourites through `AuthRepository.myFavorites` instead.
* Cubits resolve their repository from the global `getIt` in a field
  initialiser rather than taking it as a constructor argument. It works, but it
  makes them awkward to unit test against a fake repository, which is why the
  suite covers parsing, state and widgets rather than cubit behaviour.
* Only the auth DTOs are code-generated. `MovieDto`, `MovieListEnvelope` and
  `ToggleFavoriteEnvelope` are hand-written, with manual `fromJson`, no
  `copyWith` and no value equality. That is also why `MoviesState` equality is
  effectively instance-based for `items`: two states are equal only when they
  hold the same `MovieDto` instances.
* No localisation. UI strings are hardcoded Turkish; there is no
  `flutter_localizations` or ARB setup.
* Android and iOS only. No web, desktop or macOS target is checked in.

## Continuous integration

[`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs on every push and
pull request to `main`, on `ubuntu-latest`, pinned to Flutter 3.47.0. It
resolves dependencies, then checks formatting, analysis and tests. There is no
`build_runner` step, because the generated sources are committed.

## License

[MIT](LICENSE) © 2026 Osman Can YILMAZ
