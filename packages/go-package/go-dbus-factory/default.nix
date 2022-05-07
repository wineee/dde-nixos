{ stdenv
, lib
, fetchFromGitHub
, go-lib
, go
}:

stdenv.mkDerivation rec {
  pname = "go-dbus-factory";
  version = "1.10.9";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-KvFX+l2M6wHa+l6bOEKswCTcBYqtbMl/IIxGuu0PFcU=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "a library containing many useful go routines for things such as glib, gettext, archive, graphic, etc";
    homepage = "https://github.com/linuxdeepin/dde-api";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
