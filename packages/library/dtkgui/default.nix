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
  version = "5.6.1.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "999b6f5fc5588b819a0fde8bc44dcd0f84177f71";
    sha256 = "sha256-5P8xuDj3+bDE8vqwLRbouj3n+DWPaLVRiJaTYD64Iu0=";
  };

  patches = [
    (fetchpatch {
      name = "feat: Improve version information";
      url = "https://github.com/linuxdeepin/dtkgui/commit/03a732b73a07422a26e718c16135cc56ea8603f0.patch";
      sha256 = "sha256-nL7Ayrb2g16UkJF/x/L1NVI4E9bAn3lBibFNbiK+OP4=";
    })
  ];

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
