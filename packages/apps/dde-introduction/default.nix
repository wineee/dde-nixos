{ stdenv
, lib
, getUsrPatchFrom
, fetchpatch
, fetchFromGitHub
, dtk
, dde-qt-dbus-factory
, deepin-movie-reborn
, qt5integration
, qt5platform-plugins
, cmake
, qttools
, pkgconfig
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
  version = "unstable-2022-08-18";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "43cd3f4fe76dad84edac291ebd601df848b73cc1";
    sha256 = "sha256-h77EzDg7TJqh9/RW7AJSjPHuc6rG5EI88LM72rSLKPk=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/dde-introduction/commit/be4274ee9a26772b996416d368d5ef553fed8a04.diff";
      sha256 = "sha256-j8r3ng9JmITCdV/utMW2GIQQAHMxKE6Knas7ixWbVGU=";
    })
  ];

  postPatch = getUsrPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
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
