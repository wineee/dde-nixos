{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, getUsrPatchFrom
, replaceAll
, dtkwidget
, qt5integration
, qt5platform-plugins
, deepin-gettext-tools
, dde-qt-dbus-factory
, dde-dock
, cmake
, pkg-config
, qttools
, qtx11extras
, wrapQtAppsHook
, wayland
, dwayland
, gsettings-qt
, libpcap
, libnl
, qtbase
, dtkcore
, dtkgui
}:
let
  patchList = {
    "deepin-system-monitor-main/process/desktop_entry_cache.cpp" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
    ];
    "deepin-system-monitor-main/common/common.cpp" = [
      [ "/usr/bin" "/run/current-system/sw/bin" ]
    ];
    "deepin-system-monitor-main/gui/dialog/systemprotectionsetting.cpp" = [ ];
    "deepin-system-monitor-daemon/com.deepin.SystemMonitor.Daemon.service" = [ ];
    "deepin-system-monitor-daemon/deepin-system-monitor-daemon.desktop" = [ ];
    "deepin-system-monitor-daemon/systemmonitorservice.cpp" = [ ];
    "deepin-system-monitor-daemon/main.cpp" = [ ];
    "deepin-system-monitor-plugin/deepin-system-monitor-plugin.pc.in" = [ ];
    "deepin-system-monitor-plugin/gui/monitor_plugin.cpp" = [ ];
    "deepin-system-monitor-plugin-popup/com.deepin.SystemMonitorPluginPopup.service" = [ ];
    "deepin-system-monitor-plugin-popup/deepin-system-monitor-plugin-popup.desktop" = [ ];
    "deepin-system-monitor-plugin-popup/common/datacommon.h" = [ ];
  };
in
stdenv.mkDerivation rec {
  pname = "deepin-system-monitor";
  version = "6.0.5";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-LPx9gTWJ5cSPLg4aEkx0W2XgRrg7Xb465AvG3XQYq1E=";
  };

  postPatch = replaceAll "/usr/bin/renice" "renice"
    + replaceAll "/usr/bin/kill" "kill"
    + replaceAll "/usr/bin/systemctl" "systemctl"
    + replaceAll "/usr/bin/pkexec" "pkexec"
    + replaceAll "/usr/bin/deepin-system-monitor" "$out/bin/deepin-system-monitor"
    + getUsrPatchFrom patchList + ''
    substituteInPlace deepin-system-monitor-main/CMakeLists.txt \
      --replace "find_library(LIB_PROCPS NAMES procps REQUIRED)" "" 
    substituteInPlace deepin-system-monitor-plugin-popup/CMakeLists.txt \
      --replace "find_library(LIB_PROPS NAMES procps REQUIRED)" ""
    
    substituteInPlace CMakeLists.txt \
      --replace "ADD_SUBDIRECTORY(deepin-system-monitor-plugin-popup)" " " \
      --replace "ADD_SUBDIRECTORY(deepin-system-monitor-plugin)" " " 
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    deepin-gettext-tools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    dde-qt-dbus-factory
    qtx11extras
    dde-dock.dev
    wayland
    dwayland

    gsettings-qt
    libpcap
    libnl
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
    #"-DUSE_DEEPIN_WAYLAND=OFF"
  ];

  # https://github.com/linuxdeepin/deepin-system-monitor/commit/59d1e3de903a3756afa75b2d3f47c3b0857736e3
  NIX_CFLAGS_COMPILE = [
    "-I${dtkcore}/include/dtk5/DCore"
    "-I${dtkgui}/include/dtk5/DGui"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "a more user-friendly system monitor";
    homepage = "https://github.com/linuxdeepin/deepin-system-monitor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
