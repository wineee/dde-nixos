{ stdenv
, lib
, fetchFromGitHub
, buildGoPackage
, pkgconfig
, alsaLib
, bc
, blur-effect
, deepin-gettext-tools
, fontconfig
, go
, go-dbus-factory
, go-gir-generator
, go-lib
, gtk3
, libcanberra
, libgudev
, librsvg
, poppler
, pulseaudio
, utillinux
, xcur2png
, gdk-pixbuf-xlib
, gdk-pixbuf
, iniparser
, cracklib
, linux-pam
, gettext
, glib
}:

buildGoPackage rec {
  pname = "deepin-pw-check";
  version = "5.1.8";

  goPackagePath = "github.com/linuxdeepin/deepin-pw-check";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-2JJmpxsG8gQQt2ASqbmoEZRzaUve4EQGHsEDqC/f/Zs=";
  };

  goDeps = ./deps.nix;

  ### TODO dbus-1 services

  nativeBuildInputs = [
    pkgconfig
    gettext
    deepin-gettext-tools
  ];

  buildInputs = [
    go-dbus-factory
    go-gir-generator
    go-lib
    glib
    gtk3
    iniparser
    cracklib
    linux-pam
    gdk-pixbuf
    gdk-pixbuf-xlib
  ];

  postPatch = ''
    sed -i 's|iniparser/||' */*.c
  '';

  preBuild = ''
    cp -r ${go-lib}/share/gocode/* go/
    cp -r ${go-dbus-factory}/share/gocode/* go/
    cp -r ${go-gir-generator}/share/gocode/* go/
  '';

  buildPhase = ''
    runHook preBuild
    make -C go/src/${goPackagePath}
    runHook postBuild
  '';

  installPhase = ''
    make install DESTDIR="$out" PREFIX="/" -C go/src/${goPackagePath}
  '';

  meta = with lib; {
    description = "a tool to verify the validity of the password";
    homepage = "https://github.com/linuxdeepin/deepin-pw-check";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
