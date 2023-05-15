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
, util-linux
, dde-session-ui
, coreutils
, lshw
, systemd
}:

buildGoModule rec {
  pname = "dde-daemon";
  version = "6.0.16";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-pcVugGTNY7PAwiLEdwF1j8k8zTlG2/2rs0WQMZz38d0=";
  };

  vendorHash = "sha256-4/HGviJGTJoW2cVDsOvOfeHGaiXKBTzat7/5Q0FoTR8=";

  patches = [
    ./0001-dont-set-PATH.diff
    (substituteAll {
      src = ./0002-fix-custom-wallpapers-path.diff;
      inherit coreutils;
    })
    ./0003-search-in-XDG-directories.patch
    (substituteAll {
      src = ./0004-aviod-use-hardcode-path.patch;
      inherit dbus;
    })
  ];

  postPatch = ''
    substituteInPlace session/eventlog/{app_event.go,login_event.go} \
      --replace "/bin/bash" "${runtimeShell}"

    substituteInPlace inputdevices/layout_list.go \
      --replace "/usr/share/X11/xkb" "${xkeyboard_config}/share/X11/xkb"

    substituteInPlace bin/dde-system-daemon/wallpaper.go accounts1/user.go \
     --replace "/usr/share/wallpapers" "/run/current-system/sw/share/wallpapers"

    substituteInPlace timedate1/zoneinfo/zone.go \
     --replace "/usr/share/zoneinfo" "${tzdata}/share/zoneinfo"

    substituteInPlace accounts1/image_blur.go grub2/modify_manger.go \
      --replace "/usr/lib/deepin-api" "/run/current-system/sw/lib/deepin-api"

    substituteInPlace accounts1/user_chpwd_union_id.go \
      --replace "/usr/lib/dde-control-center" "/run/current-system/sw/lib/dde-control-center"

    for file in $(grep "/usr/lib/deepin-daemon" * -nR |awk -F: '{print $1}')
    do
      sed -i 's|/usr/lib/deepin-daemon|/run/current-system/sw/lib/deepin-daemon|g' $file
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

  doCheck = false;

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${lib.makeBinPath [ util-linux dde-session-ui glib lshw systemd ]}"
    )
  '';

  postFixup = ''
    for binary in $out/lib/deepin-daemon/*; do
      if [ "$binary" == "$out/lib/deepin-daemon/service-trigger" ] ; then
        continue;
      fi
      wrapGApp $binary
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
