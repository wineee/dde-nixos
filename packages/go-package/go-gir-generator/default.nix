{ stdenv
, lib
, fetchFromGitHub
, go-lib
, go
, pkgconfig
, libgudev
, gobject-introspection
}:

stdenv.mkDerivation rec {
  pname = "go-gir-generator";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-29+j0vznfZhoHvmhvDkgfddskwLvumHZVh+PKtg5pWg=";
  };

  nativeBuildInputs = [
    pkgconfig
    go
  ];

  buildInputs = [
    gobject-introspection
    libgudev
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "GOCACHE=$(TMPDIR)/go-cache"
  ];

  meta = with lib; {
    description = "Generate static golang bindings for GObject";
    homepage = "https://github.com/linuxdeepin/go-gir-generator";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
