{ stdenv
, lib
, fetchFromGitHub
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
}:
stdenv.mkDerivation rec {
  pname = "dde-network-core";
  version = "1.0.64";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-jCJ7G1rKAxPAgX+nfuIkBS2BZzuFe2CxUQukJl6rocE=";
  };

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
    gio-qt
    networkmanager-qt.dev
    glib.dev
    pcre
    utillinux
    libselinux
    libsepol
    gtest
  ];

  cmakeFlags = [ 
    "-DVERSION=${version}"
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
