{ stdenv
, lib
, fetchFromGitHub
, getPatchFrom
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
, deepin-wallpapers
, gtest
, dbus
}:
let
  patchList = {
    ### INSTALL
    "CMakeLists.txt" = [ ];

    ### MISC
    "dde-launcher.desktop" = [
      # "/usr/bin/dde-launcher"
    ];
    "dde-launcher-wapper" = [
      [ "dbus-send" "${dbus}/bin/dbus-send" ]
      # "/usr/share/applications/dde-launcher.desktop"
    ];

    "src/dbusservices/com.deepin.dde.Launcher.service" = [
      # "/usr/bin/dde-launcher-wapper"
    ];

    ### CODE
    "src/boxframe/backgroundmanager.cpp" = [
      [ "/usr/share/backgrounds/default_background.jpg" "${deepin-wallpapers}/share/wallpapers/deepin/desktop.jpg" ]
    ];
    "src/boxframe/boxframe.cpp" = [
      [ "/usr/share/backgrounds/default_background.jpg" "${deepin-wallpapers}/share/wallpapers/deepin/desktop.jpg" ]
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-launcher";
  version = "5.5.19";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-8GusAwDGTfqoqHr+oV6S3OzMXUgqkyzOGnkczx5B6Us=";
  };

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
    qtx11extras
    gsettings-qt
    gtest
    qt5integration
    qt5platform-plugins
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  # qtWrapperArgs = [
  #   "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
  #   "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  # ];

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
