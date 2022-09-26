{ stdenv
, lib
, fetchpatch
, fetchFromGitHub
, getUsrPatchFrom
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, dde-dock
, image-editor
, gsettings-qt
, cmake
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
, procps
, qtbase
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
  version = "5.11.8+";

  src = fetchFromGitHub {
    owner = "Decodetalkers";
    repo = pname;
    rev = "84213c514aa8914411d64547b15f0e2cae8f743f";
    sha256 = "sha256-bWnAp/8yAfWjdoVXiifKwoqXMJ0azMLs67p+MxLvmU0=";
  };

  # patches = [
  #   (fetchpatch {
  #     name = "fix: don't hardcode /usr/bin path";
  #     url = "https://github.com/linuxdeepin/deepin-screen-recorder/commit/292c2b7975496e936b5289b52920a36effc05477.patch";
  #     sha256 = "sha256-oMVfM4s1gvHJgG8o+gGrEAbqRNMZQjjqs53kcIS1oYU=";
  #   })
  # ];

  nativeBuildInputs = [
    cmake
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
    procps
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

  meta = with lib; {
    description = "screen recorder application for dde";
    homepage = "https://github.com/linuxdeepin/deepin-screen-recorder";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
