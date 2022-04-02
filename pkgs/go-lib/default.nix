{ stdenv
, lib
, fetchFromGitHub
, glib
, xorg
, gdk-pixbuf
, pulseaudio
, mobile-broadband-provider-info
}:

stdenv.mkDerivation rec {
  pname = "go-lib";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-9u/dstjsL/hcd+JYYiQnR4S4Jcu6BKxeBgl963jyJc0=";
  };

  buildInputs = [
    glib
    xorg.libX11
    gdk-pixbuf
    pulseaudio
    mobile-broadband-provider-info
  ];

  installPhase = ''
    mkdir -p $out/share/gocode/src/pkg.deepin.io/lib
    cp -a * $out/share/gocode/src/pkg.deepin.io/lib
    rm -r $out/share/gocode/src/pkg.deepin.io/lib/debian
  '';

  meta = with lib; {
    description = "a library containing many useful go routines for things such as glib, gettext, archive, graphic, etc";
    homepage = "https://github.com/linuxdeepin/dde-api";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
