{ stdenv
, lib
, fetchpatch
, fetchFromGitHub
, getUsrPatchFrom
, replaceAll
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, dde-dock
, image-editor
, gsettings-qt
, cmake
, qmake
, qttools
, pkg-config
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
, patchelf
}:
# TODO
# src/main.cpp : ffmpeg
let
  gstPluginPath = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with gst_all_1; [ gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad ]);
  patchList = {
    "screen_shot_recorder.pro " = [ ];
    "src/src.pro" = [ ];
    "src/pin_screenshots/pin_screenshots.pro" = [ ];
    "src/dde-dock-plugins/shotstart/shotstart.pro" = [ ];
    "src/dde-dock-plugins/recordtime/recordtime.pro" = [ ];

    ###MISC
    "deepin-screen-recorder.desktop" = [ ];
    "assets/screenRecorder.json" = [
      # /usr/share/deepin-screen-recorder/tablet_resources/fast-icon_recording_normal.svg
    ];
    "com.deepin.Screenshot.service" = [
      # /usr/share/applications/deepin-screen-recorder.desktop
    ];
    "src/dbusservice/com.deepin.Screenshot.service" = [
      [ "/usr/bin/deepin-turbo-invoker" "deepin-turbo-invoker" ]
      # /usr/bin/deepin-screenshot
    ];
    "src/pin_screenshots/com.deepin.PinScreenShots.service" = [
      # /usr/bin/deepin-pin-screenshots
    ];
    "assets/com.deepin.Screenshot.service" = [
      #/usr/bin/deepin-screen-recorder
    ];
    "assets/com.deepin.ScreenRecorder.service" = [
      # /usr/bin/deepin-screen-recorder
    ];

    ### CODE
    "src/recordertablet.cpp" = [
      #/usr/share/deepin-screen-recorder/tablet_resources
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "deepin-screen-recorder";
  version = "5.11.10";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-N/jscymVdvfO5/jpDfHH5APlufeHaeIvD0Ky33DL0oc=";
  };

  patches = [
    (fetchpatch {
      name = "fix: don't hardcode /usr/bin path";
      url = "https://github.com/linuxdeepin/deepin-screen-recorder/pull/227/commits/292c2b7975496e936b5289b52920a36effc05477.patch";
      sha256 = "sha256-oMVfM4s1gvHJgG8o+gGrEAbqRNMZQjjqs53kcIS1oYU=";
    })
  ];

  postPatch = getUsrPatchFrom patchList + replaceAll "/usr/bin/dbus-send" "${dbus}/bin/dbus-send";

  qmakeFlags = [
    "PREFIX=${placeholder "out"}"
    "BINDIR=${placeholder "out"}/bin"
    "ICONDIR=${placeholder "out"}/share/icons/hicolor/scalable/apps"
    "APPDIR=${placeholder "out"}/share/applications"
    "DSRDIR=${placeholder "out"}/share/deepin-screen-recorder"
    "DOCDIR=${placeholder "out"}/share/dman/deepin-screen-recorder"
    "ETCDIR=${placeholder "out"}/etc"
  ];

  nativeBuildInputs = [
    qmake #cmake
    pkg-config
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

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${gstPluginPath}"
  ];

  preFixup = ''
      patchelf --add-needed ${udev}/lib/libudev.so $out/bin/deepin-screen-recorder
  '';

  meta = with lib; {
    description = "screen recorder application for dde";
    homepage = "https://github.com/linuxdeepin/deepin-screen-recorder";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
