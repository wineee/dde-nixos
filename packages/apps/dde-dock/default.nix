{ stdenv
, lib
, fetchFromGitHub
, getPatchFrom
, dtk
, dde-qt-dbus-factory
, qt5integration
, qt5platform-plugins
, dde-control-center
, dde-daemon
, cmake
, qttools
, qtx11extras
, pkgconfig
, wrapQtAppsHook
, gsettings-qt
, libdbusmenu
, xorg
, gtest
}:
let
  rpetc = [ "/etc" "$out/etc" ];
  patchList = {
    ## INSTALL
    "CMakeLists.txt" = [ ];
    "plugins/keyboard-layout/CMakeLists.txt" = [ rpetc ];
    # RUN
    "plugins/dcc-dock-plugin/settings_module.cpp" = [ ];
    "plugins/overlay-warning/overlay-warning-plugin.cpp" = [
      [ "/usr/bin/pkexec" "pkexec" ]
      [ "/usr/sbin/overlayroot-disable" "overlayroot-disable" ] # TODO
    ];
    "plugins/overlay-warning/com.deepin.dde.dock.overlay.policy" = [
      [ "/usr/sbin/overlayroot-disable" "overlayroot-disable" ] # TODO
    ];
    "plugins/show-desktop/showdesktopplugin.cpp" = [
      [ "/usr/lib/deepin-daemon/desktop-toggle" "${dde-daemon}/lib/deepin-daemon/desktop-toggle" ]
    ];
    "plugins/tray/system-trays/systemtrayscontroller.cpp" = [ ];
    "plugins/shutdown/shutdownplugin.h" = [
      rpetc
      [ "/usr/share/dde-session-ui/dde-session-ui.conf" "share/dde-session-ui/dde-session-ui.conf" ] # TODO
    ];

    "plugins/tray/indicatortray.cpp" = [ rpetc ];
    "plugins/tray/trayplugin.cpp" = [ rpetc ];
    "frame/util/utils.h" = [ rpetc ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-dock";
  version = "5.5.9.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-CDL/bzTgp7/gJHcSzo8fYB858ohGEitc3AuNbQX31BY=";
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
    dde-control-center
    qtx11extras
    gsettings-qt
    libdbusmenu
    xorg.libXcursor
    xorg.libXtst
    xorg.libXdmcp
    gtest
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  postPatch = getPatchFrom patchList;

  meta = with lib; {
    description = "Deepin desktop-environment - dock module";
    homepage = "https://github.com/linuxdeepin/dde-dock";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
