{ stdenv
, lib
, fetchFromGitHub
, getPatchFrom
, go
}:

stdenv.mkDerivation rec {
  pname = "dde-wayland-config";
  version = "1.0.10";

  goPackagePath = "github.com/linuxdeepin/dde-wayland-config";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-ZuLSd9BRj+kK2XbFVOG1zTl4i24Cyee66yMvTQ14tNM=";
  };

  patches = [ ./0001-dont-chown-Xdeepin.patch ];

  postPatch = getPatchFrom {
    "Makefile" = [ [ "/usr" "" ] ];
  };

  nativeBuildInputs = [ go ];

  # installPhase = ''
  preConfigure = ''
    export GOCACHE="$TMPDIR/go-cache"
  '';

    
  # '';
  makeFlags = [ "DESTDIR=${placeholder "out"}" ];
  # dontFixup = true;

  meta = with lib; {
    description = "dde-wayland-config provides the wayland settings for the DDE";
    homepage = "https://github.com/linuxdeepin/dde-wayland-config";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
