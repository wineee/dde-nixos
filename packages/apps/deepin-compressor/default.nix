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
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-compressor";
  version = "5.12.5";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-8Qp7Y3HQtHFJzjabXtg8z6J0d+fm/Zv86phlM6aKvAs=";
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
    ./0001-support-use-DCMAKE_INSTALL_PREFIX-flag.patch
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
