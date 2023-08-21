{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtkwidget
, deepin-ocr-plugin-manager
, qt5platform-plugins
, gio-qt
, udisks2-qt5
, image-editor
, cmake
, pkg-config
, qttools
, wrapQtAppsHook
, libraw
, libexif
, qtbase
, dtkdeclarative
, freeimage
}:

stdenv.mkDerivation rec {
  pname = "deepin-image-viewer";
  version = "6.0.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-YT3wK+ELXjgtsXbkiCjQF0zczQi89tF1kyIQtl9/mMA=";
  };

  patches = [
    #./0001-fix-fhs-path-for-nix.patch
    (fetchpatch {
      name = "fix build with libraw 0.21";
      url = "https://raw.githubusercontent.com/archlinux/svntogit-community/2ff11979704dd7156a7e7c3bae9b30f08894063d/trunk/libraw-0.21.patch";
      sha256 = "sha256-I/w4uiANT8Z8ud/F9WCd3iRHOfplu3fpqnu8ZIs4C+w=";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkdeclarative
    dtkwidget
    deepin-ocr-plugin-manager
    libraw
    freeimage
    qt5platform-plugins
  ];

  cmakeFlags = [ 
    "-DVERSION=${version}" 
    #"-DDDE_OCR_ENABLE=OFF"
  ];

  meta = with lib; {
    description = "An image viewing tool with fashion interface and smooth performance";
    homepage = "https://github.com/linuxdeepin/deepin-image-viewer";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
