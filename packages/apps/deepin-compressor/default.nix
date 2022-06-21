{ stdenv
, lib
, fetchFromGitHub
, dtk
, qt5integration
, qt5platform-plugins
, udisks2-qt5
, cmake
, qttools
, pkgconfig
, kcodecs
, karchive
, wrapQtAppsHook
, minizip
, libzip
, libarchive
}:

stdenv.mkDerivation rec {
  pname = "deepin-compressor";
  version = "5.12.6";

  src = fetchFromGitHub {
    owner = "wineee";
    repo = pname;
    rev = "75f3d3fbdd3291613acd934472ccdccb1cb44daf";
    sha256 = "sha256-8Bji+7ZHYVyQmMptm24tUuOSfWzssmHKiNka6ZBxRrQ=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    udisks2-qt5
    kcodecs
    karchive
    minizip
    libzip
    libarchive
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
    "-DUSE_TEST=OFF"
  ];

  fixPluginLoadPatch = ''
    substituteInPlace src/source/common/pluginmanager.cpp \
      --replace "/usr/lib/" "$out/lib/"
  '';

  postPatch = fixPluginLoadPatch;

  meta = with lib; {
    description = "A fast and lightweight application for creating and extracting archives";
    homepage = "https://github.com/linuxdeepin/deepin-compressor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
