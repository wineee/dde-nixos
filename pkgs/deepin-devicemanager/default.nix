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
, cmake
, qttools
, polkit-qt
, libqtapt
, pkgconfig
, qtx11extras
, wrapQtAppsHook
, gtest
, kmod
}:

stdenv.mkDerivation rec {
  pname = "deepin-devicemanager";
  version = "5.8.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-wtgFyZIJI/Ar3g7VsuB25Zfzr1aunwCU1641kQiu3lk=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
    dde-qt-dbus-factory
    polkit-qt
    libqtapt
    kmod
    gtest
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX /usr)" "set(CMAKE_INSTALL_PREFIX $out)" \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "share/deepin-manual/manual-assets/application/)"
  '';

  meta = with lib; {
    description = "Device Manager is a handy tool for viewing hardware information and managing the devices";
    homepage = "https://github.com/linuxdeepin/deepin-devicemanager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    broken = true;
  };
}
