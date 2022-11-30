{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, replaceAll
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
, util-linux
, xorg
, pcre
, libselinux
, libsepol
, wrapQtAppsHook
, gtest
, xkeyboard_config
, qtbase
, qt5integration
, dbus
}:
let
  patchList = {
    "dde-lowpower/main.cpp" = [
      #"/usr/share/dde-session-ui/translations/dde-session-ui_" 
    ];
    "dmemory-warning-dialog/main.cpp" = [
      # /usr/share/dde-session-ui/translations/dde-session-ui_
    ];
    "dde-touchscreen-dialog/main.cpp" = [ ];
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
  version = "5.5.39";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-yLNsUEhYN9TTEdy8K9xWaHFCYIiQbksGEpmXjclCz7w=";
  };

  postPatch = replaceAll "/usr/share/backgrounds" "/run/current-system/sw/share/backgrounds"
      + replaceAll "/usr/share/wallpapers" "/run/current-system/sw/share/wallpapers"
      + replaceAll "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"
      + replaceAll "/usr/share/X11/xkb/rules/base.xml" "${xkeyboard_config}/share/X11/xkb/rules/base.xml"
      + replaceAll "/usr/bin/dbus-send" "${dbus}/bin/dbus-send"
      + replaceAll "/usr/bin/dmemory-warning-dialog" "$out/bin/dmemory-warning-dialog"
      + replaceAll "/usr/share/applications/dde-osd.desktop" "$out/share/applications/dde-osd.desktop"
      + getUsrPatchFrom patchList;

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
    util-linux
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
