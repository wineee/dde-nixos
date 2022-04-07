{ stdenv
, lib
, fetchFromGitHub
, dtkcore
, dtkgui
, dtkwidget
, dtkcommon
, qt5integration
, qt5platform-plugins
, qmake
, qttools
, pkgconfig
, qtwebengine
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "dmarked";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "wineee";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-0Zj5CmrvSBaYdfr82/mSDsh75uupZvqLODwKOYNe83c=";
  };

  nativeBuildInputs = [
    qmake
    #qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
    qtwebengine
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  qmakeFlags = [
    "BINDIR=${placeholder "out"}/bin"
    "APPDIR=${placeholder "out"}/share/applications"
    "DSRDIR=${placeholder "out"}/share/dmarked"
  ];

  postPatch = ''
    #substituteInPlace CMakeLists.txt \
    #  --replace "set(CMAKE_INSTALL_PREFIX /usr)" "set(CMAKE_INSTALL_PREFIX $out)" \
    #  --replace "/usr/share/deepin-manual/manual-assets/application/)" "share/deepin-manual/manual-assets/application/)"
  '';

  meta = with lib; {
    description = "An easy to use calculator for ordinary users";
    homepage = "https://github.com/linuxdeepin/deepin-calculator";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
