{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, getUsrPatchFrom
, replaceAll
, dtkwidget
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
  };
in
stdenv.mkDerivation rec {
  pname = "dde-launcher";
  version = "5.6.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-Td8R91892tgJx7FLV2IZ/aPBzDb+o6EYKpk3D8On7Ag=";
  };

  patches = [
    (fetchpatch {
      name = "fix: ambiguous reference to DRegionMonitor ";
      url = "https://github.com/linuxdeepin/dde-launcher/commit/40d0e004cb8035e96d46b87c7f9b2ff56e80366d.patch";
      sha256 = "sha256-zs512/LQe3x/awZp89N3fj4yDOY7mPTeBwh66Pjtcqc=";
    })
  ];

  postPatch = replaceAll "/usr/share/backgrounds" "/run/current-system/sw/share/backgrounds"
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
    dtkwidget
    dde-qt-dbus-factory
    qtx11extras
    gsettings-qt
    gtest
    qt5platform-plugins
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Deepin desktop-environment - Launcher module";
    homepage = "https://github.com/linuxdeepin/dde-launcher";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
