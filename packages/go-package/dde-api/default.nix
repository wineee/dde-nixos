{ stdenv
, lib
, fetchFromGitHub
, buildGoPackage
, getPatchFrom
, pkgconfig
, alsaLib
, bc
, blur-effect
, deepin-gettext-tools
, fontconfig
, go
, go-dbus-factory
, go-gir-generator
, go-lib
, gtk3
, libcanberra
, libgudev
, librsvg
, poppler
, pulseaudio
, utillinux
, xcur2png
, gdk-pixbuf-xlib
, dbus
, coreutils
}:
let
  patchList = {
    ### CODE
    "lunar-calendar/huangli.go" = [
      # /usr/share/dde-api/data/huangli*
    ];
    "lunar-calendar/main.go" = [
      #? /usr/lib/deepin-api/lunar-calendar
    ];
    "locale-helper/main.go" = [
      [ "/usr/local/sbin:" "PATH:/usr/local/sbin" ]
      #?
    ];

    "theme_thumb/gtk/gtk.go" = [
      # /usr/lib/deepin-api/gtk-thumbnailer
    ];
    "device/main.go" = [
      [ "/usr/local/sbin:" "PATH:/usr/local/sbin" ]
    ];
    "thumbnails/gtk/gtk.go" = [
      # /usr/lib/deepin-api/gtk-thumbnailer
    ];
    "i18n_dependent/i18n_dependent.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      #? /usr/share/i18n/i18n_dependent.json
    ];
    "adjust-grub-theme/main.go" = [
      # "/usr/share/dde-api/data/grub-themes/"
    ];
    "language_support/lang_support.go" = [
      #? dpkg
    ];
    "sound-theme-player/main.go" = [
      [ "/usr/sbin/alsactl" "alsactl" ]
    ];
    "themes/theme.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
    ];
    "themes/settings.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
    ];
    "lang_info/lang_info.go" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      #? /usr/share/i18n/language_info.json
    ];

    ### MISC
    "misc/systemd/system/deepin-login-sound.service" = [
      [ "/usr/bin/dbus-send" "${dbus}/bin/dbus-send" ]
    ];
    "misc/systemd/system/deepin-shutdown-sound.service" = [
      [ "/usr/bin/true" "${coreutils}/bin/true" ]
      # /usr/lib/deepin-api/deepin-shutdown-sound
    ];
  };
in
buildGoPackage rec {
  pname = "dde-api";
  version = "5.5.25";

  goPackagePath = "github.com/linuxdeepin/dde-api";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-0W3KmXuqbNy2XrEr5LlJCI6YlFyDpWG6KsyJTFO2PQE";
  };

  goDeps = ./deps.nix;

  nativeBuildInputs = [
    pkgconfig
    deepin-gettext-tools
    #bc          # run (to adjust grub theme?)
    #blur-effect # run (is it really needed?)
    #utillinux   # run
    #xcur2png    # run
  ];

  buildInputs = [
    go-dbus-factory
    go-gir-generator
    go-lib

    alsaLib
    gtk3
    libcanberra
    libgudev
    librsvg
    poppler
    pulseaudio
    gdk-pixbuf-xlib
  ];

  dontWrapQtApps = true;

  postPatch = getPatchFrom patchList + ''
    for file in misc/system-services/* misc/services/*
     do
       substituteInPlace $file \
         --replace "/usr/lib/deepin-api" "$out/lib/deepin-api"
     done
  '';

  GOFLAGS = [ "-buildmode=pie" "-trimpath" "-mod=readonly" "-modcacherw" ];

  buildPhase = ''
    runHook preBuild
    GOPATH="$GOPATH:${go-dbus-factory}/share/gocode"
    GOPATH="$GOPATH:${go-gir-generator}/share/gocode"
    GOPATH="$GOPATH:${go-lib}/share/gocode"
    make -C go/src/${goPackagePath}
    runHook postBuild
  '';

  installPhase = ''
    make install DESTDIR="$out" PREFIX="/" -C go/src/${goPackagePath}
  '';

  meta = with lib; {
    description = "DDE API provides some dbus interfaces that is used for screen zone detecting, thumbnail generating, sound playing, etc";
    homepage = "https://github.com/linuxdeepin/dde-api";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
