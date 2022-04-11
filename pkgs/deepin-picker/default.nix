{ stdenv
, lib
, fetchFromGitHub
, dtkcore
, dtkgui
, dtkwidget
, dtkcommon
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, qmake
, qttools
, pkgconfig
, qtsvg
, xorg
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "deepin-picker";
  version = "5.0.24";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-CauaeXQzBfE9EgG6WclmJ7K1nm06iZILxMtvSfqXT3U=";
  };

  nativeBuildInputs = [
    qmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
    qtsvg
    xorg.libXtst
  ];

  qmakeFlags = [
    "BINDIR=${placeholder "out"}/bin"
    "ICONDIR=${placeholder "out"}/share/icons/hicolor/scalable/apps"
    "APPDIR=${placeholder "out"}/share/applications"
    "DSRDIR=${placeholder "out"}/share/deepin-picker"
    "DOCDIR=${placeholder "out"}/share/dman/deepin-picker"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  meta = with lib; {
    description = "Color picker application";
    homepage = "https://github.com/linuxdeepin/deepin-picker";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
