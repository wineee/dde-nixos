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
, valgrind
, breeze-qt5
, libinput
, mesa
, lcms2
, xorg
, dtkcore
}:
stdenv.mkDerivation rec {
  pname = "deepin-kwin";
  version = "5.24.3-deepin.1.9";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "2fc8385435984f90eebf059a973a5a298ec49d58";
    sha256 = "sha256-oD0RM9/NdGQ7ErP8siJiYqN3lMEsIa2DDMpwJgk4PBE=";
  };

  patches = [
    (fetchpatch {
      name = "fix: deepin-wm-dbus missing install dir";
      url = "https://github.com/linuxdeepin/deepin-kwin/commit/91ced854fc3cdd71d836fbbb52ad91b03ba69ed0.patch";
      sha256 = "sha256-6AeyRY5ZbgJIBWoBoBMfOXJbY2vAeCkwjbkEKari5Ko=";
    })
  ];

  postPatch = ''
    substituteInPlace src/effects/screenshot/screenshotdbusinterface1.cpp \
      --replace 'file.readAll().startsWith(DEFINE_DDE_DOCK_PATH"dde-dock")' 'file.readAll().contains("dde-dock")'

    substituteInPlace deepin-wm-dbus/deepinwmfaker.cpp \
      --replace "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"

    substituteInPlace deepin-wm-dbus/deepinwmfaker.cpp src/effects/multitaskview/multitaskview.cpp \
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

  # cmakeFlags = [
  #   "-DKWIN_BUILD_KCMS=OFF"
  #   "-DKWIN_BUILD_TABBOX=ON"
  #   "-DKWIN_BUILD_CMS=OFF"
  #   "-DKWIN_BUILD_RUNNERS=OFF"
  # ];

  meta = with lib; {
    description = "Easy to use, but flexible, composited Window Manager";
    homepage = "https://github.com/linuxdeepin/deepin-kwin";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
