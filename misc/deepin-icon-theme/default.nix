{ stdenv
, lib
, fetchFromGitHub
, gtk3
, xcursorgen
}:

stdenv.mkDerivation rec {
  pname = "deepin-icon-theme";
  version = "2021.11.24";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-UC3PbqolcCbVrIEDqMovfJ4oeofMUGJag1A6u7X3Ml8=";
  };

  nativeBuildInputs = [ gtk3 xcursorgen ];

  postPatch = ''
    substituteInPlace Makefile --replace "PREFIX = /usr" "PREFIX = $out"
  '';

  meta = with lib; {
    description = "deepin icon theme";
    homepage = "https://github.com/linuxdeepin/deepin-icon-theme";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
