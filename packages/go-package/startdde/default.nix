{ stdenv
, lib
, fetchFromGitHub
, buildGoPackage
, pkgconfig
, go-dbus-factory
, go-gir-generator
, go-lib
, deepin-gettext-tools
, gettext
, dde-api
, deepin-desktop-schemas
, alsaLib
, glib
, gtk3
, libgudev
, libinput
, libnl
, librsvg
, linux-pam
, pulseaudio
, python3
, glibc
, gdk-pixbuf-xlib
, tzdata
, go
, xkeyboard_config
, wrapGAppsHook
}:
# TODO fix path in code
buildGoPackage rec {
  pname = "startdde";
  version = "5.9.44";

  goPackagePath = "github.com/linuxdeepin/startdde";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-pTzdIfGqtKdjKKeWCq7qocTsDclgCiRjBkL0Bn2uP7M=";
  };

  goDeps = ./deps.nix;

  nativeBuildInputs = [
    deepin-gettext-tools
    gettext
    pkgconfig
    python3
    wrapGAppsHook
  ];

  buildInputs = [
    go-dbus-factory
    go-gir-generator
    go-lib
    linux-pam
    alsaLib
    dde-api
    deepin-desktop-schemas
    glib
    libgudev
    gtk3
    gdk-pixbuf-xlib
    libinput
    libnl
    librsvg
    tzdata
    xkeyboard_config
  ];

  buildPhase = ''
    runHook preBuild
    GOPATH="$GOPATH:${go-dbus-factory}/share/gocode"
    GOPATH="$GOPATH:${go-gir-generator}/share/gocode"
    GOPATH="$GOPATH:${go-lib}/share/gocode"
    GOPATH="$GOPATH:${dde-api}/share/gocode"
    make -C go/src/${goPackagePath}
    runHook postBuild
  '';

  installPhase = ''
    make install DESTDIR="$out" PREFIX="/" -C go/src/${goPackagePath}
  '';

  meta = with lib; {
    description = "starter of deepin desktop environment";
    longDescription = "Startdde is used for launching DDE components and invoking user's custom applications which compliant with xdg autostart specification";
    homepage = "https://github.com/linuxdeepin/startdde";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
