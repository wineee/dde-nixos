{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, wrapQtAppsHook
, qtbase
, dtkcore
, gsettings-qt
, libsecret
, xorg
, systemd
}:

stdenv.mkDerivation rec {
  pname = "dde-session";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-hi81aqvHJVj5InXTteNpGNeCzjOD6Arkyo58v6Z2RXA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    dtkcore
    gsettings-qt
    libsecret
    xorg.libXcursor
    systemd
  ];

  meta = with lib; {
    description = "New deepin session, based on systemd and existing projects";
    homepage = "https://github.com/linuxdeepin/dde-session";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
