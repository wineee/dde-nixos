{ stdenv
, lib
, fetchFromGitHub
, go
, glib
, xorg
, gdk-pixbuf
, pulseaudio
, mobile-broadband-provider-info
}:

stdenv.mkDerivation rec {
  pname = "go-lib";
  version = "5.8.26";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-92sXZWX0PoZX6i/I8wAobL5pIzyqUG903SZCuu4wjtk=";
  };

  installPhase = ''
    mkdir -p $out/share/gocode/src/github.com/linuxdeepin/go-lib
    cp -a * $out/share/gocode/src/github.com/linuxdeepin/go-lib
    rm -r $out/share/gocode/src/github.com/linuxdeepin/go-lib/debian
  '';

  propagatedBuildInputs = [
    go
    glib
    xorg.libX11
    gdk-pixbuf
    pulseaudio
    mobile-broadband-provider-info
  ];

  meta = with lib; {
    description = "a library containing many useful go routines for things such as glib, gettext, archive, graphic, etc";
    homepage = "https://github.com/linuxdeepin/go-lib";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
