{ stdenv
, lib
, fetchFromGitHub
, pkgconfig
, qmake
, qttools
, wrapQtAppsHook
, libisoburn
}:

stdenv.mkDerivation rec {
  pname = "disomaster";
  version = "5.0.7";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-restwLBWza6VI87YlYHH69igrEWbe47DIsnGLcdlHJY=";
  };

  nativeBuildInputs = [
    qmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [ libisoburn ];

  meta = with lib; {
    description = "A libisoburn wrapper class for Qt";
    homepage = "https://github.com/linuxdeepin/libisoburn";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
} 
