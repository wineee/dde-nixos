{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, replaceAll
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
  version = "5.24.3-deepin.1.9";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "6bb381c00deb7427ccb319b5bbc2aeb3290b9c51";
    sha256 = "sha256-DEOSXd+BvCv286KyTsNYlz/1yu86phN4irJNucnj7vk=";
  };

  patches = [
    (fetchpatch {
      name = "disable_dde-dock_preview_notify";
      url = "https://github.com/linuxdeepin/deepin-kwin/commit/a874f798b5c3118f3f62d7dd9dfc0322d3cb88ef.patch";
      sha256 = "sha256-ANcQ5HU52A78gOkROfiGOuYSdz+0NOm9KYkkeGLw660=";
    })
  ];

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
    "-DKWIN_BUILD_RUNNERS=OFF"
    "-DDEFINE_DDE_DOCK_PATH=/run/current-system/sw/bin"
  ];

  meta = with lib; {
    description = "Easy to use, but flexible, composited Window Manager";
    homepage = "https://github.com/linuxdeepin/deepin-kwin";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
