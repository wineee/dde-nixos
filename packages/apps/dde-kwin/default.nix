{ stdenv
, lib
, replaceAll
, pkg-config
, fetchFromGitHub
, fetchpatch
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
  version = "5.6.5";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "889664378f54b986a21b5297df08f6b6177fed35";
    sha256 = "sha256-6ttr+yG5kvLDi9XAw38Lzb7ODEjgSAgUnHoDtt+eQr4=";
  };

  patches = [
    (fetchpatch {
      name = "use_GNUInstallDirs_set_path";
      url = "https://github.com/linuxdeepin/dde-kwin/commit/941df38899ea219cbc36ab69e47341620fd86229.patch";
      sha256 = "sha256-kw4xu7q+lv6h4EoFi2nSq4QqdHMBKUPCNNnz72/31iI=";
    })
  ];

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
    "-DQT_INSTALL_PLUGINS=${placeholder "out"}/${qtbase.qtPluginPrefix}"
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
