{ stdenv
, lib
, fetchFromGitHub
, replaceAll
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
}:

buildGoPackage rec {
  pname = "dde-daemon";
  version = "5.14.122";

  goPackagePath = "github.com/linuxdeepin/dde-daemon";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-KoYMv4z4IGBH0O422PuFHrIgDBEkU08Vepax+00nrGE=";
  };

  patches = [
    ./0001-fix-wrapped-name-for-verifyExe.diff
    ./0002-dont-set-PATH.diff
    ./0003-search-in-XDG-directories.diff
    ./0004-aviod-use-hardcode-path.diff
  ];

  postPatch = ''
    substituteInPlace accounts/user_chpwd_union_id.go \
      --replace "/usr/lib/dde-control-center" "/run/current-system/sw/lib/dde-control-center"

    # fix path to deepin-anything/dde-file-manager
    substituteInPlace misc/usr/share/deepin/scheduler/config.json \
      --replace "/usr/bin" "/run/current-system/sw/bin"

    # Warning: Not sure what it's used for here
    substituteInPlace dock/desktop_file_path.go \
      --replace "/usr/share" "/run/current-system/sw/share"

    # path to deepin-manuals/deepin-sample-music, should be a non-essential feature
    substituteInPlace bin/user-config/config_datas.go \
      --replace "/usr/share" "/run/current-system/sw/share"
    
    patchShebangs .

    # clean up testdata
    find . -name testdata -exec rm -r {} \; || true
  '' + replaceAll "/usr/lib/deepin-api" "/run/current-system/sw/lib/deepin-api"
    + replaceAll "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"
    + replaceAll "/usr/share/wallpapers" "/run/current-system/sw/share/wallpapers"
    + replaceAll "/usr/share/backgrounds" "/run/current-system/sw/share/backgrounds"
    + replaceAll "/bin/bash" "${runtimeShell}"
    + replaceAll "/bin/sh" "${runtimeShell}"
    + replaceAll "/usr/bin/setxkbmap" "${xorg.setxkbmap}/bin/setxkbmap"
    + replaceAll "/usr/bin/xdotool" "${xdotool}/bin/xdotool"
    + replaceAll "/usr/bin/getconf" "${getconf}/bin/getconf"
    + replaceAll "/usr/bin/dbus-send" "${dbus}/bin/dbus-send"
    + replaceAll "/usr/share/zoneinfo" "${tzdata}/share/zoneinfo"
    + replaceAll "/usr/share/X11/xkb/rules/base.xml" "${xkeyboard_config}/share/X11/xkb/rules/base.xml"
    + replaceAll "/usr/bin/kwin_no_scale" "kwin_no_scale"
    + replaceAll "/usr/bin/deepin-system-monitor" "deepin-system-monitor"
    + replaceAll "/usr/bin/dde-launcher" "dde-launcher"
    + replaceAll "/usr/bin/deepin-calculator" "deepin-calculator"
    + replaceAll "/usr/bin/systemd-detect-virt" "systemd-detect-virt"
    + ''
      echo Replacing "/usr" to "$out":
      for file in $(grep -rl "/usr" --exclude=Makefile); do
        echo -- $file
        substituteInPlace $file \
          --replace "/usr" "$out"
      done
    '';

  goDeps = ./deps.nix;

  nativeBuildInputs = [
    pkg-config
    deepin-gettext-tools
    gettext
    python3
    wrapGAppsHook
  ];

  buildInputs = [
    go-dbus-factory
    go-gir-generator
    go-lib
    dde-api
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
    addToSearchPath GOPATH "${go-dbus-factory}/share/gocode"
    addToSearchPath GOPATH "${go-gir-generator}/share/gocode"
    addToSearchPath GOPATH "${go-lib}/share/gocode"
    addToSearchPath GOPATH "${dde-api}/share/gocode"
    make -C go/src/${goPackagePath}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make install DESTDIR="$out" PREFIX="/" -C go/src/${goPackagePath}
    runHook postInstall
  '';

  postFixup = ''
    for f in "$out"/lib/deepin-daemon/*; do
      echo "Wrapping $f"
      wrapGApp "$f"
    done
    mv $out/run/current-system/sw/lib/deepin-daemon/service-trigger $out/lib/deepin-daemon/
    rm -r $out/run
  '';

  meta = with lib; {
    description = "Daemon for handling the deepin session settings";
    homepage = "https://github.com/linuxdeepin/dde-daemon";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}