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
  version = "5.6.11";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-6q75QGerve5l1NXppbMQ/4qjZiWq23+LxDrIZeAIF6E=";
  };

  # patches = [
  #  (fetchpatch {
  #    name = "refactor: use KIconEngine instead";
  #    url = "https://github.com/linuxdeepin/qt5integration/commit/822a6a40cddca1c89cc06169e42828b86c6f5a80.patch";
  #    sha256 = "sha256-PRcae63FSAzV0EKG/YipjqwsW6lR+CgKyRbkAY4ZoM4=";
  #  })
  # ];

  nativeBuildInputs = [
    qmake
    pkg-config
    wrapQtAppsHook
  ];

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
    maintainers = teams.deepin.members;
  };
}
