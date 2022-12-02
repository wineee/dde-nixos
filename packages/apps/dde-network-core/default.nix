{ stdenv
, lib
, fetchFromGitHub
, replaceAll
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
, pkg-config
, gsettings-qt
, networkmanager-qt
, glib
, pcre
, util-linux
, libselinux
, libsepol
, wrapQtAppsHook
, dbus
, gtest
, qtbase
}:
stdenv.mkDerivation rec {
  pname = "dde-network-core";
  version = "1.0.69";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-IncVvM2tx6+LAg/eLekfnphOvywmaCkC5nkxDXQhmV8=";
  };


  postPatch = replaceAll "/usr/share/applications" "/run/current-system/sw/share/applications"
      + replaceAll "/usr/share/dss-network-plugin" "$out/share/dss-network-plugin"
      + replaceAll "/usr/share/dock-network-plugin" "$out/share/dock-network-plugin";

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
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
    util-linux
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
    description = "DDE network library framework";
    homepage = "https://github.com/linuxdeepin/dde-network-core";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
