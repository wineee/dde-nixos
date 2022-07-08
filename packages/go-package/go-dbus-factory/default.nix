{ stdenv
, lib
, fetchFromGitHub
, go-lib
, go
}:

stdenv.mkDerivation rec {
  pname = "go-dbus-factory";
  version = "1.10.20";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-gqf3L/ndYNFMHf+ejgSskTXyAmiEg1ysHi8alM8oU0E=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "a library containing many useful go routines for things such as glib, gettext, archive, graphic, etc";
    homepage = "https://github.com/linuxdeepin/dde-api";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
