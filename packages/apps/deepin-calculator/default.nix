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
  version = "5.7.21+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "493d1cba8ee9cc7f3af8af05d4f58bdd656dfdb4";
    sha256 = "sha256-4p7pdhIbAdFZ59UL/ZrMXIW58hKZlQk7/W6ecFlng98=";
  };

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
