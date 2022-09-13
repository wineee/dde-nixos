{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, dde-dock
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
, dbus
, qtbase
}:
# TODO
# src/main.cpp : ffmpeg
let
  gstPluginPath = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with gst_all_1; [ gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad ]);
  patchList = {
    "src/dde-dock-plugins/shotstart/shotstart.pro" = [ ];
    "src/dde-dock-plugins/recordtime/recordtime.pro" = [ ];

    ###MISC
    "deepin-screen-recorder.desktop" = [ ];
    "assets/screenRecorder.json" = [
      # /usr/share/deepin-screen-recorder/tablet_resources/fast-icon_recording_normal.svg
    ];
    "com.deepin.Screenshot.service" = [
      [ "/usr/bin/dbus-send" "${dbus}/bin/dbus-send" ]
      # /usr/share/applications/deepin-screen-recorder.desktop
    ];
    "src/dbusservice/com.deepin.Screenshot.service" = [
      [ "/usr/bin/deepin-turbo-invoker" "deepin-turbo-invoker" ]
      # /usr/bin/deepin-screenshot
    ];
    "src/pin_screenshots/com.deepin.PinScreenShots.service" = [
      [ "/usr/bin/dbus-send" "${dbus}/bin/dbus-send" ]
      # /usr/bin/deepin-pin-screenshots
    ];
    "assets/com.deepin.Screenshot.service" = [
      [ "/usr/bin/dbus-send" "${dbus}/bin/dbus-send" ]
      #/usr/bin/deepin-screen-recorder
    ];
    "assets/com.deepin.ScreenRecorder.service" = [
      # /usr/bin/deepin-screen-recorder
    ];
    "com.deepin.ScreenRecorder.service" = [
      [ "/usr/bin/dbus-send" "${dbus}/bin/dbus-send" ]
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
    dde-dock
    image-editor
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
  ] ++ ( with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ]);

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
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
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

  fixPkgconfigPatch = ''
    substituteInPlace src/src.pro \
      --replace "PKGCONFIG +=xcb xcb-util dframeworkdbus gobject-2.0" "PKGCONFIG +=xcb xcb-util dframeworkdbus gobject-2.0 gstreamer-app-1.0"
  '';

  postPatch = fixInstallPatch + fixPkgconfigPatch + getUsrPatchFrom patchList;

  meta = with lib; {
    description = "screen recorder application for dde";
    homepage = "https://github.com/linuxdeepin/deepin-screen-recorder";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
