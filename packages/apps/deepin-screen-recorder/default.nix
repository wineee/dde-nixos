{ stdenv
, lib
, fetchFromGitHub
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, gsettings-qt
, cmake
, qttools
, polkit-qt
, pkgconfig
, qtmultimedia
, qtx11extras
, wrapQtAppsHook
, xorg
}:

stdenv.mkDerivation rec {
  pname = "deepin-screen-recorder";
  version = "5.10.22";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-1N/HyctsLrX7S1f1ZkEfHzCPkb70Z9HH7gVygXkqAXs=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    #polkit-qt
    gsettings-qt
    qtmultimedia
    qtx11extras
    xorg.libXdmcp
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  postPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace "screen_shot_event.h" "" \
      --replace "lib/GifH/gif.h" "" \
      --replace "xgifrecord.h" "" \
      --replace "screen_shot_event.cpp" ""\
      --replace "xgifrecord.cpp" ""\
      --replace "/usr/share/deepin-manual/manual-assets/application)" "$out/share/deepin-manual/manual-assets/application)"
  '';

  meta = with lib; {
    description = "Deepin Screen Recorder";
    homepage = "https://github.com/linuxdeepin/deepin-screen-recorder";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
