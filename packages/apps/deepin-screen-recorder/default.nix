{ stdenv
, lib
, fetchFromGitHub
, qmake
, pkg-config
, qttools 
, wrapQtAppsHook
, dtkwidget
, qt5integration
, dde-qt-dbus-factory
, dde-dock
, image-editor
, gsettings-qt
, qtbase
, qtmultimedia
, qtx11extras
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
stdenv.mkDerivation rec {
  pname = "deepin-screen-recorder";
  version = "5.11.23";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-yKBF/MmhlgwO5GLwfGgs13ERuzOg8EYjc3bXZ8TvcBU=";
  };
  
  patches = [ ./dont_use_libPath.diff ];

  postPatch = ''
    substituteInPlace screen_shot_recorder.pro deepin-screen-recorder.desktop \
      src/{src.pro,pin_screenshots/pin_screenshots.pro} \
      src/dde-dock-plugins/{shotstart/shotstart.pro,recordtime/recordtime.pro} \
      assets/com.deepin.Screenshot.service \
     --replace "/usr" "$out"
  '';

  nativeBuildInputs = [
    qmake
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    dtkwidget
    dde-qt-dbus-factory
    dde-dock
    image-editor
    gsettings-qt
    qtmultimedia
    qtx11extras
    xorg.libXdmcp
    xorg.libXtst
    xorg.libXcursor
    kwayland
    libusb1
    libv4l
    ffmpeg
    ffmpegthumbnailer
    portaudio
    udev
  ] ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
  ]);

  cmakeBuildType = "RelWithDebInfo";

  # qt5integration must be placed before qtsvg in QT_PLUGIN_PATH
  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}"
  ];

  preFixup = ''
    qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")
  '';

  meta = with lib; {
    description = "screen recorder application for dde";
    homepage = "https://github.com/linuxdeepin/deepin-screen-recorder";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
