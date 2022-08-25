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
, qtmultimedia
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
      --replace 'libPath("libmpv.so.1")'              '"${mpv}/lib/libmpv.so.1"' \
      --replace 'libPath("libgstreamer-1.0.so")'      '"${gst_all_1.gstreamer.out}/lib/libgstreamer-1.0.so"' \
      --replace 'libPath("libgstpbutils-1.0.so")'     '"${gst_all_1.gst-plugins-base.out}/lib/libgstpbutils-1.0.so"'

  '' + lib.optionalString cudaSupport '' 
  
  '';
  ### TODO src/backends/mpv/mpv_proxy.cpp libgpuinfo.so

in
stdenv.mkDerivation rec {
  pname = "deepin-movie-reborn";
  version = "5.10.8";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-tBUeYbsJDwuzcOt89nMeP+taZPz4lb27qEQjCxZsMck=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/deepin-movie-reborn/commit/15627ec622f8da9445fd25d2775a9b0f67618f07.patch";
      sha256 = "sha256-p3kJE7lSeqasLSswVOj91CFRZk8kRekT13ZAGKenwvU=";
    })
    (fetchpatch {
      name = "chore: dont use </usr/include/linux/cdrom.h>";
      url = "https://github.com/linuxdeepin/deepin-movie-reborn/commit/2afc63541589adab8b0c8c48e290f03535ec2996.patch";
      sha256 = "sha256-Q9dv5L5sUGeuvNxF8ypQlZuZVuU4NIR/8d8EyP/Q5wk=";
    })
  ];

  fixLoadLibPatch = lib.concatMapStrings replaceLibPath [
    "src/backends/mpv/mpv_proxy.cpp"
    "src/common/hwdec_probe.cpp"
    "src/common/thumbnail_worker.cpp"
    "src/common/platform/platform_thumbnail_worker.cpp"
    "src/libdmr/gstutils.cpp"
    "src/libdmr/filefilter.cpp"
    "src/libdmr/playlist_model.cpp"
    "src/widgets/toolbox_proxy.cpp"
    "src/widgets/platform/platform_toolbox_proxy.cpp"
    "src/backends/mpv/mpv_glwidget.cpp"
  ];

  postPatch = fixLoadLibPatch;

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
    qtmultimedia
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

  qtWrapperArgs = [ 
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix XDG_DATA_DIRS : ${placeholder "out"}/share/gsettings-schemas/${pname}-${version}"
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${gst_all_1.gstreamer.dev}/include/gstreamer-1.0"
    "-I${gst_all_1.gst-plugins-base.dev}/include/gstreamer-1.0"
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
    "-D_LIBMPR_=NO"
  ];

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
  '';

  meta = with lib; {
    description = "Full-featured video player supporting playing local and streaming media in multiple video formats";
    homepage = "https://github.com/linuxdeepin/deepin-movie-reborn";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
