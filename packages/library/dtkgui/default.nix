{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, pkgconfig
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
    rev = "798f77411a1d9bf7aeb941e45ff9ac1155d659e0";
    sha256 = "sha256-ANF6VXNAKoT0b0v6mAtuG5pjJQx+X0TFywBiTrCz/9w=";
  };

  patches = [
    (fetchpatch {
      name = "feat: Improve version information";
      url = "https://github.com/linuxdeepin/dtkgui/commit/b6e6f17ddb58abfd3b9e33898afe1f69b2791a44.patch";
      sha256 = "sha256-UUkSvz2jYinqVulhpvYmZBWqppsXOFJeSHcyQZeSMaE=";
    })
  ];

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
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
