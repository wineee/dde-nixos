{ stdenv
, lib
, fetchpatch
, fetchFromGitHub
, getUsrPatchFrom
, replaceAll
, dtkwidget
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
, glib
}:
let
  gstPluginPath = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with gst_all_1; [ gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad ]);
  patchList = {
    "screen_shot_recorder.pro" = [

      [ "src/dde-dock-plugins" "" ] 
    ];
    ###MISC
    "deepin-screen-recorder.desktop" = [ ];
    "com.deepin.Screenshot.service" = [ ];
    "src/dbusservice/com.deepin.Screenshot.service" = [
      [ "/usr/bin/deepin-turbo-invoker" "deepin-turbo-invoker" ]
      # /usr/bin/deepin-screenshot
    ];
    "src/pin_screenshots/com.deepin.PinScreenShots.service" = [ ];
    "assets/com.deepin.Screenshot.service" = [ ];
    "assets/com.deepin.ScreenRecorder.service" = [ ];

    "src/recordertablet.cpp" = [
      # "/usr/share/deepin-screen-recorder/tablet_resources" 
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "deepin-screen-recorder";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "e859e1ee7c30ed46176d7a6614a611d3a1bfc635";
    sha256 = "sha256-vm8P5NvHnGVcmcr7qnu7F8q9S/LhCg5nJihBnZA/KoI=";
  };

  patches = [
    (fetchpatch {
      name = "fix: don't hardcode /usr/bin path";
      url = "https://github.com/linuxdeepin/deepin-screen-recorder/commit/c6fb342eda2c48c1d66f6f791d6b23f7c31c9842.patch";
      sha256 = "sha256-nUAqteSB44PfgJ4NMUl7gALgAC4JZar/5zlsvjQBV94=";
    })
    (fetchpatch {
      name = "feat: use PREFIX to set install path in qmake";
      url = "https://github.com/linuxdeepin/deepin-screen-recorder/commit/5e6d01f4961cb8a0d32d9f75d9354f11b6454819.patch";
      sha256 = "sha256-TGwxm/OSez0YSG2LZFVQ3rUtfCQBUXhcrlVyn4joVro=";
    })
  ];

  postPatch = replaceAll "/usr/bin/dbus-send" "${dbus}/bin/dbus-send" + getUsrPatchFrom patchList;

  qmakeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  nativeBuildInputs = [
    qmake
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
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
    libv4l
    ffmpeg.dev
    ffmpegthumbnailer
    portaudio
    udev
  ] ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ]);

  qtWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ ffmpeg ]}"
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/${qtbase.qtPluginPrefix}"
    "--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${gstPluginPath}"
  ];

  preFixup = ''
    patchelf --add-needed ${udev}/lib/libudev.so $out/bin/deepin-screen-recorder
    patchelf --add-needed ${libv4l}/lib/libv4l2.so $out/bin/deepin-screen-recorder
  '';

  meta = with lib; {
    description = "screen recorder application for dde";
    homepage = "https://github.com/linuxdeepin/deepin-screen-recorder";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
