{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
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
, gst_all_1
, systemd
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
    pkgconfig
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
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
    "--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${gstPluginPath}"
  ];

  patches = [
    ./0001-fix-libusb-import.patch
    ./0002-CMakeLists-use-cmake-install-prefix.patch
    (fetchpatch {
      name = "fix_missing_include_in_windowstatethread_h";
      url = "https://github.com/linuxdeepin/deepin-camera/commit/1a1e7d86e44933de46f9e62c1e42953c8c63f794.patch";
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

  postPatch = fixLoadLibPatch + fixLurDirPatch + ''
    substituteInPlace src/com.deepin.Camera.service \
      --replace "/usr/bin/qdbus" "qdbus" \
      --replace "/usr/share/applications/deepin-camera.desktop" "$out/share/applications/deepin-camera.desktop"
  '';
  ## qtchooser: /usr/bin/qdbus

  cmakeFlags = [ "-DVERSION=${version}" ];

  meta = with lib; {
    description = "Tool to view camera, take photo and video";
    homepage = "https://github.com/linuxdeepin/deepin-camera";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
