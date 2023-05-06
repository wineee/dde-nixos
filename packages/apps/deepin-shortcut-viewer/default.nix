{ stdenv
, lib
, fetchFromGitHub
, dtkwidget
, qt5integration
, qt5platform-plugins
, qmake
, qtbase
, qttools
, pkg-config
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "deepin-shortcut-viewer";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "703e2053e99eae1fc53917ff0a8009aee1307692";
    sha256 = "sha256-LrvENN37q8iy24BqKfHZAXACBqWHwe2uMiq+YTNQhCA=";
  };

  nativeBuildInputs = [
    qmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    dtkwidget
    qt5integration
    qt5platform-plugins
  ];

  qmakeFlags = [
    "VERSION=${version}"
    "PREFIX=${placeholder "out"}"
  ];

  meta = with lib; {
    description = "Deepin Shortcut Viewer";
    homepage = "https://github.com/linuxdeepin/deepin-shortcut-viewer";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}