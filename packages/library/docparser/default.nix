{ stdenv
, lib
, fetchFromGitHub
, pkgconfig
, qmake
, qttools
, wrapQtAppsHook
, poppler
}:

stdenv.mkDerivation rec {
  pname = "docparser";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-abHA44WXE5z1gTiwsxpY/p7d88DQkD7PK1Bun8F9TlM=";
  };

  nativeBuildInputs = [
    qmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [ poppler ];

  meta = with lib; {
    description = "A document parser library ported from document2html";
    homepage = "https://github.com/linuxdeepin/docparser";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
} 
