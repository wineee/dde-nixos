{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, pkg-config
, cmake
, qttools
, wrapQtAppsHook
, librsvg
, lxqt
, dtkcore
, dtkcommon
, qtimageformats
, freeimage
, libraw
}:

stdenv.mkDerivation rec {
  pname = "dtkgui";
  version = "5.6.8";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-6b4EQq1b7X9/lc644qnpY3QYZ01SE+EV07aDjY5ewvY=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
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
    "-DBUILD_DOCS=OFF"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DDTK_DISABLE_LIBRSVG=ON" # librsvg
    "-DDTK_DISABLE_LIBXDG=OFF" # libqtxdg
    "-DDTK_DISABLE_EX_IMAGE_FORMAT=OFF" # freeimage
  ];

  meta = with lib; {
    description = "Deepin Toolkit, gui module for DDE look and feel";
    homepage = "https://github.com/linuxdeepin/dtkgui";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
