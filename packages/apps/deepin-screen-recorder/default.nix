{ stdenv
, lib
, fetchFromGitHub
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, gsettings-qt
, qmake
, qttools
, polkit-qt
, pkgconfig
, qtmultimedia
, qtx11extras
, wrapQtAppsHook
, xorg
, gst_all_1
, kwayland
}:
# TODO
# src/main.cpp : ffmpeg

stdenv.mkDerivation rec {
  pname = "deepin-screen-recorder";
  version = "5.11.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-K5/xnfmtDWO01fl6RVGFoH6O/Jd1movUZGbhrbmpzEw=";
  };

  nativeBuildInputs = [
    qmake
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
    xorg.libXtst
    xorg.libXcursor.dev
    gst_all_1.gst-plugins-base.dev
    kwayland
  ];

  qmakeFlags = [
    "PREFIX=${placeholder "out"}"
    "BINDIR=${placeholder "out"}/bin"
    "ICONDIR=${placeholder "out"}/share/icons/hicolor/scalable/apps"
    "APPDIR=${placeholder "out"}/share/applications"
    "DSRDIR=${placeholder "out"}/share/deepin-screen-recorder"
    "DOCDIR=${placeholder "out"}/share/dman/deepin-screen-recorder"
    "ETCDIR=${placeholder "out"}/etc"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  cmakePatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "add_subdirectory(src/dde-dock-plugins)" ""
    substituteInPlace src/CMakeLists.txt \
      --replace "screen_shot_event.h" "" \
      --replace "lib/GifH/gif.h" "" \
      --replace "xgifrecord.h" "" \
      --replace "screen_shot_event.cpp" ""\
      --replace "xgifrecord.cpp" ""\
      --replace "/usr/share/deepin-manual/manual-assets/application)" "$out/share/deepin-manual/manual-assets/application)"
  '';

  fixInstallPatch = ''
    substituteInPlace screen_shot_recorder.pro \
      --replace "/usr/share/deepin-screen-recorder/translations" "$out/share/deepin-screen-recorder/translations"

    substituteInPlace src/src.pro \
      --replace "/usr/share/deepin-manual/manual-assets/application/" "$out/share/deepin-manual/manual-assets/application/"

    substituteInPlace src/pin_screenshots/pin_screenshots.pro \
      --replace "/usr/bin" "$out/bin" \
      --replace "/usr/share/dbus-1/services" "$out/share/dbus-1/services"
  '';

  rmddedockPatch = ''
    substituteInPlace screen_shot_recorder.pro \
      --replace "src/dde-dock-plugins" " "
  '';

  fixPkgconfigPatch = ''
    substituteInPlace src/src.pro \
      --replace "PKGCONFIG +=xcb xcb-util dframeworkdbus gobject-2.0" "PKGCONFIG +=xcb xcb-util dframeworkdbus gobject-2.0 gstreamer-app-1.0"
  '';

  postPatch = fixInstallPatch + rmddedockPatch + fixPkgconfigPatch;

  meta = with lib; {
    description = "screen recorder application for dde";
    homepage = "https://github.com/linuxdeepin/deepin-screen-recorder";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
