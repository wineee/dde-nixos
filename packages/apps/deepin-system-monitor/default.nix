{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, getUsrPatchFrom
, replaceAll
, dtk
, qt5integration
, deepin-gettext-tools
, dde-qt-dbus-factory
, dde-dock
, cmake
, pkg-config
, qttools
, qtx11extras
, wrapQtAppsHook
, kwayland
, gsettings-qt
, libpcap
, libnl
, qtbase
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
  version = "5.9.32";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-jze5Pigk4edjojmpNNwaVVfcpk5Aed/S0y9YE0HdC0A";
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
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    deepin-gettext-tools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    qtx11extras
    dde-dock.dev
    # kwayland

    gsettings-qt
    libpcap
    libnl
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
    "-DUSE_DEEPIN_WAYLAND=OFF"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "a more user-friendly system monitor";
    homepage = "https://github.com/linuxdeepin/deepin-system-monitor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
