{ stdenv
, lib
, fetchFromGitHub
, getPatchFrom
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
let
  goCodePatchs = {

  };
in
buildGoPackage rec {
  pname = "dde-daemon";
  version = "5.14.44";

  goPackagePath = "github.com/linuxdeepin/dde-daemon";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-Enikmyt+CsBb00YwqxbA/id1n/PUYoZ7LykB74PToYc=";
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
    #deepin-desktop-base
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

  # https://github.com/linuxdeepin/dde-daemon/blob/master/accounts/user.go

  rmUadpPatch = ''
    rm -rf system/uadp
    rm -rf session/uadpagent
  '';

  fixShebangsPatch = ''
    patchShebangs misc/etc/acpi/actions/deepin_lid.sh \
      misc/libexec/dde-daemon/keybinding/shortcut-dde-grand-search.sh \
      misc/dde-daemon/audio/echoCancelEnable.sh
  '';

  fixPathPatch = ''
    for file in misc/system-services/* misc/services/* misc/systemd/services/*
    do
      substituteInPlace $file \
        --replace "/usr/lib/deepin-daemon" "$out/lib/deepin-daemon"
    done

    substituteInPlace misc/udev-rules/80-deepin-fprintd.rules \
      --replace "/usr/bin/dbus-send" "dbus-send"

    substituteInPlace misc/dde-daemon/keybinding/system_actions.json \
      --replace "/usr/lib/deepin-daemon/"        "$out/lib/deepin-daemon/" \
      --replace "/usr/bin/deepin-system-monitor" "deepin-system-monitor" \
      --replace "/usr/bin/setxkbmap"             "setxkbmap"\
      --replace "/usr/bin/xdotool"               "xdotool"

    substituteInPlace misc/applications/deepin-toggle-desktop.desktop \
      --replace "/usr/lib/deepin-daemon/desktop-toggle" "$out/lib/deepin-daemon/desktop-toggle"

    substituteInPlace misc/etc/acpi/events/deepin_lid \
      --replace "/etc/acpi/actions/deepin_lid.sh" "$out/etc/acpi/actions/deepin_lid.sh"
  '';

  postPatch = rmUadpPatch + fixShebangsPatch + fixPathPatch;

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

  postFixup = ''
    for f in "$out"/lib/deepin-daemon/*; do
      echo "Wrapping $f"
      wrapProgram "$f" \
        "''${gappsWrapperArgs[@]}" \
        "''${qtWrapperArgs[@]}"
    done
  '';

  meta = with lib; {
    description = "Daemon for handling the deepin session settings";
    homepage = "https://github.com/linuxdeepin/dde-daemon";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
