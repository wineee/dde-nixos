{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, getPatchFrom
, dtk
, qt5integration
, qt5platform-plugins
, deepin-gettext-tools
, dde-qt-dbus-factory
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
, qtbase
}:
let
  patchList = {
    "deepin-system-monitor-daemon/com.deepin.SystemMonitor.Daemon.service" = [ ];
    "deepin-system-monitor-plugin-popup/com.deepin.SystemMonitorPluginPopup.service" = [ ];
    "deepin-system-monitor-main/translations/policy/com.deepin.pkexec.deepin-system-monitor.policy" = [
      [ "/usr/bin/renice" "renice" ]
      [ "/usr/bin/kill" "kill" ]
      [ "/usr/bin/systemctl" "systemctl" ]
    ];
    "deepin-system-monitor-daemon/deepin-system-monitor-daemon.desktop" = [ ];
    "deepin-system-monitor-plugin-popup/deepin-system-monitor-plugin-popup.desktop" = [ ];

    "deepin-system-monitor-plugin/deepin-system-monitor-plugin.pc.in" = [ ];

    "deepin-system-monitor-daemon/systemmonitorservice.cpp" = [ ];
    "deepin-system-monitor-daemon/main.cpp" = [ ];
    "deepin-system-monitor-main/process/priority_controller.cpp" = [
      [ "/usr/bin/pkexec" "pkexec" ]
      [ "/usr/bin/renice" "renice" ]
    ];
    "deepin-system-monitor-main/process/desktop_entry_cache.cpp" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
    ];
    "deepin-system-monitor-main/process/process_controller.cpp" = [
      [ "/usr/bin/pkexec" "pkexec" ]
      [ "/usr/bin/kill" "kill" ]
    ];
    "deepin-system-monitor-main/service/service_manager.cpp" = [
      [ "/usr/bin/systemctl" "systemctl" ]
      [ "/usr/bin/pkexec" "pkexec" ]
    ];
    "deepin-system-monitor-main/common/common.cpp" = [
      [ "/usr/bin" "/run/current-system/sw/bin" ]
    ];
    "deepin-system-monitor-main/gui/dialog/systemprotectionsetting.cpp" = [ ];
    "deepin-system-monitor-plugin/gui/monitor_plugin.cpp" = [ ];
  };
in
stdenv.mkDerivation rec {
  pname = "deepin-system-monitor";
  version = "5.9.25+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "5296f81344b0cdf3eca52242c89970f91700b896";
    sha256 = "sha256-lj01JMIr3ZjNS5zTsuqPIMQD8n5c/Hr2e0bbuJq2YB8=";
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
    # kwayland

    gsettings-qt
    libpcap
    libnl
    procps

    gtest
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
    "-DUSE_DEEPIN_WAYLAND=OFF"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/deepin-system-monitor/commit/e687b1c35961e8cd664c6e4982bd2c49375090d7.patch";
      sha256 = "sha256-iR0X56OTUY6O8a9as2vF9eBygrbvzYGFcpf407b7jp0=";
    })
  ];

  postPatch = getPatchFrom patchList + ''
    substituteInPlace CMakeLists.txt \
      --replace "ADD_SUBDIRECTORY(deepin-system-monitor-plugin)" "" \
      --replace "ADD_SUBDIRECTORY(deepin-system-monitor-plugin-popup)" ""
  '';

  meta = with lib; {
    description = "a more user-friendly system monitor";
    homepage = "https://github.com/linuxdeepin/deepin-system-monitor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
