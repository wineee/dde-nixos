{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
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
, breeze-qt5
, libinput
, mesa
, lcms2
, xorg
, dtkcore
}:
stdenv.mkDerivation rec {
  pname = "deepin-kwin";
  version = "5.25.3";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-nTWaA7xnw2Q4PwALyr7P4wDyK3WhGVt4NImDjldq3cI=";
  };

  postPatch = ''
    substituteInPlace src/effects/screenshot/screenshotdbusinterface1.cpp \
      --replace 'file.readAll().startsWith(DEFINE_DDE_DOCK_PATH"dde-dock")' 'file.readAll().contains("dde-dock")'

    substituteInPlace src/effects/multitaskview/multitaskview.cpp \
      --replace "/usr/share/backgrounds" "/run/current-system/sw/share/backgrounds" \
      --replace "/usr/share/wallpapers" "/run/current-system/sw/share/wallpapers"
  '';

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
    dtkcore

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

    breeze-qt5
    libinput
    mesa
    lcms2

    xorg.libxcb
    xorg.libXdmcp
    xorg.libXcursor
    xorg.xcbutilcursor
    xorg.libXtst
    xorg.libXScrnSaver
  ];

  cmakeFlags = [
    #"-DKWIN_BUILD_KCMS=OFF"
    "-DKWIN_BUILD_TABBOX=ON"
    #"-DKWIN_BUILD_CMS=OFF"
    "-DKWIN_BUILD_RUNNERS=OFF"
  ];

  meta = with lib; {
    description = "Easy to use, but flexible, composited Window Manager";
    homepage = "https://github.com/linuxdeepin/deepin-kwin";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
