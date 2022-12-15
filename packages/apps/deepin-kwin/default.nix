{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, wayland
, dwayland
, qtbase
, qttools
, qtx11extras
, wrapQtAppsHook
, extra-cmake-modules
, gsettings-qt
, libepoxy
, kconfig
, kconfigwidgets
, kcoreaddons
, kcrash
, kdbusaddons
, kiconthemes
, kglobalaccel
, kidletime
, knotifications
, kpackage
, plasma-framework
, kcmutils
, knewstuff
, kdecoration
, kscreenlocker
, valgrind
, breeze-qt5
, libinput
, mesa
, lcms2
, xorg
}:
stdenv.mkDerivation rec {
  pname = "deepin-kwin";
  version = "unstable-2022-11-25";

  src = fetchFromGitHub {
    owner = "justforlxz";
    repo = pname;
    rev = "2e4eb120de6eef57f3d4ceab32a02fc6eabdd49e";
    sha256 = "sha256-ttn0CxdzbUHZgZNfAgxKT535vGnrqbUPZC/n8yp48cA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    extra-cmake-modules
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qttools
    qtx11extras
    wayland
    dwayland
    libepoxy
    gsettings-qt

    kconfig
    kconfigwidgets
    kcoreaddons
    kcrash
    kdbusaddons
    kiconthemes

    kglobalaccel
    kidletime
    knotifications
    kpackage
    plasma-framework
    kcmutils
    knewstuff
    kdecoration
    kscreenlocker

    valgrind
    breeze-qt5
    libinput
    mesa
    lcms2

    xorg.libxcb
    xorg.libXdmcp
    xorg.libXcursor
    xorg.xcbutilcursor
    xorg.libXtst
  ];

  cmakeFlags = [
    "-DKWIN_BUILD_KCMS=OFF"
    "-DKWIN_BUILD_TABBOX=ON"
    "-DKWIN_BUILD_CMS=OFF"
    "-DKWIN_BUILD_RUNNERS=OFF"
  ];

  meta = with lib; {
    description = "Easy to use, but flexible, composited Window Manager";
    homepage = "https://github.com/linuxdeepin/deepin-kwin";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
