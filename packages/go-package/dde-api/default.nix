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
, deepin-desktop-base
, buildGoModule
}:

buildGoModule rec {
  pname = "dde-api";
  version = "6.0.7";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "e46a1f75f1902339daf07ab5c50ad1dee05d9c2b";
    sha256 = "sha256-wnfyo8nXr+c3DRS8oOzQMDIqtuDp+0kw+BFDFasMYvQ=";
  };

  vendorHash = "sha256-ggcBI8KwvgAQZhAfwCIJaqt7wUAd2lPYYdiJIGetsXo=";

  patches = [ ./0001-fix-PATH-for-NixOS.patch ];

  postPatch = ''
    substituteInPlace lang_info/lang_info.go \
      --replace "/usr/share/i18n/language_info.json" "${deepin-desktop-base}/share/i18n/language_info.json"

    substituteInPlace misc/systemd/system/deepin-shutdown-sound.service \
      --replace "/usr/bin/true" "${coreutils}/bin/true"

    substituteInPlace sound-theme-player/main.go \
      --replace "/usr/sbin/alsactl" "alsactl"

    substituteInPlace misc/scripts/deepin-boot-sound.sh \
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
    make
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

  meta = with lib; {
    description = "Dbus interfaces used for screen zone detecting, thumbnail generating, sound playing, etc";
    homepage = "https://github.com/linuxdeepin/dde-api";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
