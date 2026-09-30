# Development Notes

## Current status

This repository syncs DDE packages from nixpkgs at the last revision that still
contained them (`96e751adaf2f` for packages, `15a586f29d59` for NixOS modules),
then progressively upgrades them to Qt6 and maintains only the upgraded set.

Only the packages listed as **maintained** below are built and exposed via
`flake.nix`; everything else in `packages/default.nix` is commented out and will
be re-enabled one by one as it is upgraded.

## Maintained packages

| Package          | Version | Qt   | Notes                                  |
|------------------|---------|------|----------------------------------------|
| dtkcommon        | 6.7.50  | n/a  | provides `DtkBuildHelper.cmake`         |
| dtklog           | 6.7.50  | Qt6  | was `dtk6log`, now `dtklog`            |
| dtkcore          | 6.7.50  | Qt6  | was `dtkcore` (Qt5) + `dtk6core`       |
| dtkgui           | 6.7.50  | Qt6  | was `dtkgui` (Qt5) + `dtk6gui`         |
| dtkwidget        | 6.7.50  | Qt6  | was `dtkwidget` (Qt5) + `dtk6widget`   |
| dtkdeclarative   | 6.7.50  | Qt6  | was `dtkdeclarative` (Qt5) + `dtk6declarative` |
| dtksystemsettings| 6.6.22  | Qt6  | was `dtk6systemsettings`               |
| qt6platform-plugins | 6.0.50 | Qt6 |                                      |
| qt6integration | 6.0.50 | Qt6 | depends on dtkwidget                 |
| treeland-protocols | 0.6.0 | n/a |                                      |
| deepin-pdfium | 1.5.8 | Qt6 | PDFium rendering lib (was Qt5 qmake) |
| docparser | 1.0.26 | n/a | doc content analysis lib (was Qt5) |
| gio-qt | 0.0.16 | Qt6 | was Qt5 (now qt6-only via patch) |
| udisks2-qt6 | 6.0.1 | Qt6 | replaces udisks2-qt5 (deleted) |
| qt6mpris | 1.0.0.1-1deepin2 | Qt6 | was already Qt6; version bump |
| deepin-terminal | 6.5.40 | Qt6 | first app upgraded to Qt6           |

## Upgrade log

- **dtkcommon** `5.7.13` -> `6.7.50`. Installs both `DtkConfig.cmake` and
  `Dtk6Config.cmake` plus `DtkBuildHelper`.
- **dtklog** Qt5 `dtklog` removed; `dtk6log` renamed to `dtklog` and upgraded
  `0.0.2` -> `6.7.50`. Built with `-DDTK5=OFF` to produce
  `libdtk6log.so` + `Dtk6LogConfig.cmake`.
- **dtkcore** Qt5 `dtkcore` (5.6.32) removed; `dtk6core` deleted and `dtkcore`
  upgraded `5.6.32` -> `6.7.50`. Built with `-DDTK5=OFF` to produce
  `libdtk6core.so` + `Dtk6CoreConfig.cmake` / `Dtk6ToolsConfig.cmake`.
- **dtkgui** Qt5 `dtkgui` removed; `dtk6gui` renamed `dtkgui` and upgraded
  `6.0.33` -> `6.7.50`. `-DDTK5=OFF`.
- **dtkwidget** Qt5 `dtkwidget` removed; `dtk6widget` renamed `dtkwidget` and
  upgraded `6.0.33` -> `6.7.50`. `-DDTK5=OFF`.
- **dtkdeclarative** Qt5 `dtkdeclarative` removed; `dtk6declarative` renamed
  `dtkdeclarative` and upgraded `6.0.33` -> `6.7.50`. `-DDTK5=OFF`.
- **dtksystemsettings** `dtk6systemsettings` renamed `dtksystemsettings` and
  upgraded `6.0.2` -> `6.6.22` (repo `dtksystemsettings`). `-DDTK5=OFF`.
- **qt6platform-plugins** `6.0.33` -> `6.0.50`. Built against the qtbase
  private xcb headers (unpacked from `qt6Packages.qtbase.src`).
- **qt6integration** `6.0.33` -> `6.0.50`. Qt 6.9 / missing-include patches are
  upstream in 6.0.50, so no fetchpatch needed.
