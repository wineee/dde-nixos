{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, qt5integration
, deepin-gettext-tools
, dde-qt-dbus-factory
, image-editor
, dde-api
, cmake
, pkg-config
, qttools
, qtmultimedia
, wrapQtAppsHook
, ffmpeg
, ffmpegthumbnailer
, libusb1
, portaudio
, libv4l
, gst_all_1
, systemd
, qtbase
}:

let
  gstPluginPath = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with gst_all_1; [ gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad ]);
in
stdenv.mkDerivation rec {
  pname = "deepin-camera";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-XEv/TBKDLMlE4JEIphKfOBmyo1pyhK8SlxDrclQQfTI=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    deepin-gettext-tools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    image-editor
    qtmultimedia
    ffmpeg
    ffmpegthumbnailer
    libusb1
    portaudio
    libv4l
    dde-api
  ] ++ (with gst_all_1 ; [
    gstreamer.dev
    gst-plugins-base
  ]);

  NIX_CFLAGS_COMPILE = [
    "-I${gst_all_1.gstreamer.dev}/include/gstreamer-1.0"
    "-I${gst_all_1.gst-plugins-base.dev}/include/gstreamer-1.0"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${gstPluginPath}"
  ];

  patches = [
    ./0001-fix-libusb-import.patch
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/deepin-camera/commit/4679e5e00c7eb21eabf7c7bced0d0b0d196f0eba.patch";
      sha256 = "sha256-5hn6oFgtLS19Fg/F2q7ExRFN6QVPV1/43XyB1yyjshg=";
    })
    (fetchpatch {
      name = "fix_missing_include_in_windowstatethread_h";
      url = "https://github.com/linuxdeepin/deepin-camera/commit/9dfc1d18275510a0ed2c96cd4e07933989270ae7.patch";
      sha256 = "sha256-JGDaPAQciw/A1RG5Fc+ttDsa7XBlwAdQy85MRYWZA3o=";
    })
  ];

  fixLoadLibPatch = ''
    substituteInPlace src/src/mainwindow.cpp \
      --replace 'libPath("libavcodec.so")'            'QString("${ffmpeg.out}/lib/libavcodec.so")' \
      --replace 'libPath("libavformat.so")'           'QString("${ffmpeg.out}/lib/libavformat.so")' \
      --replace 'libPath("libavutil.so")'             'QString("${ffmpeg.out}/lib/libavutil.so")' \
      --replace 'libPath("libudev.so")'               'QString("${lib.getLib systemd}/lib/libudev.so")' \
      --replace 'libPath("libusb-1.0.so")'            'QString("${libusb1.out}/lib/libusb-1.0.so")' \
      --replace 'libPath("libportaudio.so")'          'QString("${portaudio.out}/lib/libportaudio.so")' \
      --replace 'libPath("libv4l2.so")'               'QString("${libv4l.out}/lib/libv4l2.so")' \
      --replace 'libPath("libffmpegthumbnailer.so")'  'QString("${ffmpegthumbnailer.out}/lib/libffmpegthumbnailer.so")' \
      --replace 'libPath("libswscale.so")'            'QString("${ffmpeg.out}/lib/libswscale.so")' \
      --replace 'libPath("libswresample.so")'         'QString("${ffmpeg.out}/lib/libswresample.so")'
  '';

  fixLurDirPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace "/usr/share/libimagevisualresult/filter_cube" "${image-editor}/share/libimagevisualresult/filter_cube"
  '';

  # qtchooser: /usr/bin/qdbus
  postPatch = fixLoadLibPatch + fixLurDirPatch + ''
    substituteInPlace src/com.deepin.Camera.service \
      --replace "/usr/bin/qdbus" "qdbus" \
      --replace "/usr/share/applications/deepin-camera.desktop" "$out/share/applications/deepin-camera.desktop"
  '';

  cmakeFlags = [ "-DVERSION=${version}" ];

  meta = with lib; {
    description = "Tool to view camera, take photo and video";
    homepage = "https://github.com/linuxdeepin/deepin-camera";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
