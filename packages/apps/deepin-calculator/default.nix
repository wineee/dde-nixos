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
, pkgconfig
, qtx11extras
, wrapQtAppsHook
, gtest
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "deepin-calculator";
  version = "5.7.21";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-uM8qtlNMBL/XS/PTgNMwDo+iREvOrp07DaRZvPvpb2s=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/deepin-calculator/commit/aa565ccb961cbc29666559041b6db1ba581b089b.patch";
      sha256 = "sha256-jUX+8TOcXkPi2lQmrapu0mpeX8sBIRLGHdKtuJjhybY=";
    })
  ];

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    gtest
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  meta = with lib; {
    description = "An easy to use calculator for ordinary users";
    homepage = "https://github.com/linuxdeepin/deepin-calculator";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
