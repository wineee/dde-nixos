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
  };
in
stdenv.mkDerivation rec {
  pname = "dde-dock";
  version = "5.5.64";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-80yMfCCHuaB8daKf1B7pbQxKBRAXD3zTdlsoCSlh3tg=";
  };

  patches = [
     (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/dde-dock/commit/1e50c56540b607b7bbe2d1587e7d2de6eae4fc58.patch";
      sha256 = "sha256-xCKePyvToHJT/C9CgUICQSa1IbV9eGKShHEl78ACGyk=";
    })
    (fetchpatch {
      name = "fix: use correct path in pkgconfig";
      url = "https://github.com/linuxdeepin/dde-dock/commit/69a66fde944b939e2a9579451c1898def48df75c.patch";
      sha256 = "sha256-d+V4U7aWKbw8kb6eBtxCrAnPltQwpETteI1hsc0SKAk=";
    })
    (fetchpatch {
      name = "chore: check define of VERSION before set";
      url = "https://github.com/linuxdeepin/dde-dock/commit/87ed99c1601d77f63b80a50a589d56cf9fcb72f6.patch";
      sha256 = "sha256-w2cbohBLiuojPKexX8zwQcFWyBC/GVEnnLrA7kC6wb0=";
    })
    (fetchpatch {
      name = "feat: use configure_file set path in DdeDockConfig";
      url = "https://github.com/linuxdeepin/dde-dock/commit/89cd371e57ca5c4bf6d152b47b9159e507d82f8b.patch";
      sha256 = "sha256-ML8Yyt5OkijjSJ5/o/1jS/1O8KjGuNJ+sM+d96xE5GQ=";
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
