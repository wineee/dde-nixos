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
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-9u/dstjsL/hcd+JYYiQnR4S4Jcu6BKxeBgl963jyJc0=";
  };

  installPhase = ''
    mkdir -p $out/share/gocode/src/github.com/linuxdeepin/go-lib
    cp -a * $out/share/gocode/src/github.com/linuxdeepin/go-lib
    rm -r $out/share/gocode/src/github.com/linuxdeepin/go-lib/debian
  '';

  installCheckInputs = [
    go
    glib
    xorg.libX11
    gdk-pixbuf
    pulseaudio
    mobile-broadband-provider-info
  ];

  doInstallCheck = false;

  # FIXME go get can't access web
  installCheckPhase = ''
    export GOPROXY=https://goproxy.cn
    export GOPATH="$out/share/gocode"
    cd $out/share/gocode/src/pkg.deepin.io/lib
    go get github.com/smartystreets/goconvey github.com/howeyc/fsnotify gopkg.in/check.v1 github.com/linuxdeepin/go-x11-client
    go test -v $(go list ./... | grep -v -e lib/pulse -e lib/users/passwd -e lib/users/group -e lib/timer -e lib/log -e lib/dbus -e lib/shell)
  '';

  meta = with lib; {
    description = "a library containing many useful go routines for things such as glib, gettext, archive, graphic, etc";
    homepage = "https://github.com/linuxdeepin/dde-api";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
