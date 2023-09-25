{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtkwidget
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, cmake
, qtbase
, qtsvg
, qttools
, qtx11extras
, pkg-config
, wrapQtAppsHook
, at-spi2-core
, libsecret
, chrpath
, lxqt
}:

stdenv.mkDerivation rec {
  pname = "deepin-terminal";
  version = "6.0.7";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-vXykC/x9F+cPTSqKTWimUhnr+IsfoeQncdj75sXG4/g=";
  };

  cmakeFlags = [ "-DVERSION=${version}" ];

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
    lxqt.lxqt-build-tools
  ];

  buildInputs = [
    qt5integration
    qt5platform-plugins
    qtbase
    qtsvg
    dtkwidget
    dde-qt-dbus-factory
    qtx11extras
    at-spi2-core
    libsecret
    chrpath
  ];

  strictDeps = true;

  meta = with lib; {
    description = "Terminal emulator with workspace, multiple windows, remote management, quake mode and other features";
    homepage = "https://github.com/linuxdeepin/deepin-terminal";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
