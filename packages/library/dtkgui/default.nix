{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, pkg-config
, cmake
, qttools
, doxygen
, wrapQtAppsHook
, librsvg
, lxqt
, dtkcore
, qtbase
, qtimageformats
, freeimage
, libraw
}:

stdenv.mkDerivation rec {
  pname = "dtkgui";
  version = "5.6.12";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-sYJWa4D2BMR/jriVdpDjIFd6e1hC4ttuTBM9oW7TJ6c=";
  };

  outputs = [ "out" "doc" ];

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
    doxygen
  ];

  buildInputs = [
    qtbase
    lxqt.libqtxdg
    librsvg
    freeimage
    libraw
  ];

  propagatedBuildInputs = [
    qtimageformats
    dtkcore
  ];

  cmakeFlags = [
    "-DDTK_VERSION=${version}"
    "-DBUILD_DOCS=ON"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
    "-DQCH_INSTALL_DESTINATION=${placeholder "doc"}/${qtbase.qtDocPrefix}"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    #"-DDTK_DISABLE_LIBRSVG=OFF" # librsvg
    #"-DDTK_DISABLE_LIBXDG=OFF" # libqtxdg
    #"-DDTK_DISABLE_EX_IMAGE_FORMAT=OFF" # freeimage
  ];

  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${qtbase.bin}/${qtbase.qtPluginPrefix}
  '';

  meta = with lib; {
    description = "Deepin Toolkit, gui module for DDE look and feel";
    homepage = "https://github.com/linuxdeepin/dtkgui";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
