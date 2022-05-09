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
, cups
, czmq
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
    cups
    czmq
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

    substituteInPlace deepin-devicemanager/CMakeLists.txt \
      --replace "/usr/include/cups/" "${cups.dev}/include/cups/" \
      --replace "set(CMAKE_INSTALL_PREFIX /usr)" "set(CMAKE_INSTALL_PREFIX $out)" \
      --replace "/usr/share/icons/hicolor/scalable/apps)" "$out/share/icons/hicolor/scalable/apps)" \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "$out/share/deepin-manual/manual-assets/application/)"

    substituteInPlace deepin-devicemanager-server/CMakeLists.txt \
      --replace "/lib/systemd/system)" "$out/lib/systemd/system)" \
      --replace "/etc/dbus-1/system.d)" "$out/etc/dbus-1/system.d)" 
  '';

  meta = with lib; {
    description = "Device Manager is a handy tool for viewing hardware information and managing the devices";
    homepage = "https://github.com/linuxdeepin/deepin-devicemanager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
