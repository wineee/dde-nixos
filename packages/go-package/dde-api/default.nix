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
}:

buildGoPackage rec {
  pname = "dde-api";
  version = "5.5.12";

  goPackagePath = "github.com/linuxdeepin/dde-api";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-dC9pIkmTRqrQRagGQ6HWJopvOoA01g3ujTjNo6TmRe8=";
  };

  goDeps = ./deps.nix;

  nativeBuildInputs = [
    pkgconfig
    deepin-gettext-tools
    #bc          # run (to adjust grub theme?)
    #blur-effect # run (is it really needed?)
    #utillinux   # run
    #xcur2png    # run
  ];

  buildInputs = [
    go-dbus-factory
    go-gir-generator
    go-lib

    alsaLib
    gtk3
    libcanberra
    libgudev
    librsvg
    poppler
    pulseaudio
    gdk-pixbuf-xlib
  ];

  dontWrapQtApps = true;

  GOFLAGS = [ "-buildmode=pie" "-trimpath" "-mod=readonly" "-modcacherw" ];

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
    description = "DDE API provides some dbus interfaces that is used for screen zone detecting, thumbnail generating, sound playing, etc";
    homepage = "https://github.com/linuxdeepin/dde-api";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
