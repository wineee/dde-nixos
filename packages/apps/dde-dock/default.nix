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
, glib
, gtest
}:
let
  rpetc = [ "/etc" "$out/etc" ];
  patchList = {
    ### INSTALL
    "CMakeLists.txt" = [ ];
    "plugins/keyboard-layout/CMakeLists.txt" = [ rpetc ];
    
    ### RUN
    "plugins/dcc-dock-plugin/settings_module.cpp" = [ ];
    "plugins/overlay-warning/overlay-warning-plugin.cpp" = [
      [ "/usr/bin/pkexec" "pkexec" ]
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
      #"/etc/lightdm/lightdm-deepin-greeter.conf",
      #"/etc/deepin/dde-session-ui.conf"
      [ "/usr/share/dde-session-ui/dde-session-ui.conf" "share/dde-session-ui/dde-session-ui.conf" ] # TODO
    ];

    "plugins/tray/indicatortray.cpp" = [ rpetc ];
    "plugins/tray/trayplugin.cpp" = [ rpetc ];
    "frame/controller/dockpluginscontroller.cpp" = [ ];
    "frame/window/components/desktop_widget.cpp" = [ 
      [ "/usr/lib/deepin-daemon/desktop-toggle" "${dde-daemon}/lib/deepin-daemon/desktop-toggle" ]
     ];
    
    "frame/util/utils.h" = [
     rpetc # TODO
     # /etc/deepin/icbc.conf 
    ];

    ### OTHER
    "dde-dock.pc.in" = [ ];
    "cmake/DdeDock/DdeDockConfig.cmake" = [ ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-dock";
  version = "5.5.51";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-eTfLdGeNa0S0TuXAI2Q8m/D73tWHKgjoBpt76+FEyaY=";
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

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
  '';

  meta = with lib; {
    description = "Deepin desktop-environment - dock module";
    homepage = "https://github.com/linuxdeepin/dde-dock";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
