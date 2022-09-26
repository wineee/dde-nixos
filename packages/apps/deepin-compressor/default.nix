{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, qt5integration
, qt5platform-plugins
, udisks2-qt5
, cmake
, qttools
, pkg-config
, kcodecs
, karchive
, wrapQtAppsHook
, minizip
, libzip
, libarchive
, qtbase
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

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/deepin-compressor/commit/cc1dfcbff84f712b97b54948fb75fcd64edde28d.patch";
      sha256 = "sha256-6vxkqm+shbMbl1UZF5ShrteYr6cEp6MyvqEuPfvmrFg=";
    })
  ];

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
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
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
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
