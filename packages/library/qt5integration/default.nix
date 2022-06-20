{ stdenv
, lib
, fetchFromGitHub
, dtk
, qmake
, pkgconfig
, wrapQtAppsHook
, qtx11extras
, qt5platform-plugins
, lxqt
, mtdev
, xorg
, gtest
}:

stdenv.mkDerivation rec {
  pname = "qt5integration";
  version = "5.5.23";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-mpGbxha5n5wFPhAwXcX1eizn5BvdqnKKcgq1Jm/vUsc=";
  };

  nativeBuildInputs = [ qmake pkgconfig wrapQtAppsHook ];

  buildInputs = [
    dtk
    qtx11extras
    qt5platform-plugins
    mtdev
    lxqt.libqtxdg
    xorg.xcbutilrenderutil
    gtest
  ];

  installPhase = ''
    cp -r bin $out
  '';

  meta = with lib; {
    description = "Qt platform theme integration plugins for DDE";
    homepage = "https://github.com/linuxdeepin/qt5integration";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
