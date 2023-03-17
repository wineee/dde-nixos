{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtkwidget
, qmake
, qtbase
, qtsvg
, pkg-config
, wrapQtAppsHook
, qtx11extras
, qt5platform-plugins
, lxqt
, kiconthemes
, mtdev
, xorg
, gtest
}:

stdenv.mkDerivation rec {
  pname = "qt5integration";
  version = "5.6.6";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-7b18ydyy/TIEGDkFAoium1LSx3Qs4I4pYpMfehOBZbY";
  };

  #patches = [
  #  (fetchpatch {
  #    name = "refactor: use KIconEngine instead";
  #    url = "https://github.com/linuxdeepin/qt5integration/commit/fc88b79b52b1f90bdcb924269ddb5c6eccad2b99.patch";
  #    sha256 = "sha256-/rZhNwba00qXkU+1Pqa3ptUlPtNNHp6DsHilc6m+ljk=";
  #  })
  #];

  nativeBuildInputs = [ qmake pkg-config wrapQtAppsHook ];

  buildInputs = [
    dtkwidget
    qtx11extras
    qt5platform-plugins
    mtdev
    lxqt.libqtxdg
    kiconthemes
    xorg.xcbutilrenderutil
    gtest
  ];

  installPhase = ''
    mkdir -p $out/${qtbase.qtPluginPrefix}
    cp -r bin/plugins/* $out/${qtbase.qtPluginPrefix}/
  '';

  meta = with lib; {
    description = "Qt platform theme integration plugins for DDE";
    homepage = "https://github.com/linuxdeepin/qt5integration";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
