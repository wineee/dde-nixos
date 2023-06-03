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
, qtbase
, qtmultimedia
, qtx11extras
, image-editor
, gsettings-qt
, xorg
, libusb1
, libv4l
, ffmpeg_4
, ffmpegthumbnailer
, portaudio
, kwayland
, udev
, gst_all_1
}:

stdenv.mkDerivation rec {
  pname = "deepin-screen-recorder";
  version = "6.0.0.999";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "ed96ca36303b97f1719f5e8da3e076cf823ab8a2";
    hash = "sha256-0/L84LRjf4JPc5egQ1hVa43sgYfzakxQwAIlv0WHwKI=";
  };

  patches = [ ./dont_use_libPath.diff ];

  postPatch = ''
    find . -type f -regex ".*\\.\\(pro\\|service\\|desktop\\)" -exec sed -i -e "s|/usr/|$out/|g" {} \;
  '';

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
    qtbase
    qtmultimedia
    qtx11extras
    image-editor
    gsettings-qt
    xorg.libXdmcp
    xorg.libXtst
    xorg.libXcursor
    libusb1
    libv4l
    ffmpeg_4
    ffmpegthumbnailer
    portaudio
    kwayland
    udev
  ] ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
  ]);

  # qt5integration must be placed before qtsvg in QT_PLUGIN_PATH
  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ udev gst_all_1.gstreamer libv4l ffmpeg_4 ffmpegthumbnailer ]}"
  ];

  preFixup = ''
    qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")
  '';

  meta = with lib; {
    description = "Screen recorder application for dde";
    homepage = "https://github.com/linuxdeepin/deepin-screen-recorder";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
