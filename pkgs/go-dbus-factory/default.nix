{ stdenv
, lib
, fetchFromGitHub
, go-lib
, go
}:

stdenv.mkDerivation rec {
  pname = "go-dbus-factory";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-OLdG7LyDMiuqcB7JQqgoDpSmvO7gPJ8hhNjegtc70hU=";
  };

  #nativeBuildInputs = [ go ];
  #buildInputs = [ go-lib ]; 

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  #buildPhase = ''
  #  make bin
  #'';

  meta = with lib; {
    description = "a library containing many useful go routines for things such as glib, gettext, archive, graphic, etc";
    homepage = "https://github.com/linuxdeepin/dde-api";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
