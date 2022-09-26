{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, cmake
, qttools
, pkg-config
, qtmultimedia
, wrapQtAppsHook
, gtest
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "deepin-gomoku";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-/GxmEk3F97N2ngvvERxPjKEjXqFmMVb7kXP6KFY768Q=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/deepin-gomoku/commit/86656382d9ab646a994a4336a6e4c0a8c8e27f68.patch";
      sha256 = "sha256-pOOuBC9kxz09XsssnAsi+xh6Z8ldkvNzFks1IhfXsIw=";
    })
  ];

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    qtmultimedia
    gtest
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "Gomoku is an easy and funny chess game that is suitable for all ages";
    homepage = "https://github.com/linuxdeepin/deepin-gomoku";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
