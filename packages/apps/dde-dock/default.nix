{ stdenv
, lib
, fetchFromGitHub
, getPatchFrom
, fetchpatch
, dtk
, dde-qt-dbus-factory
, qt5integration
, qt5platform-plugins
, dde-control-center
, dde-daemon
, deepin-desktop-schemas
, cmake
, qttools
, qtx11extras
, pkgconfig
, wrapQtAppsHook
, wrapGAppsHook
, gsettings-qt
, libdbusmenu
, xorg
, glib
, gtest
, qtbase
}:
let
  rpetc = [ "/etc" "$out/etc" ];
  patchList = {
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
      [ "/usr/lib/dde-dock/plugins/system-trays" "/run/current-system/sw/lib/dde-dock/plugins/system-trays" ] # TODO https://github.com/NixOS/nixpkgs/pull/59244/files
      #"/etc/lightdm/lightdm-deepin-greeter.conf",
      #"/etc/deepin/dde-session-ui.conf"
      [ "/usr/share/dde-session-ui/dde-session-ui.conf" "share/dde-session-ui/dde-session-ui.conf" ] # TODO
    ];

    "plugins/tray/indicatortray.cpp" = [ rpetc ];
    "plugins/tray/trayplugin.cpp" = [ rpetc ];
    "frame/controller/dockpluginscontroller.cpp" = [
       [ "/usr/lib/dde-dock/plugins" "/run/current-system/sw/lib/dde-dock/plugins" ] # TODO
    ];
    "frame/window/components/desktop_widget.cpp" = [
      [ "/usr/lib/deepin-daemon/desktop-toggle" "${dde-daemon}/lib/deepin-daemon/desktop-toggle" ]
    ];

    "frame/util/utils.h" = [
      rpetc # TODO
      # /etc/deepin/icbc.conf 
    ];

    ### OTHER
    "cmake/DdeDock/DdeDockConfig.cmake" = [ ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-dock";
  version = "5.5.62";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-flFb4Y7gkEQOh4YuRwk4AeonsfFkZLT+w3308WWTrqk=";
  };

  patches = [
     (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/dde-dock/commit/4535a406da2b90363417b1726c6f93a4636490fc.patch";
      sha256 = "sha256-xCKePyvToHJT/C9CgUICQSa1IbV9eGKShHEl78ACGyk=";
    })
    (fetchpatch {
      name = "fix: use correct path in pkgconfig";
      url = "https://github.com/linuxdeepin/dde-dock/commit/f0aaccc9d5353ebf6a63315afe4cc5b42661c4b5.patch";
      sha256 = "sha256-20XayyCbNWpu7NyeTUhPK/uZ531HqEGiozlLfPhFYjQ=";
    })
  ];

  postPatch = getPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
    wrapGAppsHook
  ];
  dontWrapGApps = true;

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    dde-control-center
    qtx11extras
    deepin-desktop-schemas
    gsettings-qt
    libdbusmenu
    xorg.libXcursor
    xorg.libXtst
    xorg.libXdmcp
    gtest
  ];

  outputs = [ "out" "dev" ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    #"--prefix XDG_DATA_DIRS : ${glib.makeSchemaPath "${deepin-desktop-schemas}" "${deepin-desktop-schemas.name}"}"
    #"--prefix DSG_DATA_DIRS : ${placeholder "out"}"
  ];

  # postInstall = ''
  #   glib-compile-schemas "$out/share/glib-2.0/schemas"
  # '';

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Deepin desktop-environment - dock module";
    homepage = "https://github.com/linuxdeepin/dde-dock";
    license = licenses.gpl3Plus;
  };
}
