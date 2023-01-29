{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, replaceAll
, dtkwidget
, dde-qt-dbus-factory
, qt5integration
, qt5platform-plugins
, dde-control-center
, dde-daemon
, deepin-desktop-schemas
, cmake
, qttools
, qtx11extras
, pkg-config
, wrapQtAppsHook
, wrapGAppsHook
, gsettings-qt
, libdbusmenu
, xorg
, glib
, gtest
, qtbase
}:
stdenv.mkDerivation rec {
  pname = "dde-dock";
  version = "5.5.81";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-x8U5QPfIykaQLjwbErZiYbZC+JyPQQ+jd6MBjDQyUjs=";
  };

  postPatch = replaceAll "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"
    + replaceAll "/usr/lib/dde-dock/plugins" "/run/current-system/sw/lib/dde-dock/plugins"
    + replaceAll "/usr/bin/pkexec" "pkexec"
    + replaceAll "/usr/sbin/overlayroot-disable" "overlayroot-disable"
    + getUsrPatchFrom {
      "plugins/dcc-dock-plugin/settings_module.cpp" = [ ];
      "plugins/tray/system-trays/systemtrayscontroller.cpp" = [ ];
    };

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
    wrapGAppsHook
  ];
  dontWrapGApps = true;

  buildInputs = [
    dtkwidget
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
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/${qtbase.qtPluginPrefix}"
  ];

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Deepin desktop-environment - dock module";
    homepage = "https://github.com/linuxdeepin/dde-dock";
    platforms = platforms.linux;
    license = licenses.lgpl3Plus;
  };
}
