{ stdenv
, lib
, fetchFromGitHub
, dtkcommon
, dtkcore
, dtkgui
, dtkwidget
, qt5integration
, qt5platform-plugins
, deepin-gettext-tools
, dde-qt-dbus-factory
, image-editor
, dde-api
, cmake
, pkgconfig
, qttools
, qtmultimedia
, wrapQtAppsHook
, ffmpeg
, ffmpegthumbnailer
, libusb1
, portaudio
, libv4l
, libudev0-shim
, gst_all_1
}:

stdenv.mkDerivation rec {
  pname = "deepin-camera";
  version = "1.3.8.3";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-ZOS5Sgf5GL/YRM9X7OT5Sfn0BiqI4RDs+QeUqj/HAng=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    deepin-gettext-tools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
    dde-qt-dbus-factory
    image-editor
    qtmultimedia
    ffmpeg
    ffmpegthumbnailer
    libusb1
    portaudio
    libv4l
    dde-api
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
    "--prefix PATH : ${lib.makeBinPath [ gst_all_1.gstreamer ]}"
    "--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${gst_all_1.gst-plugins-base}/lib/gstreamer-1.0"
    "--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${gst_all_1.gst-plugins-good}/lib/gstreamer-1.0"
    "--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0"
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ ffmpeg ffmpegthumbnailer dde-api libudev0-shim libusb1 portaudio libv4l ]}"
  ];

  patches = [
    ./0001-fix-libusb-import.patch
    ./0002-CMakeLists-use-cmake-install-prefix.patch
  ];

  meta = with lib; {
    description = "Tool to view camera, take photo and video";
    homepage = "https://github.com/linuxdeepin/deepin-camera";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
