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
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "deepin-music";
  version = "6.2.18";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-rPexPFZK0bnDNshzhKdGvuhNaVvZNPnB3WesKLfx7Gg=";
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
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
  ];

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/deepin-music/commit/3762b6e1e7f8bb4be1ccf639ad270c8570e9933c.patch";
      sha256 = "sha256-iVHQLPCig/VhIIJF6t4jebNWrEP6DDfLfqslkD7+KKQ=";
    })
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

  fixDesktopPatch = ''
    substituteInPlace src/music-player/data/deepin-music.desktop \
      --replace "/usr/bin/deepin-music" "$out/bin/deepin-music"
  '';

  postPatch = fixIncludePatch + fixLoadLibPatch + fixDesktopPatch;

  meta = with lib; {
    description = "Awesome music player with brilliant and tweakful UI Deepin-UI based";
    homepage = "https://github.com/linuxdeepin/deepin-music";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
