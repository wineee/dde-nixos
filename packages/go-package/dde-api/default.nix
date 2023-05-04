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
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "Decodetalkers";
    repo = pname;
    rev = "2f094c1b6e7828cde169b721eb379e85f397adb5";
    sha256 = "sha256-pZ411y4o/aFP77lOdfOskOsEtgNcTiEIWdFT0JvGLR8=";
  };

  vendorHash = "sha256-Zkro4j4eqbLv3YQGJW2FfVM7Ot91zBhne+Fm0A38Exw=";

  patches = [ ./0001-fix-PATH-for-NixOS.patch ];

  goDeps = ./deps.nix;

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

  doCheck = false;

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Dbus interfaces used for screen zone detecting, thumbnail generating, sound playing, etc";
    homepage = "https://github.com/linuxdeepin/dde-api";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