- **treeland-protocols** `0.4.5` -> `0.6.0`.
- **deepin-terminal** `6.0.17` -> `6.5.40`. First app upgraded to Qt6 (Dtk6
  Widget). Dropped qt5integration/qt5platform-plugins/chrpath deps; added
  qt5compat, libchardet, libuchardet, glib, icu, xorg.xcbutilwm. Patched out two
  hardcoded `/usr/...` install paths.
- **deepin-pdfium** `1.0.2` -> `1.5.8`. Switched from qmake/Qt5 to cmake/Qt6.
  Added zlib/libpng/libjpeg/icu/openjpeg/lcms2/freetype/libchardet; dropped
  Qt5. Fixes `.pc` double-prefix in postInstall.
- **docparser** `1.0.11` -> `1.0.26`. No Qt needed anymore (pure cmake). Added
  freetype, minizip, zlib, file (libmagic); dropped Qt5/qttools. Patched
  `add_link_options(-pie)` (CMake 4.x breaks shared-lib link with `-pie`).
- **gio-qt** `0.0.14` -> `0.0.16`. Upstream builds qt5+qt6 in one run; patch out
  `include(qt5.cmake)`. Library only, so `dontWrapQtApps = true`. Docs disabled
  by default.
- **udisks2-qt6** new package `6.0.1` (cmake/Qt6), replaces `udisks2-qt5`
  (deleted). Fixes `.pc` double-prefix in postInstall.
- **qt6mpris** `1.0.0.1-1deepin1` -> `1.0.0.1-1deepin2`. Version bump only.

## Not yet upgraded (recorded blockers)

These were investigated and deliberately left commented out in
`packages/default.nix`. Revisit when their blockers are resolved.

- **dde-qt-dbus-factory** `6.0.1`: still qmake. Its `libdframeworkdbus.pro`
  does `load(dtk_qmake)` and `load(dtk_translation)`, but our dtkcore 6.7.50
  (Qt6 build) installs no `mkspecs/features`/`mkspecs/modules` (no `dtk_qmake`
  .prf/.pri). Needs either a Qt6-era qmake feature package or a cmake upstream
  migration. Reference (`nixos-unstable-dde-25-flake`) does not package it.
- **disomaster** `5.0.8`: still qmake (`libisoburn-1` only dep, no dtk). Should
  build with `qt6Packages.qmake` but untested; low priority (only used by
  dde-file-manager burn backend via util-dfm).
- **util-dfm** `1.4.5`: cmake/Qt6 available (`OPT_ENABLE_QT6=ON`), but pulls a
  wide dep chain — `Dtk6::Core` (dtkcore), `lucenepp` (needs boost),
  libmediainfo/libisoburn/libsecret/udisks2/libmount/glib. Reference uses
  `dtk6core` (6.0.50) + `lucenepp` + `boost`. Blocked on deciding whether to
  also ship the `dtk6*`-suffixed alias set, since util-dfm's
  `find_package(Dtk${DFM_VERSION_MAJOR} ...)` expects `Dtk6Core` while our
  scope only exposes `dtkcore`. Defer until dde-file-manager is unblocked.

## Gotchas

### SRI hash for `fetchFromGitHub`

`fetchFromGitHub` fetches `archive/<rev>.tar.gz`, which differs (metadata /
timestamp) from the `refs/tags/<tag>.tar.gz` tarball that `nix-prefetch-url`
or a manual `curl` downloads. A hash computed against the `refs/tags` tarball
will mismatch. Two ways to get the right one:

- Run `nix build` and copy the `got:` hash from the hash-mismatch error, or
- `nix-prefetch-url --unpack https://github.com/<owner>/<repo>/archive/<rev>.tar.gz`
  (returns base32) then convert to SRI:
  `nix hash to-sri --type sha256 <base32>`.

### DTK 6.7.x builds both Qt5 and Qt6 from one source

The `dtk*` repos at 6.7.x default to `DTK5=ON` (Qt5). To build the Qt6 variant
pass `-DDTK5=OFF`. The suffix (`dtk6core` vs `dtkcore`, `Dtk6Log` vs `DtkLog`)
is derived from this flag, not from the repo name.

### Qt 6.9 fixes are already upstream in 6.7.50

