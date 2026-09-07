# Hartflix — Flutter Case Study

A Flutter client for the **SINFLIX** case-study brief. It signs a user in against a
hosted REST API, keeps the session token in the platform keychain, and drives a
full-screen swipeable movie feed with server-backed favourites and a profile
screen with photo upload.

The backend is the public case API at `https://caseapi.servicelabs.tech`; there is
no backend in this repository.

> **UI language:** every user-facing string in the app is Turkish. The code,
> comments in this README, and the commit history are in English.

---

## About the name

The repository is called `hartflix-case-study`, but the Dart package is
`name: sinflix` and the code is full of `Sinflix*` identifiers. That is
deliberate, not an oversight:

* **SINFLIX** is the product name given in the case-study brief. It is used
  consistently for the Dart package, the theme (`SinflixTheme`), the shared
  widgets (`SinflixField`), the asset filenames, and the Android/iOS bundle
  identifier `app.sinflix.sinflix`.
* **hartflix-case-study** is only the name of the GitHub repository that hosts
  the submission.

Renaming the Dart package alone would have made things *less* consistent — the
package would no longer match the bundle identifier, the theme classes or the
assets. Renaming all of them would change the app's install identity
(`applicationId` / `PRODUCT_BUNDLE_IDENTIFIER`), which is out of scope for a
submitted case study. So the brief's name was kept everywhere inside the app.

---

## What it demonstrates

* Feature-first layering with an explicit `data` / `domain` / `presentation`
  split for the two features that talk to the network.
* Cubit-based state management with `Equatable` value states.
* Declarative, auth-aware routing: a `GoRouter` `redirect` driven by an auth
  stream, so the session state — not the widgets — decides what is reachable.
* Compile-time dependency injection (`injectable` + `get_it`) with a Dio module
  that attaches the bearer token in a request interceptor.
