{ stdenv
, lib
, fetchFromDeepin
, gtk3
, xcursorgen
}:

stdenv.mkDerivation rec {
  pname = "deepin-icon-theme";
  version = "2021.11.24";

  src = fetchFromDeepin { inherit pname; };

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
