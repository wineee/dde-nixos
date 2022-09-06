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
  version = "5.0.8";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-wN8mhddqqzYXkT6rRWsHVCWzaG2uRcF2iiFHlZx2LfY=";
  };

  nativeBuildInputs = [
    qmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [ libisoburn ];

  qmakeFlags = [ "VERSION=${version}" ];

  meta = with lib; {
    description = "A libisoburn wrapper class for Qt";
    homepage = "https://github.com/linuxdeepin/disomaster";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
} 
