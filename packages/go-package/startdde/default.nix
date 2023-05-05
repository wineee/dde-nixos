{ stdenv
, lib
, buildGoModule
, fetchFromGitHub
, pkg-config
, gettext
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
, dde-polkit-agent
, gnome
, pciutils
, fetchpatch
}:

buildGoModule rec {
  pname = "startdde";
  version = "6.0.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "5e3fb76061821312b5901822a45347d28a4a436a";
    hash = "sha256-JhqN2r6r2kwzGR7Y9lkcq65GXPG0UBSPl+jQAWUukh4=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/linuxdeepin/startdde/commit/0e999151695d49bc550d9801ad65739e71cc82dd.patch";
      sha256 = "sha256-cMdJjIo/VQB6dK0knQaVxktIRLHl0Fuy4G/rRcu8smM=";
    })
  ];

  vendorHash = "sha256-QfZcLvymjZVK6CUnsvGPVtT/a0dLuhqnJQQe777/EIE=";

  postPatch = ''
    substituteInPlace display/manager.go session.go \
      --replace "/bin/bash" "${runtimeShell}"
    substituteInPlace display/manager.go main.go utils.go session.go \
      --replace "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"
    substituteInPlace misc/auto_launch/{default.json,chinese.json} \
      --replace "/usr/lib/polkit-1-dde/dde-polkit-agent" "${dde-polkit-agent}/lib/polkit-1-dde/dde-polkit-agent"
    substituteInPlace startmanager.go launch_group.go memchecker/config.go \
      --replace "/usr/share/startdde" "$out/share/startdde"
    substituteInPlace misc/lightdm.conf --replace "/usr" "$out"
  '';

  nativeBuildInputs = [
    gettext
    pkg-config
    jq
    wrapGAppsHook
    glib
  ];

  buildInputs = [
    libgnome-keyring
    gtk3
    alsa-lib
    pulseaudio
    libgudev
    libsecret
  ];

  buildPhase = ''
    runHook preBuild
    make GO_BUILD_FLAGS="$GOFLAGS"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make install DESTDIR="$out" PREFIX="/"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Starter of deepin desktop environment";
    homepage = "https://github.com/linuxdeepin/startdde";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
