{ stdenv
, lib
, fetchFromGitHub
, dtkwidget
, qt5integration
, dde-qt-dbus-factory
, dde-dock
, image-editor
, gsettings-qt
, qmake
, qttools
, pkg-config
, qtbase
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
, patchelf
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
  
  patches = [
    ./dont_use_libPath.diff
  ];

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
    gst_all_1.gst-plugins-base
    kwayland
    libusb1
    libv4l
    ffmpeg
    ffmpegthumbnailer
    portaudio
    udev
  ];

  # qt5integration must be placed before qtsvg in QT_PLUGIN_PATH
  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix PATH : ${lib.makeBinPath [ ffmpeg ]}"
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ udev ffmpeg ]}"
  ];

  meta = with lib; {
    description = "screen recorder application for dde";
    homepage = "https://github.com/linuxdeepin/deepin-screen-recorder";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
