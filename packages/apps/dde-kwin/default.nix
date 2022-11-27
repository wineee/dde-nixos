{ stdenv
, lib
, replaceAll
, pkg-config
, fetchFromGitHub
, cmake
, kwayland
, qtbase
, qttools
, qtx11extras
, wrapQtAppsHook
, deepin-gettext-tools
, extra-cmake-modules
, dtk
, gsettings-qt
, xorg
, libepoxy
, makeWrapper
, deepin-kwin
, kdecoration
, kconfig
, kwindowsystem
, kglobalaccel
}:
stdenv.mkDerivation rec {
  pname = "dde-kwin";
  version = "5.5.22";

  src = fetchFromGitHub {
    owner = "wineee";
    repo = pname;
    rev = "54b63c1285bc54108796df2ce708cb1b6295b7f0";
    sha256 = "sha256-l7YeCBilSFLH7fPU7ClkaWDf55lXTNunsUCZHo+x5p8=";
  };

  postPatch = replaceAll "/usr/include/KWaylandServer" "${kwayland.dev}/include/KWaylandServer"
    + replaceAll "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"
    + replaceAll "/usr/share/backgrounds" "/run/current-system/sw/share/backgrounds"
    + replaceAll "/usr/share/wallpapers" "/run/current-system/sw/share/wallpapers"
  + ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    cmake
    qttools
    deepin-gettext-tools
    extra-cmake-modules
    pkg-config
    wrapQtAppsHook
    makeWrapper
  ];

  buildInputs = [
    deepin-kwin
    kwayland
    kdecoration
    kconfig
    kwindowsystem
    kglobalaccel

    dtk
    qtx11extras
    gsettings-qt
    
    xorg.libXdmcp
    libepoxy.dev
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${kwayland.dev}/include/KF5"
  ];

  cmakeFlags = [
    "-DPROJECT_VERSION=${version}"
    #"-DKWIN_VERSION=${kwin.version}"
    #"-DPLUGIN_INSTALL_PATH=${placeholder "out"}/lib/plugins/platforms"
    #"-DKWIN_LIBRARY_PATH=${libkwin}/lib"
    "-DQT_INSTALL_PLUGINS=${placeholder "out"}/${qtbase.qtPluginPrefix}"

    #"-DUSE_WINDOW_TOOL=OFF"
    #"-DENABLE_BUILTIN_BLUR=OFF" 
    #"-DENABLE_KDECORATION=ON"
    #"-DENABLE_BUILTIN_MULTITASKING=OFF"
    #"-DENABLE_BUILTIN_BLACK_SCREEN=OFF"
    #"-DUSE_DEEPIN_WAYLAND=OFF"
    #"-DENABLE_BUILTIN_SCISSOR_WINDOW=ON"
  ];

  postFixup = ''
    wrapProgram $out/bin/kwin_no_scale \
      --set QT_QPA_PLATFORM_PLUGIN_PATH "${placeholder "out"}/${qtbase.qtPluginPrefix}"
  '';
  ## FIXME: why cann't use --prefix

  meta = with lib; {
    description = "KWin configuration for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-kwin";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
