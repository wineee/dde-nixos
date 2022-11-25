{ stdenv
, stdenvNoCC
, lib
, fetchpatch
, getUsrPatchFrom
, pkg-config
, fetchFromGitHub
, cmake
, kwin
, kwayland
, qtbase
, qttools
, wrapQtAppsHook
, deepin-gettext-tools
, extra-cmake-modules
, dtk
, gsettings-qt
, xorg
, libepoxy
, makeWrapper
}:
let
  patchList = {
  };

in
stdenv.mkDerivation rec {
  pname = "dwayland";
  version = "5.24.3-deepin.1.3";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "";
  };

  patches = [
  ];

  postPatch = getUsrPatchFrom patchList + ''
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
    kwin
    libkwin
    kwayland
    dtk
    gsettings-qt
    xorg.libXdmcp
    libepoxy.dev
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${kwayland.dev}/include/KF5"
  ];

  cmakeFlags = [
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
