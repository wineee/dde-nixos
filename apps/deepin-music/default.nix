{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtkcommon
, dtkcore
, dtkgui
, dtkwidget
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
}:

stdenv.mkDerivation rec {
  pname = "deepin-music";
  version = "6.2.12";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-9b+apLmtcJJmR67ta00xBwjpugnhkQ8lenJrEWOpyck=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
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

  cmakeFlags = [ "-DVERSION=${version}" ];

  fixIncludePatch = ''
    substituteInPlace src/music-player/CMakeLists.txt \
      --replace "include_directories(/usr/include/vlc)" "include_directories(${libvlc}/include/vlc)" \
      --replace "include_directories(/usr/include/vlc/plugins)" "include_directories(${libvlc}/include/vlc/plugins)"
  '';

  fixInstallPatch = ''
    substituteInPlace src/libmusic-plugin/CMakeLists.txt \
      --replace "/usr/lib/deepin-aiassistant/serivce-plugins)" "$out/lib/deepin-aiassistant/serivce-plugins)"

    substituteInPlace src/music-player/CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX /usr)" "set(CMAKE_INSTALL_PREFIX $out)" \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "$out/share/deepin-manual/manual-assets/application/)"
  '';

  postPatch = fixIncludePatch + fixInstallPatch;

  meta = with lib; {
    description = "Awesome music player with brilliant and tweakful UI Deepin-UI based";
    homepage = "https://github.com/linuxdeepin/deepin-music";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
