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
, gtest
}:

stdenv.mkDerivation rec {
  pname = "qt5integration";
  version = "unstable-2022-05-18";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "2f7c2ff2bad491883ae05e0cc52568823f3b2009";
    sha256 = "sha256-BG+5jJstA4D6Hz066kzZxQD3ludNTjBJhh1YEpj3pSI=";
  };

  nativeBuildInputs = [ qmake pkgconfig wrapQtAppsHook ];

  buildInputs = [
    dtk
    qtx11extras
    qt5platform-plugins
    mtdev
    lxqt.libqtxdg
    gtest
  ];

  installPhase = ''
    cp -r bin $out
  '';

  dontFixup = true; #FIXME why?

  meta = with lib; {
    description = "Qt platform theme integration plugins for DDE";
    homepage = "https://github.com/linuxdeepin/qt5integration";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
