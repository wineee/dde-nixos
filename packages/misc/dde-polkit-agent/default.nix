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
, polkit-qt
}:

stdenv.mkDerivation rec {
  pname = "dde-polkit-agent";
  version = "5.5.19";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-jVzwzTejaFgmTzkEEVoLXWdPX43EgwTC90dUurH57q8=";
  };

  patches = [
    ./fix_in_non_deepin.patch
  ];

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
    polkit-qt
  ];

  postFixup = ''
    wrapQtApp $out/lib/polkit-1-dde/dde-polkit-agent
  '';

  meta = with lib; {
    description = "PolicyKit agent for Deepin Desktop Environment";
    homepage = https://github.com/linuxdeepin/dde-polkit-agent;
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
