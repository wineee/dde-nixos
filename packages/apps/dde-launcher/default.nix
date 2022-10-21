{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, dtk
, dde-qt-dbus-factory
, qt5integration
, qt5platform-plugins
, cmake
, qttools
, qtx11extras
, pkg-config
, wrapQtAppsHook
, wrapGAppsHook
, gsettings-qt
, glib
, gtest
, dbus
, qtbase
}:
let
  patchList = {
    "dde-launcher.desktop" = [ ];
    "dde-launcher-wapper" = [
      [ "dbus-send" "${dbus}/bin/dbus-send" ]
      # "/usr/share/applications/dde-launcher.desktop"
    ];
    "src/dbusservices/com.deepin.dde.Launcher.service" = [
      # "/usr/bin/dde-launcher-wapper"
    ];
    "src/boxframe/backgroundmanager.cpp" = [
      [ "/usr/share/backgrounds" "/run/current-system/sw/share/backgrounds" ]
    ];
    "src/boxframe/boxframe.cpp" = [
      [ "/usr/share/backgrounds" "/run/current-system/sw/share/backgrounds" ]
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-launcher";
  version = "5.5.34";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-rKLINEctDbL2c0zBfjMLuKI9fw3YP/MdCbDaBPjWqWM=";
  };

  postPatch = getUsrPatchFrom patchList;

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
    qtx11extras
    gsettings-qt
    gtest
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Deepin desktop-environment - Launcher module";
    homepage = "https://github.com/linuxdeepin/dde-launcher";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
