{ stdenv
, lib
, getPatchFrom
, fetchFromGitHub
, dtk
, dde-qt-dbus-factory
, dde-dock
, dde-control-center
, dde-session-shell
, qt5integration
, qt5platform-plugins
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
}:
let
  # FIXME: cant build 
  patchList = {

  }; 
in stdenv.mkDerivation rec {
  pname = "dde-network-core";
  version = "1.0.45+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "a24e2a10fb8ef276667cfc06e63e28d0250029ab";
    sha256 = "sha256-T23IC6wps+TUgqAppfuiwk2N7zWtpNr7aybwEft3z8A=";
  };

  postPatch = getPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [ 
    dtk
    dde-dock
    dde-control-center
    dde-session-shell
    dde-qt-dbus-factory
    gsettings-qt
    networkmanager-qt.dev
    glib.dev
    pcre
    utillinux
    libselinux
    libsepol
    gtest
  ];

  #NIX_CFLAGS_COMPILE = [ "-I${glib.dev}/include/glib-2.0" ];

  enableParallelBuilding = false;
  cmakeFlags = [ 
    "-DVERSION=${version}" 
  ];

  # qtWrapperArgs = [
  #   "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
  #   "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  # ];

  meta = with lib; {
    description = "dde-network-core";
    homepage = "https://github.com/linuxdeepin/dde-network-core";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
