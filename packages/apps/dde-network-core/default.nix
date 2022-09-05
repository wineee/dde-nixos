{ stdenv
, lib
, getPatchFrom
, fetchFromGitHub
, fetchpatch
, dtk
, dde-qt-dbus-factory
, dde-dock
, dde-control-center
, dde-session-shell
, qt5integration
, qt5platform-plugins
, gio-qt
, cmake
, qttools
, pkgconfig
, gsettings-qt
, networkmanager-qt
, glib
, pcre
, utillinux
, libselinux
, libsepol
, wrapQtAppsHook
, dbus
, gtest
, qtbase
, breakpointHook
}:
let
  # FIXME: cant build 
  patchList = {

  }; 
in stdenv.mkDerivation rec {
  pname = "dde-network-core";
  version = "1.0.45";

  src = fetchFromGitHub {
    owner = "wineee";
    repo = pname;
    rev = "882da45c0dfbd61909a7b655547e5ab369f8e873";
    sha256 = "sha256-n/kZKAol+GHrcastECU2IyPlJp2oui38EVhxjrowEAw=";
  };

  postPatch = getPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
    breakpointHook
  ];

  buildInputs = [ 
    dtk
    dde-dock
    dde-control-center
    dde-session-shell
    dde-qt-dbus-factory
    gsettings-qt
    gio-qt
    networkmanager-qt.dev
    glib.dev
    pcre
    utillinux
    libselinux
    libsepol
    gtest
  ];

  #NIX_CFLAGS_COMPILE = [ "-I${glib.dev}/include/glib-2.0" ];

  enableParallelBuilding = true;
  cmakeFlags = [ 
    "-DPROJECT_VERSION=${version}"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "dde-network-core";
    homepage = "https://github.com/linuxdeepin/dde-network-core";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
