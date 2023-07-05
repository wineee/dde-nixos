{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, cmake
, qttools
, pkg-config
, wrapQtAppsHook
, qtbase
, qtsvg
, dtkwidget
, dde-dock
, dde-control-center
, dde-session-shell
, networkmanager-qt
, glib
, gtest
}:

stdenv.mkDerivation rec {
  pname = "dde-network-core";
  version = "2.0.10.999";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "a9cf8b3dead543913e00a9acb4b93d437e97ed59";
    hash = "sha256-CJE+/UtArhebti6f4kAkYq1ZrRb7zeDBNsv/TLiPpMI=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtsvg
    dtkwidget
    dde-dock
    dde-control-center
    dde-session-shell
    networkmanager-qt
    glib
    gtest
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
  ];

  strictDeps = true;

  meta = with lib; {
    description = "DDE network library framework";
    homepage = "https://github.com/linuxdeepin/dde-network-core";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
