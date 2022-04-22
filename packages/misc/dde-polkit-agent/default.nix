{ stdenv
, lib
, fetchFromGitHub
, dtkcommon
, dtkcore
, dtkgui
, dtkwidget
, dde-qt-dbus-factory
, pkgconfig
, cmake
, qttools
, wrapQtAppsHook
, polkit-qt-1
}:

stdenv.mkDerivation rec {
  pname = "dde-polkit-agent";
  version = "5.5.7";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-zh1tK9jhEvKWyCcriYFOL2ko9E7nA/6Mte9fJL1b+hA=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
    dde-qt-dbus-factory
    polkit-qt-1
  ];

  patches = [
    ./fix_in_non_deepin.patch
  ];

  meta = with lib; {
    description = "PolicyKit agent for Deepin Desktop Environment";
    homepage = https://github.com/linuxdeepin/dde-polkit-agent;
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
