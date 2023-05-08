{ stdenv
, lib
, fetchFromGitHub
, buildGoModule
, wrapQtAppsHook
, wrapGAppsHook
, pkg-config
, alsa-lib
, bc
, blur-effect
, deepin-gettext-tools
, fontconfig
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
, deepin-desktop-base
}:

buildGoModule rec {
  pname = "dde-api";
  version = "6.0.6.p7";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "e9fd08ffcc41c86b08f4a2fdd88240ad81200191";
    sha256 = "sha256-OoPpnjpVetLcbgz6cKLdr0o9iWuaBsYel2P34B6xZBQ=";
  };

  vendorHash = "sha256-ggcBI8KwvgAQZhAfwCIJaqt7wUAd2lPYYdiJIGetsXo=";

  postPatch = ''
    substituteInPlace misc/systemd/system/deepin-shutdown-sound.service \
      --replace "/usr/bin/true" "${coreutils}/bin/true"

    substituteInPlace sound-theme-player/main.go \
      --replace "/usr/sbin/alsactl" "alsactl"

    substituteInPlace misc/{scripts/deepin-boot-sound.sh,systemd/system/deepin-login-sound.service} \
     --replace "/usr/bin/dbus-send" "${dbus}/bin/dbus-send"

    substituteInPlace lunar-calendar/huangli.go adjust-grub-theme/main.go \
      --replace "/usr/share/dde-api" "$out/share/dde-api"

    substituteInPlace themes/{theme.go,settings.go} \
      --replace "/usr/share" "/run/current-system/sw/share"

    for file in $(grep "/usr/lib/deepin-api" * -nR |awk -F: '{print $1}')
    do
      sed -i 's|/usr/lib/deepin-api|/run/current-system/sw/lib/deepin-api|g' $file
    done
  '';

  nativeBuildInputs = [
    pkg-config
    deepin-gettext-tools
    wrapQtAppsHook
    wrapGAppsHook
  ];
  dontWrapGApps = true;

  buildInputs = [
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
    make GOBUILD_OPTIONS="$GOFLAGS"
    runHook postBuild
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall
    make install DESTDIR="$out" PREFIX="/"
    runHook postInstall
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
    maintainers = teams.deepin.members;
  };
}
