{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, replaceAll
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
let
  rpetc = [ "/etc" "$out/etc" ];
  patchList = {
    "plugins/dcc-dock-plugin/settings_module.cpp" = [ ];
    "plugins/tray/system-trays/systemtrayscontroller.cpp" = [ ];
    "plugins/tray/indicatortray.cpp" = [ rpetc ];
    "plugins/tray/trayplugin.cpp" = [ rpetc ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-dock";
  version = "5.5.77";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-Oyh7HiHKfG1Uq65qx2dCLU03sr/oo1dYuLU1wJaT81A=";
  };

  # patches = [ ./0001-dont-use-kwin-screenshot.patch ];

  postPatch = replaceAll "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"
      + replaceAll "/usr/lib/dde-dock/plugins" "/run/current-system/sw/lib/dde-dock/plugins"
      + replaceAll "/usr/bin/pkexec" "pkexec"
      + replaceAll "/usr/sbin/overlayroot-disable" "overlayroot-disable"
      + getUsrPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
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
    license = licenses.lgpl3Plus;
  };
}
