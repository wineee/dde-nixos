{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, qtmpris
, qtdbusextended
, cmake
, pkgconfig
, qttools
, qtx11extras
, wrapQtAppsHook
, gsettings-qt
, elfutils
, ffmpeg
, ffmpegthumbnailer
, mpv
, xorg
, pcre
, libdvdread
, libdvdnav
, libunwind
, libva
, zstd
, glib
, gst_all_1
, gsettings-desktop-schemas
, wrapGAppsHook
, gtest
, libpulseaudio
, cudaSupport ? false
, cudaPackages
, breakpointHook
, qtbase
}:
let
  replaceLibPath = filePath: ''
    substituteInPlace ${filePath} \
      --replace 'libPath("libavcodec.so")'            '"${ffmpeg.out}/lib/libavcodec.so"' \
      --replace 'libPath("libavformat.so")'           '"${ffmpeg.out}/lib/libavformat.so"' \
      --replace 'libPath("libavutil.so")'             '"${ffmpeg.out}/lib/libavutil.so"' \
      --replace 'libPath("libffmpegthumbnailer.so")'  '"${ffmpegthumbnailer.out}/lib/libffmpegthumbnailer.so"' \
      --replace 'libPath("libmpv.so.1")'              '"${mpv}/lib/libmpv.so.1"'
  '' + lib.optionalString cudaSupport '' 
  '';
  ### TODO src/backends/mpv/mpv_proxy.cpp libgpuinfo.so

in
stdenv.mkDerivation rec {
  pname = "deepin-movie-reborn";
  # version = "5.10.2";
  version = "5.9.14";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    # sha256 = "sha256-247dOKfNq8A3Ngxshy6q9mlgy32kpmpAOS/I2u0Vgzo=";
    sha256 = "sha256-crTAXTuStA3euPvq/h97wzuG+wTz83biqXgvxkERLRg=";
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    qtx11extras
    qtdbusextended
    qtmpris
    gsettings-qt
    elfutils.dev
    ffmpeg
    ffmpegthumbnailer
    xorg.libXtst
    xorg.libXdmcp
    pcre.dev
    libdvdread
    libdvdnav
    libunwind
    libva
    zstd.dev
    mpv
    gsettings-desktop-schemas
    gtest
    xorg.xcbproto
    libpulseaudio
    gst_all_1.gstreamer
  ] ++ lib.optional cudaSupport [ cudaPackages.cudatoolkit ];

  patches = [
    ./fix-build.patch
  ];

  qtWrapperArgs = [ 
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix XDG_DATA_DIRS : ${placeholder "out"}/share/gsettings-schemas/${pname}-${version}"
  ];


  cmakeFlags = [
    "-DVERSION=${version}"
  ];

  fixCodePatch = ''
    substituteInPlace src/common/diskcheckthread.cpp \
      --replace "</usr/include/linux/cdrom.h>" "<linux/cdrom.h>"

    substituteInPlace tests/deepin-movie-platform/CMakeLists.txt \
      --replace "find_package(gui-private)" ""
    substituteInPlace tests/deepin-movie/CMakeLists.txt \
      --replace "find_package(gui-private)" ""
    substituteInPlace src/CMakeLists.txt \
      --replace "find_package(gui-private)" ""
  '';

  fixInstallPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace "/usr/share/glib-2.0/schemas)" "$out/share/glib-2.0/schemas)" \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "$out/share/deepin-manual/manual-assets/application/)"
  '';

  fixLoadLibPatch = lib.concatMapStrings replaceLibPath [
    "src/libdmr/playlist_model.cpp"
    "src/libdmr/filefilter.cpp"
    "src/widgets/platform/platform_toolbox_proxy.cpp"
    "src/common/platform/platform_thumbnail_worker.cpp"
    "src/common/thumbnail_worker.cpp"
    "src/common/hwdec_probe.cpp"
    "src/widgets/toolbox_proxy.cpp"
    "src/backends/mpv/mpv_proxy.cpp"
    "src/backends/mpv/mpv_glwidget.cpp"
    "src/backends/mpv/mpv_glwidget.cpp"
  ];

  fixDevFilesPatch = ''
    substituteInPlace src/libdmr/libdmr.pc.in \
      --replace "prefix=/usr" "prefix=$dev" \
      --replace "@CMAKE_INSTALL_LIBDIR@" "lib" \
      --replace "@PROJECT_VERSION@" "${version}"
  '';

  postPatch = fixCodePatch + fixInstallPatch + fixLoadLibPatch + fixDevFilesPatch;

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
  '';

  postFixup = ''
    ln -sf $out/lib/libdmr.so $dev/lib/libdmr.so
  '';

  meta = with lib; {
    description = "A full-featured video player supporting playing local and streaming media in multiple video formats";
    homepage = "https://github.com/linuxdeepin/deepin-movie-reborn";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
