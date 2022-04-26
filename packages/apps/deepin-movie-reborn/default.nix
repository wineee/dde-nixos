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
, ffmpeg
, ffmpegthumbnailer
, mpv
, xorg
, libdvdread
, libdvdnav
, libva
, glib
, gsettings-desktop-schemas
, wrapGAppsHook
, gtest
, libpulseaudio
, cudaSupport ? false, cudaPackages
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
  version = "5.9.14";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-crTAXTuStA3euPvq/h97wzuG+wTz83biqXgvxkERLRg=";
  };

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
    ffmpeg
    ffmpegthumbnailer
    xorg.libXtst
    xorg.libXdmcp
    libdvdread
    libdvdnav
    libva
    mpv
    gsettings-desktop-schemas
    gtest
    xorg.xcbproto
    libpulseaudio
  ] ++ lib.optional cudaSupport [ cudaPackages.cudatoolkit ];

  patches = [
    ./fix-build.patch
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
    "--prefix XDG_DATA_DIRS : ${placeholder "out"}/share/gsettings-schemas/${pname}-${version}"
  ];

  #makeFlags =  [ "CFLAGS+=-Og" "CFLAGS+=-ggdb" ];

  cmakeFlags = [ 
    "-DVERSION=${version}"
    #"-DCMAKE_BUILD_TYPE=Debug"
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

  postPatch = fixCodePatch + fixInstallPatch + fixLoadLibPatch;

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
  '';

  meta = with lib; {
    description = "A full-featured video player supporting playing local and streaming media in multiple video formats";
    homepage = "https://github.com/linuxdeepin/deepin-movie-reborn";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
