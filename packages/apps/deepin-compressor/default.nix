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
, pkgconfig
, kcodecs
, karchive
, wrapQtAppsHook
, minizip
, libzip
, libarchive
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-compressor";
  version = "unstable-2022-02-20";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "f38fbcc1d6db4de2c15450be163aa734b85eeb5d";
    sha256 = "sha256-im1TXsuoLDM4BYfNpvg8yvARykuaIWnytmjzPMHqRrU=";
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
    gtest
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
    "-DLIBRARY_OUTPUT_PATH=${placeholder "out"}/lib"
    "-DEXECUTABLE_OUTPUT_PATH=${placeholder "out"}/bin"
    "-DHFILES_OUTPUT_PATH=${placeholder "out"}/include"
  ];

  patches = [
    (fetchpatch {
      url = "https://github.com/linuxdeepin/deepin-compressor/commit/c0a371d76f69bc92aedcdc0d49a590617399ce44.patch";
      sha256 = "sha256-iD+QkhncKaCJ6z1ZR/1OqYQADaFdvo3HZNkybFcHwPg=";
      name = "support_use_DCMAKE_INSTALL_PREFIX_flag_patch";
    })
  ];

  fixPluginLoadPatch = ''
    substituteInPlace src/source/common/pluginmanager.cpp \
      --replace "/usr/lib/" "$out/lib/"
  '';

  fixInstallPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace "/usr/share/applications/context-menus/)" "$out/share/applications/context-menus/)" \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "$out/share/deepin-manual/manual-assets/application/)"
    substituteInPlace CMakeLists.txt \
      --replace "/usr/lib/deepin-compressor/plugins" "$out/lib/deepin-compressor/plugins"
  '';

  postPatch = fixPluginLoadPatch + fixInstallPatch;

  meta = with lib; {
    description = "A fast and lightweight application for creating and extracting archives";
    homepage = "https://github.com/linuxdeepin/deepin-compressor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
