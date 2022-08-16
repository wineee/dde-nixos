{ stdenv
, lib
, fetchFromGitHub
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, qmake
, qttools
, pkgconfig
, qtsvg
, xorg
, wrapQtAppsHook
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "deepin-picker";
  version = "5.0.28";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-b463PqrCpt/DQqint5Xb0cRT66iHNPavj0lsTMv801k=";
  };

  nativeBuildInputs = [
    qmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
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
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  postPatch = ''
    substituteInPlace com.deepin.Picker.service \
      --replace "/usr/bin/deepin-picker" "$out/bin/deepin-picker"
  '';

  meta = with lib; {
    description = "Color picker application";
    homepage = "https://github.com/linuxdeepin/deepin-picker";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
