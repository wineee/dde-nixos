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
}:

stdenv.mkDerivation rec {
  pname = "dtkgui";
  version = "5.6.1+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "5204f570ef298afd3555edd2e3b718e6423681ac";
    sha256 = "sha256-ioekMkhWZlI7aHc1eSQeL7/wmt7FCs1CFMdpUpN+ywA=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcore
    dtkcommon
    librsvg
    lxqt.libqtxdg
  ];

  cmakeFlags = [ 
    "-DBUILD_DOCS=OFF"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
  ];

  meta = with lib; {
    description = "Deepin Toolkit, gui module for DDE look and feel";
    homepage = "https://github.com/linuxdeepin/dtkgui";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
