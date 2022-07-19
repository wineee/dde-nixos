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
, wrapQtAppsHook
, runtimeShell
}:
let
  goCodePatchs = {
    "inputdevices/layout_list.go" = [
      #? ["/usr/share/X11/xkb/rules/base.xml"]
    ];
    "inputdevices/keyboard.go" = [
      ["/usr/bin/setxkbmap" "setxkbmap"]
      #? "/etc/default/keyboard"
    ];
    "grub2/modify_manger.go" = [
      #? ["/usr/lib/deepin-api/adjust-grub-theme"]
      ## FIXE setENV ??
      ## os.Setenv("PATH", "/usr/local/sbin:
    ];
    "gesture/built-in.go" = [
      # "/usr/lib/deepin-daemon/desktop-toggle"
    ];
    "gesture/config.go" = [
      # "/usr/share/dde-daemon/gesture.json"
    ];
    "appearance/fsnotify.go" = [
      ["/usr/share" "/run/current-system/sw/share"]
      # /usr/share/themes"
      # /usr/share/icons
    ];
    "appearance/background/list.go" = [
      ["/usr/share/wallpapers/deepin" "/run/current-system/sw/share/wallpapers/deepin"]
    ];
    "apps/utils.go" = [
      ["/usr/share" "/run/current-system/sw/share"]
      # return []string{"/usr/share", "/usr/local/share"}
    ];
    "appearance/background/custom_wallpapers.go" = [
      ["/usr/share/wallpapers/deepin/desktop.bmp" "/run/current-system/sw/share/wallpapers/deepin/desktop.bmp"]
    ];
    "timedate/zoneinfo/zone.go" = [
      ["usr/share/zoneinfo" "/etc/zoneinfo"]
    ];
    "appearance/ifc.go" = [ ];
    "appearance/manager.go" = [
      ["usr/share/zoneinfo" "/etc/zoneinfo"]
    ];
    "launcher/manager.go" = [
      ["/usr/share" "/run/current-system/sw/share"]
      ## ddeDataDir = /usr/share/dde/data/
    ];
    "launcher/manager_init.go" = [
      ["/usr/share" "/run/current-system/sw/share"]
      # "/usr/share/applications"
    ];
    "launcher/manager_ifc.go" = [
      ["/usr/bin/dde-launcher" "dde-launcher"]
    ];
    "launcher/manager_uninstall.go" = [
      #? "/usr/share/deepin-flatpak/app/"
    ];
    "audio/audio_config.go" = [
      ["/bin/sh" "${runtimeShell}"]
      # "/usr/share/dde-daemon/audio/echoCancelEnable.sh"
    ];
    "bin/dde-authority/fprint_transaction.go" = [
      #? "/usr/lib/fprintd/fprintd"
    ];
    "system/power_manager/utils.go" = [
      ["/usr/bin/systemd-detect-virt" "systemd-detect-virt"]
    ];
    "system/gesture/config.go" = [
      ## TODO
      
      #/etc/
      # ?
    ];
    "system/systeminfo/manager.go" = [
      ["/usr/bin/getconf" "getconf"]
    ];
    "bin/search/main.go" = [
      # /usr/lib/deepin-daemon/search
    ];
    "system/power/manager_lmt.go" = [
      ["/usr/sbin/laptop_mode" "laptop_mode"]
      #? "/etc/laptop-mode/laptop-mode.conf"
    ];
    "bin/user-config/config_datas.go" = [
      #TODO
      ["/usr/share" "/run/current-system/sw/share"]
      # "/usr/share/doc/deepin-manuals"
      # "/usr/share/deepin-default-settings"
      # "/usr/share/deepin-sample-music"
      #? /etc/default/locale
      #? /etc/skel.locale
    ];
    "bin/dde-system-daemon/wallpaper.go" = [
      ["/usr/share" "/run/current-system/sw/share"]
      #"/usr/share/wallpapers/custom-wallpapers/
    ];
    "bin/dde-system-daemon/virtual.go" = [
      #"/usr/share/dde-daemon/supportVirsConf.ini"
    ];
    "system/display/displaycfg.go" =[
      ["/usr/bin/lightdm-deepin-greeter" "lightdm-deepin-greeter"]
    ];
    "bin/dde-system-daemon/main.go" = [
      #? os.Setenv("PATH", "/usr/local/sbin
      # "/usr/lib/deepin-daemon/dde-system-daemon"
    ];
    "service_trigger/manager.go" = [
      # "/usr/lib/deepin-daemon/"
      ["/etc/deepin-daemon/" "$out/etc/deepin-daemon/"]
    ];
    "bluetooth/utils_notify.go" = [
      ["/usr/lib/deepin-daemon/dde-bluetooth-dialog" "dde-bluetooth-dialog"]
    ];
    "keybinding/special_keycode.go" = [
      ["/usr/bin/setxkbmap" "setxkbmap" ]
      ["/usr/bin/xdotool" "xdotool"]
    ];
    "mime/app_info.go" = [
      # /usr/share /usr/local/share
    ];
    "keybinding/utils.go" = [
      [ "/usr/bin/kwin_no_scale" "kwin_no_scale" ]
    ];
    "network/manager.go" = [
      #? ["/usr/lib/NetworkManager/VPN" ]
      #? ["/etc/NetworkManager/VPN"] 
    ];
    "dock/identify_window.go" = [
      ["/usr/share" "/run/current-system/sw/share"]
      # "/usr/share/applications/"
    ];
    "keybinding/shortcuts/system_shortcut.go"= [
      ["/usr/bin/setxkbmap" "setxkbmap"]
      ["/usr/bin/xdotool" "xdotool"]
      ["/usr/bin/deepin-system-monitor" "deepin-system-monitor"]
      ## TODO
    ];
    "accounts/users/display_manager.go" = [
      #? /usr/share/config/kdm/kdmrc"
    ];
    "accounts/user.go" = [
      # /usr/lib/deepin-daemon
      ["/usr/bin/dde-control-center" "dde-control-center"]
      ["/usr/share" "/run/current-system/sw/share"]
      #/usr/share/wallpapers/deepin/
      #/usr/share/xsessions
    ];
    "network/nm_setting_vpn.go" = [
      #? "/etc/NetworkManager/VPN"
      #? "/usr/lib/NetworkManager/VPN"
    ];
    "accounts/image_blur.go" = [
      [ "/usr/lib/deepin-api/image-blur-helper" "image-blur-helper" ]
    ];
    "dock/desktop_file_path.go" = [
      ["/usr/share" "/run/current-system/sw/share"]
      # "/usr/share/applications/"
    ];
    "accounts/user_chpwd_union_id.go" = [
      ["/usr/lib/dde-control-center/reset-password-dialog" "reset-password-dialog"]
      ["/usr/bin/dde-control-center" "dde-control-center"]
      ["/usr/bin/dde-lock" "dde-lock"]
      ["/usr/bin/lightdm-deepin-greeter" "lightdm-deepin-greeter"]
    ];
    "dock/dock_manager_init.go" = [
      ["/usr/share" "/run/current-system/sw/share"]
      #? ddeDataDir     = "/usr/share/dde/data"
    ];
    "accounts/users/list.go" = [
      #? /usr/etc/login.defs
    ];
    "keybinding/shortcuts/media_shortcut.go" = [
      # /usr/lib/deepin-daemon/default-terminal
    ];
    "network/secret_agent.go" = [
      # /usr/lib/deepin-daemon/dnetwork-secret-dialog
    ];
    "accounts/handle_event.go" = [
      #? /usr/share/config/kdm/kdmrc
    ];
    "accounts/manager.go" = [
      # /usr/share/dde-daemon/accounts/dbus-udcp.json
    ];
    "systeminfo/utils.go" = [
      [ "/usr/bin/getconf" "getconf" ]
    ];
    "session/power/constant.go" = [
      [ "/usr/lib/deepin-daemon/dde-lowpower" "dde-lowpower"]
    ];
    "audio/util.go" = [
      #? "/etc/pulse/default.pa"
    ];
    "grub2/edit_auth.go" = [
      #? "/etc/grub.d/42_uos_menu_crypto"
    ];
    # "grub2/grub_params.go" = [
    #   /etc/default/grub
    # ];
    # "grub_common/common.go" = [
    #   /etc/default/grub
    # ];
    "system/timedated/manager.go" =[
      #? /etc/systemd/timesyncd.conf.d/deepin.conf
    ];
    "bin/dde-system-daemon/network.go" = [
      #?/etc/NetworkManager/system-connections
    ];
    "langselector/locale_ifc.go" = [
      #? /etc/locale.gen
    ];
    "keybinding/shortcuts/shortcut_manager.go" = [
      #? /etc/deepin-version
    ];
    "accounts/deepinversion.go" = [
      #? /etc/deepin-version
    ];
    "accounts/users/manager.go" = [
      #? "/etc/adduser.conf"
    ];
    "accounts/users/common.go" = [
      #"/etc/deepin-version"
    ];
    #TODO "accounts/users/display_manager.go"
    "systeminfo/distro.go" = [
      #/etc/lsb-release
    ];
    "systeminfo/version.go" = [
      #? /etc/deepin-version
      #/etc/lsb-release
    ];
    "session/power/power_save_plan.go" = [
      #? /etc/deepin/no_suspend
    ];
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
    wrapQtAppsHook
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

  postPatch = rmUadpPatch + fixShebangsPatch + fixPathPatch + getPatchFrom goCodePatchs;

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
