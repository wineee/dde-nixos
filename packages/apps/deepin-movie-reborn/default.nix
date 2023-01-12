{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, replaceAll
, dtk
, qt5integration
, dde-qt-dbus-factory
, qtmpris
, qtdbusextended
, cmake
, pkg-config
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
  gstPluginPath = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with gst_all_1; [ gstreamer gst-plugins-base gst-plugins-good ]);
in
stdenv.mkDerivation rec {
  pname = "deepin-movie-reborn";
  version = "5.10.17";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "bce4cdf08b8e786f06c5cc32c657d873be6c5346";
    sha256 = "sha256-XlnHSiGV02WQUCLgeidY1tCR8WjO1IGuQUOWwMT7ru8";
  };

  patches = [
    (fetchpatch {
      name = "chore: dont use </usr/include/linux/cdrom.h>";
      url = "https://github.com/linuxdeepin/deepin-movie-reborn/commit/2afc63541589adab8b0c8c48e290f03535ec2996.patch";
      sha256 = "sha256-Q9dv5L5sUGeuvNxF8ypQlZuZVuU4NIR/8d8EyP/Q5wk=";
    })
    ./0001-fix-lib-path.patch
  ];

  # postPatch = ''
  #  substituteInPlace CMakeLists.txt --replace "add_subdirectory(examples/test)" " "
  # '';

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    qtdbusextended
    qtmpris
    gsettings-qt
    elfutils.dev
    ffmpeg
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
  ] ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
  ]) ++ lib.optional cudaSupport [ cudaPackages.cudatoolkit ];

  propagatedBuildInputs = [
    qtmultimedia
    qtx11extras
    ffmpegthumbnailer
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix XDG_DATA_DIRS : ${placeholder "out"}/share/gsettings-schemas/${pname}-${version}"
    "--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${gstPluginPath}"
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ mpv ffmpeg ffmpegthumbnailer gst_all_1.gstreamer gst_all_1.gst-plugins-base ]}"
    (lib.optionalString cudaSupport "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ cudaPackages.cudatoolkit ]}")
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${gst_all_1.gstreamer.dev}/include/gstreamer-1.0"
    "-I${gst_all_1.gst-plugins-base.dev}/include/gstreamer-1.0"
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
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
