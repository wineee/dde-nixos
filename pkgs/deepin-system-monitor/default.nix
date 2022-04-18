{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, qt5integration
, qt5platform-plugins
, deepin-gettext-tools
, dde-qt-dbus-factory
, gio-qt
, udisks2-qt5
, image-editor
, cmake
, pkgconfig
, qttools
, qtsvg
, qtx11extras
, wrapQtAppsHook
, kwayland
, gsettings-qt
, libpcap
, libnl
, procps
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-system-monitor";
  version = "5.9.17";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-rcQspAjRYr/HINLOlz85zO5qIOwCchq5+23F60tr8hY=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    deepin-gettext-tools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    qtx11extras
    kwayland

    gsettings-qt
    libpcap
    libnl
    procps

    gtest
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DWAYLAND_SESSION_SUPPORT=OFF"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  #enableParallelBuilding = false;

  patches = [
    (fetchpatch {
      url = "https://github.com/linuxdeepin/deepin-system-monitor/commit/36dc3291fd45810310c3fdaeb33e493ae6433778.patch";
      sha256 = "sha256-9WwiEENrwxsacSFZ5WllQuhykHGAkmv7Agph6oyA/4k=";
      name = "Add_build_flag_to_disable_wayland_support_patch";
    })
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "ADD_SUBDIRECTORY(deepin-system-monitor-plugin)" "" \
      --replace "ADD_SUBDIRECTORY(deepin-system-monitor-plugin-popup)" ""

    substituteInPlace deepin-system-monitor-main/CMakeLists.txt \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "$out/share/deepin-manual/manual-assets/application/)"
      
    substituteInPlace deepin-system-monitor-daemon/CMakeLists.txt \
      --replace "/etc/xdg/autostart)" "$out/xdg/autostart)" \
      --replace "/usr/share/dbus-1/services)" "$out/share/dbus-1/services)" \
      --replace "\"/usr/share/deepin-system-monitor-daemon/translations\")" "$out/share/deepin-system-monitor-daemon/translations)"
  '';

  meta = with lib; {
    description = "a more user-friendly system monitor";
    homepage = "https://github.com/linuxdeepin/deepin-system-monitor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
