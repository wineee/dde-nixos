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
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "Decodetalkers";
    repo = pname;
    rev = "7baf6716982f8137126a95c11524fed7e1207753";
    sha256 = "sha256-i2/V58JtGyx209A0Ns3q+oYKke9H7KKTPlRf+/ZR1TM=";
  };

  vendorHash = "sha256-B4Q6Uf5bhOWFbzrl5eZJsPUWww/v1TzrRe+2gkCXqc0=";

  patches = [
    #./0001-fix-wrapped-name-for-verifyExe.diff
    #./0002-dont-set-PATH.diff
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

  doCheck = false;

  postFixup = ''
    for f in "$out"/lib/deepin-daemon/*; do
      echo "Wrapping $f"
      wrapGApp "$f"
    done
  '';

  meta = with lib; {
    description = "Daemon for handling the deepin session settings";
    homepage = "https://github.com/linuxdeepin/dde-daemon";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
