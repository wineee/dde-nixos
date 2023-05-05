{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, cmake
, qttools
, pkg-config
, wrapQtAppsHook
, dtkwidget
, dde-dock
, dde-control-center
, dde-session-shell
, dde-qt-dbus-factory
, gsettings-qt
, gio-qt
, networkmanager-qt
, glib
, pcre
, util-linux
, libselinux
, libsepol
, dbus
, gtest
, qtbase
}:
stdenv.mkDerivation rec {
  pname = "dde-network-core";
  version = "2.0.7";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-HTF9NhzgFqQxEDugq/GQiYh50VtGwyyADliTpLN2e7E=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/linuxdeepin/dde-network-core/commit/b42d781512d4de0e006ce3beccf16a36b8035f22.patch";
      sha256 = "sha256-aNnVuxFYlO7t5oONwGeL68dWc6emFZ90OtJO9K/TjzE=";
    })
  ];

  postPatch = ''
    substituteInPlace dss-network-plugin/notification/bubbletool.cpp \
      --replace "/usr/share" "/run/current-system/sw/share"
  '';

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    dde-dock
    dde-control-center
    dde-session-shell
    dde-qt-dbus-factory
    gsettings-qt
    gio-qt
    networkmanager-qt
    glib
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
    maintainers = teams.deepin.members;
  };
}