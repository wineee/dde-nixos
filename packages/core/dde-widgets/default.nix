{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, wrapQtAppsHook
, dde-qt-dbus-factory
, qtbase
, qtx11extras
, dtkwidget
, tzdata
, fetchpatch
, gtest
}:

stdenv.mkDerivation rec {
  pname = "dde-widgets";
  version = "6.0.12.999";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "42dd6566e3f2a010eba3f817afa816b726d9de6a";
    sha256 = "sha256-I/DSGVOJ+fJRomfDxhaxGjWBTKZIgTS7fVIFqP087ik=";
  };

  patches = [
    ./zone.diff
    ./0001-chore-avoid-use-hardcode-path-in-services.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    dde-qt-dbus-factory
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtx11extras
    dtkwidget
    gtest
  ];

  meta = with lib; {
    description = "Desktop widgets service/implementation for DDE";
    homepage = "https://github.com/linuxdeepin/dde-widgets";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
