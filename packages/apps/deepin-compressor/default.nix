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
  version = "5.12.8+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "2087ff088877c34a60bcb15de2d4f159a2126723";
    sha256 = "sha256-WxawHIdlt2MbiIuEmbe8qIXmJ6MR4+qYSNKTbq9Pe18=";
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

  # qtWrapperArgs = [
  #   "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
  #   "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  # ];

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
