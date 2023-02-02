{ stdenv
, lib
, replaceAll
, pkg-config
, fetchFromGitHub
, cmake
, qtbase
, qttools
, qtx11extras
, wrapQtAppsHook
, deepin-gettext-tools
, extra-cmake-modules
, dtkwidget
, gsettings-qt
, xorg
, libepoxy
, makeWrapper
, deepin-kwin
, kdecoration
, kconfig
, kwindowsystem
, kglobalaccel
, dtkcore
}:
stdenv.mkDerivation rec {
  pname = "dde-kwin";
  version = "5.6.5";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "b5c00527b86f773595c786c8015d60f8be3a681b";
    sha256 = "sha256-qXN9AwjLnqO5BpnrX5PaSCKZ6ff874r08ubCMM272tA=";
  };

  postPatch = replaceAll "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"
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
    kdecoration
    kconfig
    kwindowsystem
    kglobalaccel
    dtkwidget
    qtx11extras
    gsettings-qt
    xorg.libXdmcp
    libepoxy.dev
  ];

  # NIX_CFLAGS_COMPILE = [
  #   "-I${kwayland.dev}/include/KF5"
  # ];

  cmakeFlags = [
    "-DPROJECT_VERSION=${version}"
    "-DQT_INSTALL_PLUGINS=${placeholder "out"}/${qtbase.qtPluginPrefix}"
  ];

  # kwin_no_scale is a sh script
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
