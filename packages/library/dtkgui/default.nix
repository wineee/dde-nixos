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
  version = "5.6.5";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-DeusmlVaNLaRLYXqsUZu8HcP936LunmlEjyyjJAR0J8=";
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
  ];

  meta = with lib; {
    description = "Deepin Toolkit, gui module for DDE look and feel";
    homepage = "https://github.com/linuxdeepin/dtkgui";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
