{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, dde-qt-dbus-factory
, wrapQtAppsHook
, qtbase
, qtx11extras
, dtkwidget
, qt5integration
, gtest
}:

stdenv.mkDerivation rec {
  pname = "dde-widgets";
  version = "6.0.13";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-cxbXZHd/KUr6zNrmKbHzcP/jDi9oo7Yiru07J4uwYPE=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    dde-qt-dbus-factory
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtx11extras
    dtkwidget
    qt5integration
    gtest
  ];

  meta = with lib; {
    description = "Desktop widgets service/implementation for DDE";
    homepage = "https://github.com/linuxdeepin/dde-widgets";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
