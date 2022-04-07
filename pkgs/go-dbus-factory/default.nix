{ stdenv
, lib
, fetchFromGitHub
, go-lib
, go
}:

stdenv.mkDerivation rec {
  pname = "go-dbus-factory";
  version = "unstable-2022-01-17";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "fab97cf936d78150ba011a7aeb8e24993ddca37d";
    sha256 = "sha256-KvFX+l2M6wHa+l6bOEKswCTcBYqtbMl/IIxGuu0PFcU=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "a library containing many useful go routines for things such as glib, gettext, archive, graphic, etc";
    homepage = "https://github.com/linuxdeepin/dde-api";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
