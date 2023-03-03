{ stdenv
, lib
, fetchFromGitHub
, qmake
, pkg-config
, libchardet
, lcms2
, openjpeg
}:

stdenv.mkDerivation rec {
  pname = "deepin-pdfium";
  version = "2023-03-03";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "8ac2a9d802a7ce7c79d2f17c0e912fecb4303c12";
    sha256 = "sha256-xM56ufTgRxbwdWF8xeN7szWLjARIi7mcS9KntY8oQGE=";
  };

  nativeBuildInputs = [
    qmake
    pkg-config
  ];

  dontWrapQtApps = true;

  buildInputs = [
    libchardet
    lcms2
    openjpeg
  ];

  meta = with lib; {
    description = "development library for pdf on Deepin";
    homepage = "https://github.com/linuxdeepin/deepin-pdfium";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}