{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, substituteAll
, buildGoModule
, pkg-config
, deepin-gettext-tools
, gettext
, python3
, wrapGAppsHook
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
}:

buildGoModule rec {
  pname = "dde-daemon";
  version = "6.0.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "52eccc195b39e81a08bcca664f4c122087f7a598";
    hash = "sha256-008n5c4vwuPXBEmnbqh80Bs+IbSJWrhHVJ3iXPt9Pcc=";
  };

  vendorHash = "sha256-51V+cR0TckXorK1DyMrQHcPF4eQ1hUJYyJkmpHsud3Y=";

  patches = [
    ./0002-dont-set-PATH.patch
  ];

  postPatch = ''
    substituteInPlace misc/udev-rules/80-deepin-fprintd.rules \
      --replace "/usr/bin/dbus-send" "${dbus}/bin/dbus-send"

    substituteInPlace session/eventlog/{app_event.go,login_event.go} \
      --replace "/bin/bash" "${runtimeShell}"

    substituteInPlace inputdevices/layout_list.go \
      --replace "/usr/share/X11/xkb" "${xkeyboard_config}/share/X11/xkb"

    substituteInPlace bin/dde-system-daemon/wallpaper.go accounts1/user.go \
     --replace "/usr/share/wallpapers" "/run/current-system/sw/share/wallpapers"

    substituteInPlace timedate1/zoneinfo/zone.go \
     --replace "/usr/share/zoneinfo" "${tzdata}/share/zoneinfo"

    substituteInPlace accounts1/image_blur.go grub2/modify_manger.go \
      --replace "/usr/lib/deepin-api" "/run/current-system/sw/libexec/deepin-api"

    substituteInPlace accounts1/user_chpwd_union_id.go \
      --replace "/usr/lib/dde-control-center" "/run/current-system/sw/lib/dde-control-center"

    for file in $(grep "/usr/lib/deepin-daemon" * -nR |awk -F: '{print $1}')
    do
      sed -i 's|/usr/lib/deepin-daemon|/run/current-system/sw/libexec/deepin-daemon|g' $file
    done

    patchShebangs .
  '';

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
    mv $out/lib/deepin-daemon $out/libexec
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
