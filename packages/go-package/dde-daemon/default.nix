{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
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
, wrapQtAppsHook
, runtimeShell
, fprintd
, xorg
, xdotool
, dbus
, getconf
, utillinux
, ddcutil
}:
let
  goCodePatchs = {
    "inputdevices/layout_list.go" = [
      [ "/usr/share/X11/xkb/rules/base.xml" "${xkeyboard_config}/share/X11/xkb/rules/base.xml" ]
    ];
    "grub2/modify_manger.go" = [
      [ "_ = os.Setenv(\"PATH\", \"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\")" " " ]
    ];
    "gesture/config.go" = [
      # "/usr/share/dde-daemon/gesture.json"
    ];
    "appearance/fsnotify.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      # /usr/share/themes"
      # /usr/share/icons
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
    "launcher/manager_ifc.go" = [
      [ "/usr/bin/dde-launcher" "dde-launcher" ]
    ];
    "audio/audio_config.go" = [
      # "/usr/share/dde-daemon/audio/echoCancelEnable.sh"
    ];
    "bin/dde-authority/fprint_transaction.go" = [
      #? fprintd 0.8 in deepin but 1.9in nixos
      # services.fprintd.enable
      [ "/usr/lib/fprintd/fprintd" "${fprintd}/libexec/fprintd" ]
    ];
    "system/power_manager/utils.go" = [
      [ "/usr/bin/systemd-detect-virt" "systemd-detect-virt" ]
    ];
    "system/gesture/config.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
    ];
    "system/power/manager_lmt.go" = [
      [ "/usr/sbin/laptop_mode" "laptop_mode" ] # TODO https://github.com/rickysarraf/laptop-mode-tools
    ];
    "bin/user-config/config_datas.go" = [
      #TODO
      [ "/usr/share" "/run/current-system/sw/share" ]
      # "/usr/share/doc/deepin-manuals"
      # "/usr/share/deepin-sample-music"
      #? /etc/default/locale
    ];
    "bin/dde-system-daemon/virtual.go" = [
      # "/usr/share/dde-daemon/supportVirsConf.ini"
    ];
    "system/display/displaycfg.go" = [
      [ "/usr/bin/lightdm-deepin-greeter" "lightdm-deepin-greeter" ]
      [ "runuser" "${utillinux.bin}/bin/runuser" ]
    ];
    "service_trigger/manager.go" = [
      [ "/etc/deepin-daemon/" "$out/etc/deepin-daemon/" ]
    ];
    "keybinding/utils.go" = [
      [ "/usr/bin/kwin_no_scale" "kwin_no_scale" ]
    ];
    "dock/identify_window.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      # "/usr/share/applications/"
    ];
    "keybinding/shortcuts/system_shortcut.go" = [
      [ "/usr/bin/deepin-system-monitor" "deepin-system-monitor" ]
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
    "accounts/users/list.go" = [
      #? /usr/etc/login.defs
    ];
    "accounts/handle_event.go" = [
      #? /usr/share/config/kdm/kdmrc
    ];
    "accounts/manager.go" = [
      # /usr/share/dde-daemon/accounts/dbus-udcp.json
    ];

    "grub2/grub_params.go" = [
      #/etc/default/grub
    ];
    "grub_common/common.go" = [
      #/etc/default/grub
    ];
    "system/timedated/manager.go" = [
      #? /etc/systemd/timesyncd.conf.d/deepin.conf
    ];
    "langselector/locale_ifc.go" = [
      #? /etc/locale.gen
    ];
    "accounts/users/manager.go" = [
      #? "/etc/adduser.conf"
    ];
    "image_effect/utils.go" = [
      [ "runuser" "${utillinux.bin}/bin/runuser" ]
    ];
    "misc/etc/acpi/events/deepin_lid" = [ 
      [ "/etc/acpi/actions/deepin_lid.sh" "$out/etc/acpi/actions/deepin_lid.sh" ]
    ];
    "misc/applications/deepin-toggle-desktop.desktop" = [ ];
    "misc/udev-rules/80-deepin-fprintd.rules" = [
      [ "/usr/bin/dbus-send" "${dbus}/bin/dbus-send" ]
    ];
    "misc/dde-daemon/keybinding/system_actions.json" = [
      [ "/usr/bin/deepin-system-monitor" "deepin-system-monitor" ]
    ];
  };
  replaceAll = x: y: ''
    echo Replacing "${x}" to "${y}":
    for file in $(grep -rl "${x}")
    do
      echo -- $file
      substituteInPlace $file \
        --replace "${x}" "${y}"
    done
  '';
in
buildGoPackage rec {
  pname = "dde-daemon";
  version = "5.14.104";

  goPackagePath = "github.com/linuxdeepin/dde-daemon";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-BkqKVgJey4uwtBe0dJbg5VhtXJSVhmuYDIiv0pX21Ko=";
  };

  postPatch =  getUsrPatchFrom goCodePatchs
               + replaceAll "/usr/lib/deepin-api" "/run/current-system/sw/lib/deepin-api"
               + replaceAll "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"
               + replaceAll "/usr/share/wallpapers" "/run/current-system/sw/share/wallpapers"
               + replaceAll "/bin/bash" "${runtimeShell}"
               + replaceAll "/bin/sh" "${runtimeShell}"
               + replaceAll "/usr/bin/setxkbmap" "${xorg.setxkbmap}/bin/setxkbmap"
               + replaceAll "/usr/bin/xdotool" "${xdotool}/bin/xdotool"
               + replaceAll "/usr/bin/getconf" "${getconf}/bin/getconf"
               + replaceAll "/usr/share/zoneinfo" "${tzdata}/share/zoneinfo"
               + ''
                  patchShebangs .
               '';

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
    wrapQtAppsHook
  ];

  buildInputs = [
    go-dbus-factory
    go-gir-generator
    go-lib
    linux-pam

    alsaLib
    dde-api
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
    utillinux
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
