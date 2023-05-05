{ stdenv
, lib
, fetchFromGitHub
, substituteAll
, buildGoPackage
, pkg-config
, deepin-gettext-tools
, gettext
, python3
, wrapGAppsHook
, go-dbus-factory
, go-gir-generator
, go-lib
, dde-api
, ddcutil
, alsa-lib
, glib
, gtk3
, libgudev
, libinput
, libnl
, librsvg
, linux-pam
, libxcrypt
, networkmanager
, pulseaudio
, gdk-pixbuf-xlib
, tzdata
, xkeyboard_config
, runtimeShell
, xorg
, xdotool
, getconf
, dbus
, buildGoModule
}:

buildGoModule rec {
  pname = "dde-daemon";
  version = "6.0.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "662e0f184d982ce2e3c4b76135a9fd4297102154";
    hash = "sha256-UJeo+idpCrwirvTi5+OPCWy4R45j7wzx/fw3WNrcBTM=";
  };

  vendorHash = "sha256-51V+cR0TckXorK1DyMrQHcPF4eQ1hUJYyJkmpHsud3Y=";

  patches = [
    ./0002-dont-set-PATH.patch
    #./0003-search-in-XDG-directories.diff
    #./0004-aviod-use-hardcode-path.diff
  ];

  nativeBuildInputs = [
    pkg-config
    deepin-gettext-tools
    gettext
    python3
    wrapGAppsHook
  ];

  buildInputs = [
    ddcutil
    linux-pam
    libxcrypt
    alsa-lib
    glib
    libgudev
    gtk3
    gdk-pixbuf-xlib
    networkmanager
    libinput
    libnl
    librsvg
    pulseaudio
    tzdata
    xkeyboard_config
  ];

  buildPhase = ''
    runHook preBuild
    make GOBUILD_OPTIONS="$GOFLAGS"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make install DESTDIR="$out" PREFIX="/"
    runHook postInstall
  '';

  postInstall = ''
    mv $out/lib/deepin-daemon $out/libexec/deepin-daemon
  '';

  doCheck = false;

  meta = with lib; {
    description = "Daemon for handling the deepin session settings";
    homepage = "https://github.com/linuxdeepin/dde-daemon";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
