{ stdenv
, lib
, getUsrPatchFrom
, fetchFromGitHub
, dtk
, dde-qt-dbus-factory
, deepin-movie-reborn
, qt5integration
, cmake
, qttools
, pkg-config
, gst_all_1
, mpv
, ffmpeg
, ffmpegthumbnailer
, wrapQtAppsHook
, qtbase
, gtest
}:
let
  patchList = {
    "dde-introduction.desktop" = [ ];
    "src/mainwindow.h" = [ ];
    "src/modules/videowidget.cpp" = [ ];
    "src/widgets/bottomnavigation.cpp" = [ ];
  };
  gstPluginPath = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with gst_all_1; [ gstreamer gst-plugins-base gst-plugins-good ]);
in
stdenv.mkDerivation rec {
  pname = "dde-introduction";
  version = "unstable-2022-09-23";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "f7427cabf249ac370f9755f2bf313fb609b9facc";
    sha256 = "sha256-P0Cz54e2Lngze5gkFGTQKgmcuJMyExSrfJDHb8GkeRo=";
  };

  postPatch = getUsrPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    deepin-movie-reborn
    gtest
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${gstPluginPath}"
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ mpv ffmpeg ffmpegthumbnailer gst_all_1.gstreamer gst_all_1.gst-plugins-base ] }"
  ];

  meta = with lib; {
    description = "dde introduction";
    homepage = "https://github.com/linuxdeepin/dde-introduction";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
