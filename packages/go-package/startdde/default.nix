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
, gnome
, pciutils
, dbus
}:

buildGoModule rec {
  pname = "startdde";
  version = "6.0.8";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-HvRt5lcCN+0HmVm0bXxx0/+bIM54v8LWH5V24uSPFwM=";
  };

  patches = [
    ./0001-avoid-use-hardcode-path.diff
    ./0002-search-in-XDG-directories.diff
    ./0003-add-adrg-xdg-for-gomod.diff
  ];

  vendorHash = "sha256-5BEOazAygYL1N+CaGAbUwdpHZ1EiHr6yNW27/bXNdZg=";

  postPatch = ''
    substituteInPlace display/manager.go session.go \
      --replace "/bin/bash" "${runtimeShell}"

    substituteInPlace misc/systemd_task/dde-display-task-refresh-brightness.service \
       --replace "/usr/bin/dbus-send" "${dbus}/bin/dbus-send"

    substituteInPlace display/manager.go utils.go session.go \
      --replace "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"

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
