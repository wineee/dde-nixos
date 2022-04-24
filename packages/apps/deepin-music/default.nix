{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, udisks2-qt5
, qtmpris
, qtdbusextended
, cmake
, pkgconfig
, qtbase
, qtmultimedia
, qttools
, wrapQtAppsHook
, kcodecs
, ffmpeg
, libvlc
, libcue
, taglib
, gsettings-qt
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-music";
  version = "unstable-2022-04-19";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "9c4c678f0241736b41acf501dbf0a3829e83a004";
    sha256 = "sha256-DZ6feQnbd58H/5IBixrhWCpGmN9YJutP+T6Ne9Rc6qc=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    udisks2-qt5
    qtmpris
    qtdbusextended
    qtmultimedia
    kcodecs
    ffmpeg
    libvlc
    libcue
    taglib
    gsettings-qt
    gtest
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  #makeFlags =  [ "CFLAGS+=-Og" "CFLAGS+=-ggdb" ];

  cmakeFlags = [
    "-DVERSION=${version}"
    #"-DCMAKE_BUILD_TYPE=Debug"
  ];

  fixIncludePatch = ''
    substituteInPlace src/music-player/CMakeLists.txt \
      --replace "include_directories(/usr/include/vlc)" "include_directories(${libvlc}/include/vlc)" \
      --replace "include_directories(/usr/include/vlc/plugins)" "include_directories(${libvlc}/include/vlc/plugins)"
  '';

  fixLoadLibPatch = ''
    substituteInPlace src/music-player/core/vlc/vlcdynamicinstance.cpp \
      --replace 'libPath(libvlccore);'  '"${libvlc}/lib/libvlccore.so";' \
      --replace 'libPath(libvlc);'      '"${libvlc}/lib/libvlc.so";' \
      --replace 'libPath(libcodec);'    '"${ffmpeg.out}/lib/libavcodec.so";' \
      --replace 'libPath(libformate);'  '"${ffmpeg.out}/lib/libavformat.so";'

    substituteInPlace src/libdmusic/ffmpegdynamicinstance.cpp \
      --replace 'libPath(libcodec);'    '"${ffmpeg.out}/lib/libavcodec.so";' \
      --replace 'libPath(libformate);'  '"${ffmpeg.out}/lib/libavformat.so";'
  '';

  fixInstallPatch = ''
    substituteInPlace src/libmusic-plugin/CMakeLists.txt \
      --replace "/usr/lib/deepin-aiassistant/serivce-plugins)" "$out/lib/deepin-aiassistant/serivce-plugins)"

    substituteInPlace src/music-player/CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX /usr)" "set(CMAKE_INSTALL_PREFIX $out)" \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "$out/share/deepin-manual/manual-assets/application/)"
  '';

  postPatch = fixIncludePatch + fixLoadLibPatch + fixInstallPatch;

  meta = with lib; {
    description = "Awesome music player with brilliant and tweakful UI Deepin-UI based";
    homepage = "https://github.com/linuxdeepin/deepin-music";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
