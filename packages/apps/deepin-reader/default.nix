{ stdenv
, lib
, fetchFromGitHub
, qmake
, pkg-config
, qttools
, wrapQtAppsHook
, dtkwidget
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, qtwebengine
, karchive
, poppler
, libchardet
, libspectre
, openjpeg
, djvulibre
, qtbase
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-reader";
  version = "6.0.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "6032d2c5b3c83e4fadae5f230b23937263e29f52";
    sha256 = "sha256-FEvsjSui0ehLAQKypRJVEttCuYKRUHN7lwLjTNRH2Y0=";
  };

  postPatch = ''
    substituteInPlace deepin_reader.pro \
      --replace "SUBDIRS += htmltopdf" " "
    substituteInPlace reader/document/Model.cpp \
      --replace "/usr/lib/deepin-reader/htmltopdf" "htmltopdf"
  '';

  nativeBuildInputs = [
    qmake
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    qt5integration
    qt5platform-plugins
    dde-qt-dbus-factory
    qtwebengine
    karchive
    poppler
    libchardet
    libspectre
    djvulibre
    openjpeg
    gtest
  ];

  qmakeFlags = [
    "DEFINES+=VERSION=${version}"
    "DEFINES+=OS_BUILD_V23"
  ];

  meta = with lib; {
    description = "A simple memo software with texts and voice recordings";
    homepage = "https://github.com/linuxdeepin/deepin-reader";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}