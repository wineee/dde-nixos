{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtkcommon
, dtkcore
, dtkgui
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

stdenv.mkDerivation rec {
  pname = "qt5integration";
  version = "5.6.4";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-MZkhTvjTyBrlntgFq2F3iGK7WvfmnGJQLk5B1OM5kQo=";
  };

  patches = [
    (fetchpatch {
      name = "basic_support_for_ColorScheme_Highlight";
      url = "https://github.com/linuxdeepin/qt5integration/commit/1f985ea13133235707ab1e37c6371d25850fed10.patch";
      sha256 = "sha256-cHR5kfsRQO3jqEXQNYl/TEHqjxgr0Sbf65UmFn+xSTA=";
    })
  ];

  nativeBuildInputs = [ qmake pkg-config wrapQtAppsHook ];

  buildInputs = [
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
    qtx11extras
    qt5platform-plugins
    mtdev
    lxqt.libqtxdg
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