* Code-generated immutable DTOs (`freezed` + `json_serializable`) for the auth
  models, including a custom `JsonConverter` for a field the API returns as
  either a string or a number. The movie DTOs are hand-written — see
  [Known gaps](#known-gaps).
* An optimistic-update pattern in the Explore feed: the heart flips instantly,
  reconciles against the server list, and rolls back on failure.

---

## Quickstart

Requires the Flutter SDK. `pubspec.yaml` declares the floor the committed
`pubspec.lock` resolves to — **Dart >= 3.12, Flutter >= 3.44**. Verified on
**Flutter 3.47.0 / Dart 3.13.0** (stable), which is also the version CI runs.

```bash
git clone https://github.com/osmncnylmz/hartflix-case-study.git
cd hartflix-case-study

flutter pub get
flutter run
```

That is all you need to run the app — **`build_runner` is not part of the setup**,
because every generated file (`*.freezed.dart`, `*.g.dart`,
`lib/src/app/di/injection.config.dart`) is committed to the repository.

The app talks to the public case API out of the box; there is no `.env`, no API
key and no local backend to start. Create an account from the **Kayıt Ol**
(register) screen on first launch.

### Regenerating code

Only needed after you edit a `@freezed`, `@JsonSerializable` or `@injectable`
annotated file:

```bash
dart run build_runner build
```

Commit the regenerated files alongside your change. (`--delete-conflicting-outputs`
has been a no-op since build_runner 2.7, which made conflicting outputs always
get deleted; the flag is still accepted and ignored.)

### Regenerating the launcher icon and splash screen

These are one-off tooling steps, not part of the normal build:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## Running the checks

These are exactly the commands CI runs, in order:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

`flutter analyze` is clean — zero infos, zero warnings — and the suite is
**30 tests across 5 files**:

| File | Covers |
| --- | --- |
| `test/core/json_test.dart` | `unwrapData` envelope handling, `StringOrIntConverter` |
| `test/features/movies/movie_parsing_test.dart` | `MovieDto`, `MovieListEnvelope`, `ToggleFavoriteEnvelope` JSON mapping |
| `test/features/movies/movies_state_test.dart` | `MoviesState` defaults, `copyWith`, value equality |
| `test/features/auth/auth_state_test.dart` | `AuthState` status strings the router redirects on |
| `test/shared/sinflix_field_test.dart` | `SinflixField` / `SocialButton` widget behaviour |

The tests are deliberately hermetic: they cover parsing, state and widget logic
and never touch the network.

> The `analyzer: exclude:` block in `analysis_options.yaml` is not hand-written:
> `flutter pub get` on Flutter 3.47 runs the tool's `AnalysisOptionsMigration`
> and re-adds it. It excludes no Dart source in this repository — every `.dart`
> file lives under `lib/` or `test/` — so the clean analyze covers everything.

---

## Architecture

```
lib/
├── main.dart                        # bootstrap: overlay style, BlocObserver, DI, MaterialApp.router
└── src/
    ├── app/
    │   ├── bloc_observer/           # AppBlocObserver hook
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
    │   │   └── presentation/        # MoviesCubit + MoviesState
    │   ├── home/presentation/       # HomeShell (bottom nav), ExplorePage, limited-offer sheet
    │   ├── profile/presentation/    # ProfilePage, ProfileUploadPage
    │   └── splash/presentation/     # SplashPage
    └── shared/
        ├── styles/                  # SinflixTheme, PillsNav bottom navigation
        └── widgets/                 # SinflixField, SocialButton
```

**Not every feature has all three layers, and that is intentional.** `auth` and
`movies` own the network contracts, so they get `data` / `domain` /
`presentation`. `home`, `profile` and `splash` are pure presentation — they
compose widgets over the two repositories above rather than owning data of their
own.

### Dependency direction

The *behaviour* is inverted, the *data types* are not, and it is worth being
precise about which is which.

Cubits depend only on the abstract `AuthRepository` / `MoviesRepository` in
`domain`. The concrete `*RepositoryImpl` classes are bound to those interfaces
with `@LazySingleton(as: ...)` and resolved through `get_it`, so no presentation
code constructs or calls a `data/` implementation directly.

The DTOs are the exception: `MovieDto` is a data-layer type used as the shared
model across layers *and* across features. `MoviesCubit`, `ExplorePage` and
`ProfilePage` all import it, `AuthRepository.myFavorites()` returns
`List<MovieDto>`, and `AuthRepositoryImpl` takes the movies feature's
`MovieService` as a constructor argument to serve it. A stricter layering would
map the DTOs onto per-feature domain entities; for a case study of this size the
extra mapping layer was not worth the indirection, and this is a deliberate
trade-off rather than an accident.

### Auth and routing

1. `SecureTokenStore` persists the access token via `flutter_secure_storage`
   (Keychain on iOS, EncryptedSharedPreferences on Android). The Android backend
   is opted into explicitly with
   `aOptions: AndroidOptions(encryptedSharedPreferences: true)` — it is *not*
   the plugin default, which is the legacy KeyStore-wrapped `SharedPreferences`.
   It needs API 23+; the app's `minSdk` is Flutter's default of 24.
2. `NetworkModule.dio` registers a request interceptor that reads that token and
   sets `Authorization: Bearer <token>` on every outgoing request. Base URL is
   `https://caseapi.servicelabs.tech`, with a 10s connect and 20s receive timeout.
3. `AuthCubit` exposes a status string — `unknown`, `loading`, `authenticated`,
   `unauthenticated`, `failure`.
4. `GoRouterRefreshStream` adapts the cubit's `Stream` into the `Listenable` that
   `GoRouter.refreshListenable` expects, so the `redirect` re-runs whenever auth
   changes: `unknown` pins you to `/splash`, `authenticated` pushes you off
   `/splash` and the auth pages to `/home`, `unauthenticated` sends everything
   else to `/login`.

`SplashPage` also arms a 2-second fallback timer that navigates to `/login` if no
auth status has arrived, so a hung network call cannot strand the user on the
splash screen.

### API surface actually used

| Method | Endpoint | Used by |
| --- | --- | --- |
| `POST` | `/user/login` | `AuthService.login` |
| `POST` | `/user/register` | `AuthService.register` |
| `GET` | `/user/profile` | `AuthService.profile` |
| `POST` | `/user/upload_photo` | `AuthService.uploadPhoto` (multipart) |
| `GET` | `/movie/list?page=N` | `MovieService.listMovies` |
| `GET` | `/movie/favorites` | `MovieService.favoriteList` |
| `POST` | `/movie/favorite/{id}` | `MovieService.toggleFavorite` |

Successful responses are wrapped as `{"response": {...}, "data": {...}}`;
`unwrapData` in `core/network/json_utils.dart` unwraps that envelope and falls
back to the raw body when it is absent.

---

## Screens

**Splash** — full-bleed splash asset while `AuthCubit.check()` decides where to go.

**Login / Register** — dark card on black, `Form` validation (the email must
contain `@`, the password must be at least 6 characters), inline loading state on
the submit button, and errors surfaced through a `SnackBar`.

**Explore** — a full-screen horizontal `PageView` of posters. Pull-to-refresh uses
`CupertinoSliverRefreshControl`; the next page is prefetched once you are within
two cards of the end; the page-dot indicator counts within packs of five, which
matches the five items per page the repository yields. Tapping the heart applies
the change locally first (with haptic feedback), then calls the API and rolls the
local change back if the call throws. `_bestPoster` upgrades `http://` URLs to
`https://`, rejects anything that is still not `https`, and skips the legacy
`ia.media-imdb.com` host that answers 403, falling back to the `Images` array
when the primary poster is unusable.

**Profile** — avatar, name, e-mail and id, plus a two-column grid of favourited
movies loaded from `/movie/favorites`. Pull-to-refresh reloads both. Includes a
logout confirmation dialog and a static "Sınırlı Teklif" (limited offer) bottom
sheet showing token bundles.

**Profile upload** — picks an image from the gallery at 80% quality and posts it
as multipart to `/user/upload_photo`.

---

## Dependency choices

| Package | Why it is here |
| --- | --- |
| `flutter_bloc` / `bloc` / `equatable` | Cubits keep the async flows (paging, favourites, auth) out of the widgets. `Equatable` gives the states value equality so `BlocConsumer`'s `listenWhen`/`buildWhen` can filter on real changes rather than rebuilding on every emit. |
| `go_router` | The auth gate is a routing concern, and `redirect` + `refreshListenable` expresses "the session decides what is reachable" declaratively instead of scattering `Navigator` calls through pages. |
| `get_it` + `injectable` | `injectable` generates the wiring from annotations, so adding a service does not mean hand-editing a registration file. Everything is `@lazySingleton`, so the Dio client and token store are created once and shared. |
| `dio` | Needed for the request interceptor that injects the bearer token, and for `FormData`/`MultipartFile` on the photo upload — both awkward with `package:http`. |
| `freezed` + `json_annotation` / `json_serializable` | Immutable DTOs with generated `fromJson`, `copyWith` and equality — used for the auth models (`UserDto`, `AuthEnvelope`); the movie DTOs are hand-written. `StringOrIntConverter` handles the user id, which the API returns as a string on some endpoints and a number on others. |
| `flutter_secure_storage` | An access token belongs in the Keychain / EncryptedSharedPreferences, not in plain `SharedPreferences`. `SecureTokenStore` opts into `encryptedSharedPreferences` explicitly, since the plugin does not enable it by default. |
| `cached_network_image` | The feed is poster-heavy; disk caching plus per-image placeholder and error widgets keeps swiping smooth over a slow connection. |
| `google_fonts` | Ships the Inter text theme without bundling font binaries in the repo. |
| `image_picker` | Gallery access for the profile photo flow. |
| `flutter_lints` | The lint baseline. The analyzer currently reports zero issues. |
| `flutter_launcher_icons` / `flutter_native_splash` | Generate the platform icon and splash assets from the two files in `assets/`, so the platform folders stay generated rather than hand-maintained. |

---

## Known gaps

Being explicit about what this case study does *not* do:

* **The social login buttons and "Şifremi unuttum?" are UI only** — they have
  empty callbacks. No OAuth or password-reset flow is implemented.
* **The limited-offer sheet is a static mock.** Package prices and bonus figures
  are hardcoded; there is no purchase or IAP integration.
* **Logout is local.** It clears the stored token; it does not call a logout
  endpoint.
* **`MoviesCubit.loadRandom` / `loadFavorites` are unused.** They are implemented
  down to the service layer (`MovieService.randomMovies`) but no screen currently
  calls them; `ProfilePage` reads favourites through `AuthRepository.myFavorites`
  instead.
* **Cubits resolve their repository from the global `getIt` in a field
  initialiser** rather than taking it as a constructor argument. It works, but it
  makes the cubits harder to unit test with a fake repository, which is why the
  test suite covers parsing, state and widgets rather than cubit behaviour.
* **Only the auth DTOs are code-generated.** `UserDto` and `AuthEnvelope` are
  `freezed` + `json_serializable`; `MovieDto`, `MovieListEnvelope` and
  `ToggleFavoriteEnvelope` are hand-written with manual `fromJson` parsing, no
  `copyWith` and no value equality. That is why `MoviesState` equality is
  effectively instance-based for `items` — two states are equal only when they
  hold the same `MovieDto` instances.
* **No localisation.** UI strings are hardcoded Turkish; there is no
  `flutter_localizations` / ARB setup.
* **Android and iOS only.** No web, desktop or macOS targets are checked in.

---

## Continuous integration

[`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs on every push and
pull request to `main`, on `ubuntu-latest`, pinned to Flutter 3.47.0. It resolves
dependencies, then enforces formatting, analysis and tests. It does not run
`build_runner`, because the generated sources are committed.

---

## License

[MIT](LICENSE) © 2026 Osman Can YILMAZ
