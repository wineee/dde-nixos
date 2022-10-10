{ stdenv
, lib
, getUsrPatchFrom
, fetchFromGitHub
, dtk
, dde-qt-dbus-factory
, deepin-movie-reborn
, qt5integration
, qt5platform-plugins
, cmake
, qttools
, pkg-config
, wrapQtAppsHook
, qtbase
, gtest
}:
let
  patchList = {
    "src/mainwindow.h" = [ ];
    "src/modules/videowidget.cpp" = [ ];
    "src/widgets/bottomnavigation.cpp" = [ ];
  }; 
in stdenv.mkDerivation rec {
  pname = "dde-introduction";
  version = "unstable-2022-09-23";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "f7427cabf249ac370f9755f2bf313fb609b9facc";
    sha256 = "sha256-P0Cz54e2Lngze5gkFGTQKgmcuJMyExSrfJDHb8GkeRo=";
  };

  postPatch = getUsrPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    deepin-movie-reborn
    gtest
  ];

  cmakeFlags = [
    "-DVERSION=${version}" 
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "dde introduction";
    homepage = "https://github.com/linuxdeepin/dde-introduction";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
