{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, dtk
, qt5integration
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
  version = "5.12.9";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-HJDtUvXUT94G4WqrK92UMmijnuC4ApkKHU3yE3rOKHQ=";
  };

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

  postPatch = fixPluginLoadPatch + getUsrPatchFrom {
    "src/desktop/${pname}.desktop" = [ ];
  };

  meta = with lib; {
    description = "A fast and lightweight application for creating and extracting archives";
    homepage = "https://github.com/linuxdeepin/deepin-compressor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
