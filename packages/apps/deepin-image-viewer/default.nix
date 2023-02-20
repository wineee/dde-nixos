{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtkwidget
, qt5integration
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
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "1511990072246b553074791705119a388425f3a2";
    sha256 = "sha256-jEggVmDQ5tIepEcbE4RLwqkUjD8+XbWhJ9ZLRadsPaI=";
  };

  patches = [
    #./0001-fix-fhs-path-for-nix.patch
    ./0001-feat-add-build-flag-to-disable-deepin-ocr.patch
    (fetchpatch {
      name = "fix build with libraw 0.21";
      url = "https://raw.githubusercontent.com/archlinux/svntogit-community/2ff11979704dd7156a7e7c3bae9b30f08894063d/trunk/libraw-0.21.patch";
      sha256 = "sha256-I/w4uiANT8Z8ud/F9WCd3iRHOfplu3fpqnu8ZIs4C+w=";
    })
  ];

  postPatch = '' 
    substituteInPlace src/com.deepin.imageViewer.service \
      --replace "/usr/bin/ll-cli run org.deepin.image.viewer --exec deepin-image-viewer" "$out/bin/deepin-image-viewer"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkdeclarative
    dtkwidget
    libraw
    freeimage
  ];

  cmakeFlags = [ 
    "-DVERSION=${version}" 
    "-DDDE_OCR_ENABLE=OFF"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "An image viewing tool with fashion interface and smooth performance";
    homepage = "https://github.com/linuxdeepin/deepin-image-viewer";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
