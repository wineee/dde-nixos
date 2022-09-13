{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, dtk
, pkg-config
, cmake
, dde-dock
, dde-qt-dbus-factory
, deepin-gettext-tools
, glib
, gsettings-qt
, lightdm_qt
, qttools
, qtx11extras
, utillinux
, xorg
, pcre
, libselinux
, libsepol
, wrapQtAppsHook
, gtest
, xkeyboard_config
, qtbase
, qt5integration
}:
let
  patchList = {
    ### MISC
    "dmemory-warning-dialog/com.deepin.dde.MemoryWarningDialog.service" = [
      # "/usr/bin/dmemory-warning-dialog"
    ];
    "dde-warning-dialog/com.deepin.dde.WarningDialog.service" = [
      # "/usr/lib/deepin-daemon/dde-warning-dialog"
    ];
    "dde-welcome/com.deepin.dde.welcome.service" = [
      # "/usr/lib/deepin-daemon/dde-welcome"
    ];
    "dde-osd/files/com.deepin.dde.freedesktop.Notification.service" = [
      # "/usr/lib/deepin-daemon/dde-osd"
    ];
    "dde-osd/files/com.deepin.dde.Notification.service" = [
      # "/usr/lib/deepin-daemon/dde-osd"
    ];
    "dde-osd/files/com.deepin.dde.osd.service" = [
      # "/usr/lib/deepin-daemon/dde-osd"
    ];
    ### CODE
    "widgets/fullscreenbackground.cpp" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      #[ "/usr/share/wallpapers/deepin/desktop.jpg" ]
      #[ "/usr/share/backgrounds/default_background.jpg" ]
    ];
    "dde-lowpower/main.cpp" = [
      #"/usr/share/dde-session-ui/translations/dde-session-ui_" 
    ];
    "dmemory-warning-dialog/main.cpp" = [
      # /usr/share/dde-session-ui/translations/dde-session-ui_
    ];
    "dde-touchscreen-dialog/main.cpp" = [ ];
    "global_util/xkbparser.h" = [
      [ "/usr/share/X11/xkb/rules/base.xml" "${xkeyboard_config}/share/X11/xkb/rules/base.xml" ]
    ];
    "dnetwork-secret-dialog/main.cpp" = [ ];
    "dde-suspend-dialog/main.cpp" = [ ];
    "dde-warning-dialog/main.cpp" = [ ];
    "dde-bluetooth-dialog/main.cpp" = [ ];
    "dde-welcome/main.cpp" = [ ];
    "dde-hints-dialog/main.cpp" = [ ];
    "dde-osd/main.cpp" = [ ];
    "dde-wm-chooser/main.cpp" = [ ];
    "dde-license-dialog/content.cpp" = [ ];
    "dde-license-dialog/main.cpp" = [ ];
    "dde-osd/notification/bubbletool.cpp" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      # "/usr/share/applications/" + name + ".desktop"
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-session-ui";
  version = "5.5.23";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-q8+aOUmU1PSs7nPYSlV28qq62FrOgPAAH72CKAbd60o=";
  };

  postPatch = getUsrPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    deepin-gettext-tools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-dock
    dde-qt-dbus-factory
    gsettings-qt
    qtx11extras
    pcre
    xorg.libXdmcp
    utillinux
    libselinux
    libsepol
    gtest
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    # wrapGAppsHook or wrapQtAppsHook does not work with binaries outside of $out/bin or $out/libexec
    for binary in $out/lib/deepin-daemon/*; do
      wrapProgram $binary "''${qtWrapperArgs[@]}"
    done
  '';

  meta = with lib; {
    description = "Deepin desktop-environment - Session UI module";
    homepage = "https://github.com/linuxdeepin/dde-session-ui";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
