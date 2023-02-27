{ stdenv
, lib
, fetchFromGitHub
, replaceAll
, getUsrPatchFrom
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
, alsa-lib
, glib
, gtk3
, libgudev
, libinput
, libnl
, librsvg
, linux-pam
, networkmanager
, pulseaudio
, glibc
, gdk-pixbuf-xlib
, tzdata
, xkeyboard_config
, runtimeShell
, fprintd
, xorg
, xdotool
, dbus
, getconf
, util-linux
, ddcutil
, libxcrypt
}:
let
  patchList = {
    "gesture/config.go" = [
      # "/usr/share/dde-daemon/gesture.json"
    ];
    "appearance/fsnotify.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      # /usr/share/themes /usr/share/icons
    ];
    "apps/utils.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      # return []string{"/usr/share", "/usr/local/share"}
    ];
    "appearance/ifc.go" = [ ];
    "launcher/manager.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      # ddeDataDir = /usr/share/dde/data/
    ];
    "launcher/manager_init.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      # /usr/share/applications
    ];
    "audio/audio_config.go" = [
      # /usr/share/dde-daemon/audio/echoCancelEnable.sh
    ];
    "bin/dde-authority/fprint_transaction.go" = [
      # fprintd 0.8 in deepin but 1.9 in nixos
      [ "/usr/lib/fprintd/fprintd" "${fprintd}/libexec/fprintd" ]
    ];
    "system/gesture/config.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
    ];
    "system/power/manager_lmt.go" = [
      [ "/usr/sbin/laptop_mode" "laptop_mode" ]
    ];
    "bin/user-config/config_datas.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      # /usr/share/doc/deepin-manuals /usr/share/deepin-sample-music
    ];
    "bin/dde-system-daemon/virtual.go" = [
      # /usr/share/dde-daemon/supportVirsConf.ini
    ];
    "system/display/displaycfg.go" = [
      [ "/usr/bin/lightdm-deepin-greeter" "lightdm-deepin-greeter" ]
      [ "runuser" "${util-linux.bin}/bin/runuser" ]
    ];
    "dock/identify_window.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      # /usr/share/applications/
    ];
    "keybinding/shortcuts/system_shortcut.go" = [
      [ "dbus-send" "${dbus}/bin/dbus-send" ]
      [ "gsettings" "${glib.bin}/bin/gsettings" ]
    ];
    "accounts/user.go" = [
      [ "/usr/bin/dde-control-center" "dde-control-center" ]
      [ "/usr/share" "/run/current-system/sw/share" ]
      # /usr/share/xsessions
    ];
    "dock/desktop_file_path.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      # /usr/share/applications/
    ];
    "accounts/user_chpwd_union_id.go" = [
      [ "/usr/lib/dde-control-center" "/run/current-system/sw/lib/dde-control-center" ]
      [ "/usr/bin/dde-control-center" "dde-control-center" ]
      [ "/usr/bin/dde-lock" "dde-lock" ]
      [ "/usr/bin/lightdm-deepin-greeter" "lightdm-deepin-greeter" ]
    ];
    "dock/dock_manager_init.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      # ddeDataDir     = "/usr/share/dde/data"
    ];
    "accounts/manager.go" = [
      # /usr/share/dde-daemon/accounts/dbus-udcp.json
    ];
    "image_effect/utils.go" = [
      [ "runuser" "${util-linux.bin}/bin/runuser" ]
    ];
    "misc/usr/share/deepin/scheduler/config.json" = [
      [ "/usr/bin" "/run/current-system/sw/bin" ]
      # path to deepin-anything/dde-file-manager
    ];
  };
in
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
  ];

  postPatch = replaceAll "/usr/lib/deepin-api" "/run/current-system/sw/lib/deepin-api"
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
    + getUsrPatchFrom patchList + ''
    patchShebangs .
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
    util-linux
    ddcutil
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