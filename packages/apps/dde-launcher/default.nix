{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, fetchpatch
, dtk
, dde-qt-dbus-factory
, qt5integration
, qt5platform-plugins
, cmake
, qttools
, qtx11extras
, pkgconfig
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
    ### MISC
    "dde-launcher.desktop" = [ ];
    "dde-launcher-wapper" = [
      [ "dbus-send" "${dbus}/bin/dbus-send" ]
      # "/usr/share/applications/dde-launcher.desktop"
    ];
    "src/dbusservices/com.deepin.dde.Launcher.service" = [
      # "/usr/bin/dde-launcher-wapper"
    ];

    ### CODE
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
  version = "5.5.32";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-h9s1LhbUY7C6mdp9ZmesjdcGpMF9P/oAXnlHvB27YrE=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/dde-launcher/commit/121d6048092c7afc96d788e360445644e4fb95dd.diff";
      sha256 = "sha256-14hhnBWWURYuy0rbO/y2mRp6ktm6cxcZOPrVI/ruAKc=";
    })
  ];

  postPatch = getUsrPatchFrom patchList;

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
