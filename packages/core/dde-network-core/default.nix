{ stdenv
, lib
, fetchFromGitHub
, replaceAll
, dtkwidget
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
  version = "1.1.8";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-ysmdB9CT7mhN/0r8CRT4FQsK12HkhjbezGXwWiNScqg=";
  };

  postPatch = replaceAll "/usr/share/applications" "/run/current-system/sw/share/applications"
    + replaceAll "/usr/share/dss-network-plugin" "$out/share/dss-network-plugin"
    + replaceAll "/usr/share/dock-network-plugin" "$out/share/dock-network-plugin"
    + replaceAll "/usr/share/dcc-network-plugin" "$out/share/dcc-network-plugin";

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    qt5integration
    qt5platform-plugins
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

  meta = with lib; {
    description = "DDE network library framework";
    homepage = "https://github.com/linuxdeepin/dde-network-core";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
