{ stdenv
, lib
, fetchFromGitHub
, replaceAll
, buildGoPackage
, getUsrPatchFrom
, wrapQtAppsHook
, wrapGAppsHook
, pkg-config
, alsa-lib
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
, util-linux
, xcur2png
, gdk-pixbuf-xlib
, dbus
, coreutils
}:
let
  share_to_sw = [ "/usr/share" "/run/current-system/sw/share" ];
  patchList = {
    "lunar-calendar/huangli.go" = [ ];
    "adjust-grub-theme/main.go" = [ ];
    "locale-helper/main.go" = [
      [ "/usr/local/sbin:" "PATH:/usr/local/sbin" ]
    ];
    "device/main.go" = [
      [ "/usr/local/sbin:" "PATH:/usr/local/sbin" ]
    ];
    "i18n_dependent/i18n_dependent.go" = [ share_to_sw ];
    "themes/theme.go" = [ share_to_sw ];
    "themes/settings.go" = [ share_to_sw ];
    "lang_info/lang_info.go" = [ share_to_sw ];
  };
in
buildGoPackage rec {
  pname = "dde-api";
  version = "5.5.32";

  goPackagePath = "github.com/linuxdeepin/dde-api";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-F+vEOSpysqVtjs8de5mCmeANuCbYUQ860ZHl5rwNYac=";
  };

  postPatch = replaceAll "/usr/lib/deepin-api" "/run/current-system/sw/lib/deepin-api"
      + replaceAll "/usr/bin/dbus-send" "${dbus}/bin/dbus-send"
      + replaceAll "/usr/bin/true" "${coreutils}/bin/true"
      + replaceAll "/usr/sbin/alsactl" "alsactl"
      + replaceAll "/usr/share/i18n" "/run/current-system/sw/share/i18n"
      + getUsrPatchFrom patchList;

  goDeps = ./deps.nix;

  nativeBuildInputs = [
    pkg-config
    deepin-gettext-tools
    wrapQtAppsHook
    wrapGAppsHook
  ];
  dontWrapGApps = true;

  buildInputs = [
    go-dbus-factory
    go-gir-generator
    go-lib

    alsa-lib
    gtk3
    libcanberra
    libgudev
    librsvg
    poppler
    pulseaudio
    gdk-pixbuf-xlib
  ];

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

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    for binary in $out/lib/deepin-api/*; do
      wrapProgram $binary "''${qtWrapperArgs[@]}"
    done
  '';

  meta = with lib; {
    description = "Dbus interfaces used for screen zone detecting, thumbnail generating, sound playing, etc";
    homepage = "https://github.com/linuxdeepin/dde-api";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
