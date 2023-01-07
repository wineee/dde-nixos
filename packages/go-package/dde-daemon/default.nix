{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, replaceAll
, substituteAll
, buildGoPackage
, pkg-config
, go-dbus-factory
, go-gir-generator
, go-lib
, deepin-gettext-tools
, gettext
, dde-api
, deepin-desktop-schemas
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
, python3
, hicolor-icon-theme
, glibc
, gdk-pixbuf-xlib
, tzdata
, go
, makeWrapper
, xkeyboard_config
, wrapGAppsHook
, wrapQtAppsHook
, runtimeShell
, fprintd
, xorg
, xdotool
, dbus
, getconf
, util-linux
, ddcutil
, libxcrypt
, dde-account-faces
}:
let
  goCodePatchs = {
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
      # "/usr/share/applications"
    ];
    "audio/audio_config.go" = [
      # "/usr/share/dde-daemon/audio/echoCancelEnable.sh"
    ];
    "bin/dde-authority/fprint_transaction.go" = [
      #? fprintd 0.8 in deepin but 1.9in nixos
      # services.fprintd.enable
      [ "/usr/lib/fprintd/fprintd" "${fprintd}/libexec/fprintd" ]
    ];
    "system/gesture/config.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
    ];
    "system/power/manager_lmt.go" = [
      [ "/usr/sbin/laptop_mode" "laptop_mode" ] # TODO https://github.com/rickysarraf/laptop-mode-tools
    ];
    "bin/user-config/config_datas.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      # "/usr/share/doc/deepin-manuals"
      # "/usr/share/deepin-sample-music"
    ];
    "bin/dde-system-daemon/virtual.go" = [
      # "/usr/share/dde-daemon/supportVirsConf.ini"
    ];
    "system/display/displaycfg.go" = [
      [ "/usr/bin/lightdm-deepin-greeter" "lightdm-deepin-greeter" ]
      [ "runuser" "${util-linux.bin}/bin/runuser" ]
    ];
    "dock/identify_window.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      # "/usr/share/applications/"
    ];
    "keybinding/shortcuts/system_shortcut.go" = [
      [ "dbus-send" "${dbus}/bin/dbus-send" ]
      [ "gsettings" "${glib.bin}/bin/gsettings" ]
      ## TODO
    ];
    "accounts/users/display_manager.go" = [
      #? /usr/share/config/kdm/kdmrc"
    ];
    "accounts/user.go" = [
      [ "/usr/bin/dde-control-center" "dde-control-center" ]
      [ "/usr/share" "/run/current-system/sw/share" ]
      #/usr/share/xsessions
      [ "/var/lib/AccountsService/icons" "${dde-account-faces}/share/lib/AccountsService/icons" ]
    ];
    "dock/desktop_file_path.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      # "/usr/share/applications/"
    ];
    "accounts/user_chpwd_union_id.go" = [
      [ "/usr/lib/dde-control-center/reset-password-dialog" "reset-password-dialog" ]
      [ "/usr/bin/dde-control-center" "dde-control-center" ]
      [ "/usr/bin/dde-lock" "dde-lock" ]
      [ "/usr/bin/lightdm-deepin-greeter" "lightdm-deepin-greeter" ]
    ];
    "dock/dock_manager_init.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      #? ddeDataDir     = "/usr/share/dde/data"
    ];
    "accounts/handle_event.go" = [
      #? /usr/share/config/kdm/kdmrc
    ];
    "accounts/manager.go" = [
      # /usr/share/dde-daemon/accounts/dbus-udcp.json
    ];
    "system/timedated/manager.go" = [
      #? /etc/systemd/timesyncd.conf.d/deepin.conf
    ];
    "accounts/users/manager.go" = [
      #? "/etc/adduser.conf"
    ];
    "image_effect/utils.go" = [
      [ "runuser" "${util-linux.bin}/bin/runuser" ]
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
    (substituteAll {
      src = ./0001-patch_account_face_path_for_nix.patch;
      actConfigDir = "\"${dde-account-faces}/share/lib/AccountsService\"";
    })
    ./0002-fix-PATH-when-was-launched-by-dbus.patch
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
    + replaceAll "/usr/bin/kwin_no_scale" "kwin_no_scale"
    + replaceAll "/usr/bin/deepin-system-monitor" "deepin-system-monitor"
    + replaceAll "/usr/bin/dde-launcher" "dde-launcher"
    + replaceAll "/usr/bin/deepin-calculator" "deepin-calculator"
    + replaceAll "/usr/bin/systemd-detect-virt" "systemd-detect-virt"
    + replaceAll "/usr/share/zoneinfo" "${tzdata}/share/zoneinfo"
    + replaceAll "/usr/share/X11/xkb/rules/base.xml" "${xkeyboard_config}/share/X11/xkb/rules/base.xml"
    + getUsrPatchFrom goCodePatchs + ''
    patchShebangs .
  '';

  goDeps = ./deps.nix;

  nativeBuildInputs = [
    pkg-config
    deepin-gettext-tools
    gettext
    networkmanager
    #networkmanager.dev
    python3
    makeWrapper
    wrapGAppsHook
    wrapQtAppsHook
  ];

  buildInputs = [
    go-dbus-factory
    go-gir-generator
    go-lib
    linux-pam
    libxcrypt
    alsa-lib
    dde-api
    deepin-desktop-schemas
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
    util-linux
    ddcutil
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

  postFixup = ''
    for f in "$out"/lib/deepin-daemon/*; do
      echo "Wrapping $f"
      wrapProgram "$f" \
        "''${gappsWrapperArgs[@]}" \
        "''${qtWrapperArgs[@]}"
    done
    mv $out/run/current-system/sw/lib/deepin-daemon/service-trigger $out/lib/deepin-daemon/
    rm -r $out/run
  '';

  meta = with lib; {
    description = "Daemon for handling the deepin session settings";
    homepage = "https://github.com/linuxdeepin/dde-daemon";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
