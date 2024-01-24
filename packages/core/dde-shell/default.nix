{ stdenv
, lib
, fetchFromGitHub
, cmake
, extra-cmake-modules
, pkg-config
, wrapQtAppsHook
, wayland-scanner
, qtbase
, qtwayland
, dtkdeclarative
, wayland
, wayland-protocols
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-shell";
  version = "unstable-2024-01-24";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-shell";
    rev = "bfd8c7ae6f31184f2f530bcf921d1d00b459fdf6";
    hash = "sha256-+tVFd8551iPcQRV3PA/CtW3bqpk0vEZXPaXYdsmwTDw=";
  };

  patches = [
    ./no-plugin.diff
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
    wrapQtAppsHook
    wayland-scanner
  ];

  buildInputs = [
    qtbase
    qtwayland
    dtkdeclarative
    wayland
    wayland-protocols
  ];

  cmakeFlags = [
    (lib.cmakeFeature "SYSTEMD_USER_UNIT_DIR" "${placeholder "out"}/lib/systemd/user")
  ];

  #FIXME: lib/qt6/qml/org/deepin/ds/dock/libdock-plugin.so
  noAuditTmpdir = true;

  meta = {
    description = "A plugin system that integrates plugins developed on DDE";
    homepage = "https://github.com/vioken/qwlroots";
    license = with lib.licenses; [ gpl3Plus ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ rewine ];
  };
})
