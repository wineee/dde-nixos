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
  version = "unstable-2022-12-29";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "6bb381c00deb7427ccb319b5bbc2aeb3290b9c51";
    sha256 = "sha256-DEOSXd+BvCv286KyTsNYlz/1yu86phN4irJNucnj7vk=";
  };

  patches = [
    (fetchpatch {
      name = "disable_dde-dock_preview_notify";
      url = "https://github.com/linuxdeepin/deepin-kwin/commit/29e1de078bbd03e1a1e1d4b9cfd830c0e15dd7cb.patch";
      sha256 = "sha256-0MY4wLBBz/7nk7RS8fELe6kRB4Rn1nZvtb7tTUuzxHs=";
    })
  ];

  postPatch = replaceAll "/usr/bin/dde-dock" "/run/current-system/sw/bin/dde-dock";

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
