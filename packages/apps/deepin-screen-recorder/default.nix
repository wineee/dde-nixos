{ stdenv
, lib
, fetchFromGitHub
, getPatchFrom
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, image-editor
, gsettings-qt
, qmake
, qttools
, pkgconfig
, qtmultimedia
, qtx11extras
, wrapQtAppsHook
, xorg
, gst_all_1
, libusb1
, ffmpeg
, ffmpegthumbnailer
, portaudio
, libv4l
, udev
, kwayland
}:
# TODO
# src/main.cpp : ffmpeg
let
  gstPluginPath = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with gst_all_1; [ gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad ]);
  patchList = {

    ###MISC
    "deepin-screen-recorder.desktop" = [ ];
    "assets/screenRecorder.json" = [
      # /usr/share/deepin-screen-recorder/tablet_resources/fast-icon_recording_normal.svg
    ];
    "com.deepin.Screenshot.service" = [
      [ "/usr/bin/dbus-send" "dbus-send" ]
      # /usr/share/applications/deepin-screen-recorder.desktop
    ];
    "src/dbusservice/com.deepin.Screenshot.service" = [
      [ "/usr/bin/deepin-turbo-invoker" "deepin-turbo-invoker" ]
      # /usr/bin/deepin-screenshot
    ];
    "src/pin_screenshots/com.deepin.PinScreenShots.service" = [
      [ "/usr/bin/dbus-send" "dbus-send" ]
      # /usr/bin/deepin-pin-screenshots
    ];
    "assets/com.deepin.Screenshot.service" = [
      [ "/usr/bin/dbus-send" "dbus-send" ]
      #/usr/bin/deepin-screen-recorder
    ];
    "assets/com.deepin.ScreenRecorder.service" = [
      # /usr/bin/deepin-screen-recorder
    ];
    "com.deepin.ScreenRecorder.service" = [
      [ "/usr/bin/dbus-send" "dbus-send" ]
    ];

    ### CODE
    "src/recordertablet.cpp" = [
      #/usr/share/deepin-screen-recorder/tablet_resources
    ];
    "src/pin_screenshots/mainwindow.cpp" = [
      #? QFile("/usr/bin/dde-file-manager").exists()
    ];

    "src/main.cpp" = [
      #? /usr/bin/ffmpeg why not "which ffmpeg"
    ];

    "src/main_window.cpp" = [
      #? QFile("/usr/bin/deepin-album").exists() ..
    ];
  };
in
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
    image-editor
    #polkit-qt
    gsettings-qt
    qtmultimedia
    qtx11extras
    xorg.libXdmcp
    xorg.libXtst
    xorg.libXcursor.dev
    gst_all_1.gst-plugins-base.dev
    kwayland
    libusb1
    libv4l.dev
    ffmpeg.dev
    ffmpegthumbnailer
    portaudio
    udev
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
    "--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${gstPluginPath}"
  ];

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

  postPatch = fixInstallPatch + rmddedockPatch + fixPkgconfigPatch + getPatchFrom patchList;

  meta = with lib; {
    description = "screen recorder application for dde";
    homepage = "https://github.com/linuxdeepin/deepin-screen-recorder";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
