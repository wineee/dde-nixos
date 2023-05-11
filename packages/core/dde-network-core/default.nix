{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, cmake
, qttools
, pkg-config
, wrapQtAppsHook
, qtbase
, qtsvg
, dtkwidget
, dde-dock
, dde-control-center
, dde-session-shell
, networkmanager-qt
, glib
, gtest
}:

stdenv.mkDerivation rec {
  pname = "dde-network-core";
  version = "2.0.7.999";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "980db32ffaf916dbde7f775e3a916de6dc820cb0";
    sha256 = "sha256-oGymFAKCvTG+AxI0EkccxC9n+zc/yPSo2z8uIuGENtc=";
  };

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
    qtbase
    qtsvg
    dtkwidget
    dde-dock
    dde-control-center
    dde-session-shell
    networkmanager-qt
    glib
    gtest
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
  ];

  strictDeps = true;

  meta = with lib; {
    description = "DDE network library framework";
    homepage = "https://github.com/linuxdeepin/dde-network-core";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
