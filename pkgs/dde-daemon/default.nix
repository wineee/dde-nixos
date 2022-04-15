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
, deepin-wallpapers
, deepin-desktop-base
, alsaLib
, glib
, gtk3
, libgudev
, libinput
, libnl
, librsvg
, linux-pam
, networkmanager
, pulseaudio
, python3
, hicolor-icon-theme
, glibc
, gdk-pixbuf-xlib
, tzdata
, go
, makeWrapper
, xkeyboard_config
, wrapGAppsHook
}:

buildGoPackage rec {
  pname = "dde-daemon";
  version = "6.0.0";

  goPackagePath = "github.com/linuxdeepin/dde-daemon";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-uzkEubgHcEhcUZsW6VFASnafealogUNUWMbc6IXCNhY=";
  };

  goDeps = ./deps.nix;

  nativeBuildInputs = [
    pkgconfig
    deepin-gettext-tools
    gettext
    networkmanager
    networkmanager.dev
    python3
    makeWrapper
    wrapGAppsHook
  ];

  buildInputs = [
    go-dbus-factory
    go-gir-generator
    go-lib
    linux-pam

    alsaLib
    dde-api
    deepin-desktop-base
    deepin-desktop-schemas
    deepin-wallpapers
    glib
    libgudev
    gtk3
    gdk-pixbuf-xlib
    hicolor-icon-theme
    libinput
    libnl
    librsvg
    pulseaudio
    tzdata
    xkeyboard_config
  ];

  dontWrapQtApps = true;

  patches = [
    ./remove-tc.patch
    ./dde-daemon.patch
  ];

  postPatch = ''
    rm -rf system/uadp
    rm -rf session/uadpagent
  '';

  preBuild = ''
    cp -r ${go-lib}/share/gocode/* go/
    cp -r ${go-dbus-factory}/share/gocode/* go/
    cp -r ${go-gir-generator}/share/gocode/* go/
    cp -r ${dde-api}/share/gocode/* go/
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
    description = "Daemon for handling the deepin session settings";
    homepage = "https://github.com/linuxdeepin/dde-daemon";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
