{ stdenv
, lib
, fetchFromGitHub
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, cmake
, qttools
, polkit-qt
, pkgconfig
, qtx11extras
, wrapQtAppsHook
, pciutils
, libcups
, gtest
, kmod
}:

stdenv.mkDerivation rec {
  pname = "deepin-devicemanager";
  version = "5.6.32";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-vUxLZ3rx341mkLTdKrlSTBBSRFoywShWyTRO30KDccc=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    polkit-qt
    kmod
    pciutils
    libcups
    gtest
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
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
  };
}
