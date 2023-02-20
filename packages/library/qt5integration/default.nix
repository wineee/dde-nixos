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
  aaa =  lxqt.libqtxdg.overrideAttrs(drv: {
      patches = [ ./fix-icon.patch ];
  });
in
stdenv.mkDerivation rec {
  pname = "qt5integration";
  version = "5.6.4";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-MZkhTvjTyBrlntgFq2F3iGK7WvfmnGJQLk5B1OM5kQo=";
  };

  nativeBuildInputs = [ qmake pkg-config wrapQtAppsHook ];

  buildInputs = [
    dtkwidget
    qtx11extras
    qt5platform-plugins
    mtdev
    aaa
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
