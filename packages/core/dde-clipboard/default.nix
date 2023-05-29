{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtkwidget
, gio-qt
, cmake
, extra-cmake-modules
, qttools
, wayland
, kwayland
, dwayland
, pkg-config
, wrapQtAppsHook
, glibmm
, gtest
}:

stdenv.mkDerivation rec {
  pname = "dde-clipboard";
  version = "6.0.4.999";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "7db6a31d63e27057712b485e7d266f90f0d58d8e";
    hash = "sha256-2AV+zkCk0R1vcK7E0OQ9dIqog5ViOfMQ3xx/0DFE6FM=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/linuxdeepin/dde-clipboard/pull/134/commits/adbacff5943fe4f1ffadd984e6555eb427676108.patch";
      sha256 = "sha256-uQB3I52+BqBv9nGNW/mhBcs5iroBVXrUjgJxxxwtGu0=";
    })
  ];

  postPatch = ''
    substituteInPlace misc/{dde-clipboard.desktop,dde-clipboard-daemon.service,org.deepin.dde.Clipboard1.service} \
      --replace "/usr/bin/qdbus" "${lib.getBin qttools}/bin/qdbus" \
      --replace "/usr" "$out"
  '';

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    gio-qt
    wayland
    kwayland
    dwayland
    glibmm
    gtest
  ];

  meta = with lib; {
    description = "DDE optional clipboard manager componment";
    homepage = "https://github.com/linuxdeepin/dde-clipboard";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}