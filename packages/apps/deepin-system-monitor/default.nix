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
  version = "5.9.25";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-11XEHVEMQp+BJ1wxq9/VCRz8voGuhIBO4kl+1E1WSSs=";
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
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DUSE_DEEPIN_WAYLAND=OFF"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  patches = [
    (fetchpatch {
      name = "Add_build_flag_to_disable_wayland_support_patch";
      url = "https://github.com/linuxdeepin/deepin-system-monitor/pull/161/commits/7d0df4597f066fc785809a44c5fbc307a5c3fd66.patch";
      sha256 = "sha256-GhVWUOy6nqoDXk+96AGaB0WUN3CAN47H0GWqQEtVchQ=";
    })
  ];

  postPatch = getPatchFrom patchList + ''
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
