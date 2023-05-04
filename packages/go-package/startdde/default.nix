{ stdenv
, lib
, buildGoModule
, fetchFromGitHub
, getUsrPatchFrom
, replaceAll
, pkg-config
, go-dbus-factory
, go-gir-generator
, go-lib
, gettext
, dde-api
, libgnome-keyring
, gtk3
, alsa-lib
, pulseaudio
, libgudev
, libsecret
, jq
, glib
, wrapGAppsHook
, runtimeShell
, dde-daemon
, dde-polkit-agent
, gnome
, pciutils
}:

buildGoModule rec {
  pname = "startdde";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "wineee";
    repo = pname;
    rev = "0c727b96ce7c6c1554d8de5f1749964395339077";
    sha256 = "sha256-8Wbk2JOihNX4NhsxX7dXIZuN45PAM4G7M9Xd9IBNUJo=";
  };

  vendorSha256 = "sha256-M7T8zMV8uhPYxAfmdk7NuaF9YqhrGhFaZEq/FBI+VZg=";

  postPatch = replaceAll "/bin/bash" "${runtimeShell}"
    + replaceAll "/usr/bin/dde_wloutput" "dde-wloutput"
    + replaceAll "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon";


  nativeBuildInputs = [
    gettext
    pkg-config
    jq
    wrapGAppsHook
    glib
  ];

  buildInputs = [
    go-gir-generator
    libgnome-keyring
    gtk3
    alsa-lib
    pulseaudio
    libgudev
    libsecret
  ];

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    make install DESTDIR="$out" PREFIX="/"
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
