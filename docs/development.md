# Development Notes

## Current status

This repository syncs DDE packages from nixpkgs at the last revision that still
contained them (`96e751adaf2f` for packages, `15a586f29d59` for NixOS modules),
then progressively upgrades them to Qt6 and maintains only the upgraded set.

Only the packages listed as **maintained** below are built and exposed via
`flake.nix`; everything else in `packages/default.nix` is commented out and will
be re-enabled one by one as it is upgraded.

## Maintained packages

| Package    | Version | Qt   | Notes                          |
|------------|---------|------|--------------------------------|
| dtkcommon  | 6.7.50  | n/a  | provides `DtkBuildHelper.cmake` |
| dtklog     | 6.7.50  | Qt6  | was `dtk6log`, now `dtklog`    |
| dtkcore    | 6.7.50  | Qt6  | was `dtkcore` (Qt5) + `dtk6core` |

## Upgrade log

- **dtkcommon** `5.7.13` -> `6.7.50`. Installs both `DtkConfig.cmake` and
  `Dtk6Config.cmake` plus `DtkBuildHelper`.
- **dtklog** Qt5 `dtklog` removed; `dtk6log` renamed to `dtklog` and upgraded
  `0.0.2` -> `6.7.50`. Built with `-DDTK5=OFF` to produce
  `libdtk6log.so` + `Dtk6LogConfig.cmake`.
- **dtkcore** Qt5 `dtkcore` (5.6.32) removed; `dtk6core` deleted and `dtkcore`
  upgraded `5.6.32` -> `6.7.50`. Built with `-DDTK5=OFF` to produce
  `libdtk6core.so` + `Dtk6CoreConfig.cmake` / `Dtk6ToolsConfig.cmake`.

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

### `doc` output does not exist for Qt6 builds

`dtkcore`'s CMake sets `BUILD_DOCS=OFF` for non-Qt5 builds, so nothing installs
into the `doc` output and nix fails with
`failed to produce output path for output 'doc'`. Drop the `doc` output (or keep
`-DBUILD_DOCS=ON` + `doxygen`).

### Path-fix patches changed context in 6.7.x

The nixpkgs `fix-pkgconfig-path.patch` / `fix-pri-path.patch` substitute
`@DTK_VERSION_MAJOR@` in older DTK sources, but 6.7.x uses `@DTK_NAME_SUFFIX@`.
Regenerate the patches against the new source before applying.

### `nixpkgs` input was bumped

Building the Qt6 packages requires a recent nixpkgs (Qt 6.9+ / `wrapGAppsHook3`).
`flake.lock` now pins a much newer nixpkgs than the original snapshot, so the
previously documented "keep nixpkgs untouched" note no longer applies.
