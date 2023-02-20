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
, mtdev
, xorg
, gtest
}:
let
  libqtxdg =  lxqt.libqtxdg.overrideAttrs(drv: {
      patches = [ ./fix-icon.patch ];
  });
in
stdenv.mkDerivation rec {
  pname = "qt5integration";
  version = "5.6.5";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-Xj8SyV5IIHxjQsdnVJQhfbw6fvCeiMckexUo+6W0GM0=";
  };

  nativeBuildInputs = [ qmake pkg-config wrapQtAppsHook ];

  buildInputs = [
    dtkwidget
    qtx11extras
    qt5platform-plugins
    mtdev
    libqtxdg
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
