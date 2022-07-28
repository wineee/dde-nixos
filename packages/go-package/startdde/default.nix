{ stdenv
, lib
, fetchFromGitHub
, getPatchFrom
, buildGoPackage
, pkgconfig
, go-dbus-factory
, go-gir-generator
, go-lib
, gettext
, dde-api
, libgnome-keyring
, gtk3
, alsa-lib
, libgudev
, libsecret
, jq
, glib
, wrapGAppsHook
, runtimeShell
, dde-daemon
, dde-polkit-agent
, dde-session-ui
, dde-session-shell
, gnome
}:
let
  patchList = {
    "main.go" = [
      [ "/usr/bin/kwin_no_scale" "kwin_no_scale" ] ### TODO dde-kwine 
      [ "/usr/lib/deepin-daemon/dde-session-daemon" "${dde-daemon}/lib/deepin-daemon/dde-session-daemon" ]
      [ "/usr/bin/dde-dock" "dde-dock" ]
      [ "/usr/bin/dde-desktop" "dde-desktop" ]
      [ "/usr/libexec/deepin/login-reminder-helper" "login-reminder-helper" ]
      [ "/usr/bin/dde-hints-dialog" "dde-hints-dialog" ]
    ];
    "session.go" = [
      [ "/usr/share/applications/dde-lock.desktop" "/run/current-system/sw/share/applications/dde-lock.desktop" ]
      [ "/usr/bin/dde-shutdown" "dde-shutdown" ]
      [ "/usr/lib/deepin-daemon/langselector" "${dde-daemon}/lib/deepin-daemon/langselector" ]
      [ "/usr/bin/dde-lock" "${dde-session-shell}/bin/dde-lock" ]
      [ "/usr/lib/deepin-daemon/dde-osd" "${dde-session-ui}/lib/deepin-daemon/dde-osd" ]
      [ "/usr/bin/gnome-keyring-daemon" "${gnome.gnome-keyring}/bin/gnome-keyring-daemon" ]
      #? [ "/usr/share/deepin-default-settings/fontconfig.json"  ] 
    ];
    "main_test.go" = [
      [ "/usr/bin/kwin_no_scale" "kwin_no_scale" ]
    ];
    "misc/lightdm.conf" = [
      # "/usr/sbin/deepin-fix-xauthority-perm" 
    ];
    "misc/Xsession.d/00deepin-dde-env" = [
      # "/usr/bin/startdde
    ];
    "misc/auto_launch/chinese.json" = [
      [ "/usr/bin/dde-file-manager" "dde-file-manager" ]
      [ "/usr/lib/polkit-1-dde/dde-polkit-agent" "${dde-polkit-agent}/lib/polkit-1-dde/dde-polkit-agent" ] 
      [ "/usr/bin/dde-shutdown" "dde-shutdown" ]
    ];
    "misc/auto_launch/default.json" = [
      [ "/usr/lib/polkit-1-dde/dde-polkit-agent" "${dde-polkit-agent}/lib/polkit-1-dde/dde-polkit-agent" ] 
    ];
    "utils.go" = [
      [ "/usr/lib/deepin-daemon/dde-welcome" "${dde-session-ui}/lib/deepin-daemon/dde-welcome" ]
    ];
    "launch_group.go" = [
      # "/usr/share/startdde/auto_launch.json" 
    ];
    "watchdog/deepinid_daemon.go" = [
      [ "/usr/lib/deepin-deepinid-daemon/deepin-deepinid-daemon" "deepin-deepinid-daemon" ]
    ];
    "watchdog/watchdog_test.go" = [
      [ "/usr/bin/kwin_no_scale" "kwin_no_scale" ]
    ];
    "watchdog/dde_polkit_agent.go" = [
      [ "/usr/lib/polkit-1-dde/dde-polkit-agent" "${dde-polkit-agent}/lib/polkit-1-dde/dde-polkit-agent" ] 
    ];
    "launch_group_test.go" = [
      [ "/usr/lib/polkit-1-dde/dde-polkit-agent" "${dde-polkit-agent}/lib/polkit-1-dde/dde-polkit-agent" ] 
    ];
    "testdata/auto_launch/auto_launch.json" = [
      [ "/usr/lib/polkit-1-dde/dde-polkit-agent" "${dde-polkit-agent}/lib/polkit-1-dde/dde-polkit-agent" ] 
    ];
    "testdata/desktop/dde-file-manager.desktop" = [
      [ "/usr/bin/dde-file-manager" "dde-file-manager" ]
    ];
    "memchecker/config.go" = [
      # /usr/share/startdde/memchecker.json 
    ];
    "display/manager.go" = [
      [ "/usr/lib/deepin-daemon/dde-touchscreen-dialog" "dde-touchscreen-dialog" ]
      [ "/bin/bash" "${runtimeShell}" ]
    ];
    "display/wayland.go" = [
      [ "/usr/bin/dde_wloutput" "dde_wloutput" ]
    ];
    #?  "memanalyzer/config_test.go" 
  };
in
buildGoPackage rec {
  pname = "startdde";
  version = "5.9.44";

  goPackagePath = "github.com/linuxdeepin/startdde";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-qS7r7CeK8ogrxqiNJh4/fYAaLo2j3f+N4S9a6jiur+U=";
  };

  postPatch = getPatchFrom patchList + ''
    substituteInPlace "startmanager.go"\
      --replace "/usr/share/startdde/app_startup.conf" "$out/share/startdde/app_startup.conf"
    substituteInPlace misc/xsessions/deepin.desktop.in --subst-var-by PREFIX $out
  '';

  goDeps = ./deps.nix;

  nativeBuildInputs = [
    gettext
    pkgconfig
    jq
    wrapGAppsHook
    glib
  ];

  buildInputs = [
    go-dbus-factory
    go-gir-generator
    go-lib
    dde-api
    libgnome-keyring
    gtk3
    alsa-lib
    libgudev
    libsecret
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

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
  '';

  passthru.providedSessions = [ "deepin" ];

  meta = with lib; {
    description = "starter of deepin desktop environment";
    longDescription = "Startdde is used for launching DDE components and invoking user's custom applications which compliant with xdg autostart specification";
    homepage = "https://github.com/linuxdeepin/startdde";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