The `fetchpatch` Qt 6.9 compatibility patches used by nixpkgs for the 6.0.x
`dtk6*` packages (e.g. `dvtablehook.h`'s `#if QT_VERSION >= QT_VERSION_CHECK(6, 9, 0)`,
`dconfig2cpp` unicode cast) are already merged into the 6.7.50 tags. Do not
carry them over when upgrading to 6.7.x.

### dtkgui needs dtkcommon's dsg config JSON at configure time

`dtkgui`'s `src/kernel/kernel.cmake` hardcodes
`/usr/share/dsg/configs/org.deepin.dtk.preference.json` on Linux, which only
exists inside the `dtkcommon` store path. Patch it in `postPatch`:

```nix
substituteInPlace src/kernel/kernel.cmake \
  --replace-fail '/usr/share/dsg/configs/org.deepin.dtk.preference.json' \
                 '${dtkcommon}/share/dsg/configs/org.deepin.dtk.preference.json'
```

### `finalAttrs` derivation cannot use bare `src` in postUnpack

In `stdenv.mkDerivation (finalAttrs: { ... })`, the `postUnpack` (and other
phases) must reference the source via `finalAttrs.src.name`, not `${src}`:

```nix
postUnpack = ''
  tar -xf ${qt6Packages.qtbase.src}
  mv qtbase-everywhere-src-${qt6Packages.qtbase.version}/src/plugins/platforms/xcb \
     ${finalAttrs.src.name}/xcb/libqt6xcbqpa-dev/${qt6Packages.qtbase.version}
'';
```

### deepin-terminal 6.5.40 hardcodes `/usr` install paths

`deepin-terminal` installs the manual into
`/usr/share/deepin-manual/manual-assets/application/`, and its vendored
`3rdparty/terminalwidget/CMakeLists.txt` does `set(CMAKE_INSTALL_PREFIX "/usr")`,
which breaks the nix install phase. Patch both in `postPatch`:

```nix
postPatch = ''
  substituteInPlace CMakeLists.txt \
    --replace-fail '/usr/share/deepin-manual/manual-assets/application/' 'share/deepin-manual/manual-assets/application/'
  substituteInPlace 3rdparty/terminalwidget/CMakeLists.txt \
    --replace-fail 'set(CMAKE_INSTALL_PREFIX "/usr")' '# nix: do not override install prefix'
'';
```

Note: `''` cannot be used as an empty `--replace` target in an indented Nix
string (it terminates the string); replace with a comment instead.

### `add_link_options(-pie)` breaks shared libs on CMake 4.x

`docparser` (and other deepin cmake projects) set
`add_link_options(-z noexecstack -pie -fPIC)` globally. On CMake 4.4.x that
`-pie` reaches the shared-library link and fails with
`undefined reference to main`. Strip `-pie` in `postPatch`.

### `.pc` double-prefix (`${prefix}//nix/store/...`)

Deepin cmake libraries generate pkg-config files with
`libdir=${prefix}/@CMAKE_INSTALL_LIBDIR@` while nix already sets absolute
install dirs, producing `${prefix}//nix/store/...`. Fix in `postInstall`:

```nix
postInstall = ''
  find $out/lib/pkgconfig -name "*.pc" -exec sed -i "s|''${prefix}/|/|g" {} +
'';
```

### `dtk*` 6.7.x build docs only for Qt5

The 6.7.x `dtkgui`/`dtkcore` CMake force `BUILD_DOCS=OFF` when Qt6 is selected,
so nothing installs into the `doc` output and nix fails with
`failed to produce output path for output 'doc'`. Drop the `doc` output (or keep
`-DBUILD_DOCS=ON` + `doxygen`) and pass `-DBUILD_DOCS=OFF` to keep the build
clean.

### Path-fix patches changed context in 6.7.x

The nixpkgs `fix-pkgconfig-path.patch` / `fix-pri-path.patch` substitute
`@DTK_VERSION_MAJOR@` in older DTK sources, but 6.7.x uses `@DTK_NAME_SUFFIX@`.
Regenerate the patches against the new source before applying.

### `nixpkgs` input was bumped

Building the Qt6 packages requires a recent nixpkgs (Qt 6.9+ / `wrapGAppsHook3`).
`flake.lock` now pins a much newer nixpkgs than the original snapshot, so the
previously documented "keep nixpkgs untouched" note no longer applies.
