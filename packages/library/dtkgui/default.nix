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
, buildDocs ? true
}:

stdenv.mkDerivation rec {
  pname = "dtkgui";
  version = "5.6.11";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-b1PtaH5sEAjpi50mSczxiZIRL++ibNmIFgOC3L1fBhk=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ] ++ lib.optional buildDocs [
    doxygen
    #qttools.dev
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
    "-DDVERSION=${version}"
    "-DBUILD_DOCS=ON"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
    "-DQCH_INSTALL_DESTINATION=${qtbase.qtDocPrefix}"
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
