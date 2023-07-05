{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, wrapQtAppsHook
, qtbase
, dtkcore
, gsettings-qt
, libsecret
, xorg
, systemd
, dde-polkit-agent
}:

stdenv.mkDerivation rec {
  pname = "dde-session";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "203de6b0e8fde5235106cc0605f3b941a99b4c28";
    hash = "sha256-nK29HhfoiEfXK8fPi/ODoJVyrVtEuoHzaIc22txXNjQ=";
  };

  postPatch = ''
    # Avoid using absolute path to distinguish applications
    substituteInPlace src/dde-session/impl/sessionmanager.cpp \
      --replace 'file.readAll().startsWith("/usr/bin/dde-lock")' 'file.readAll().contains("dde-dock")' \

    substituteInPlace systemd/dde-session-daemon.target.wants/dde-polkit-agent.service \
      --replace "/usr/lib/polkit-1-dde" "${dde-polkit-agent}/lib/polkit-1-dde"

    for file in $(grep -rl "/usr/lib/deepin-daemon"); do
      substituteInPlace $file --replace "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"
    done

    for file in $(grep -rl "/usr/bin"); do
      substituteInPlace $file --replace "/usr/bin/" "/run/current-system/sw/bin/"
    done
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    dtkcore
    gsettings-qt
    libsecret
    xorg.libXcursor
    systemd
  ];

  passthru.providedSessions = [ "dde-x11" "dde-wayland" ];

  meta = with lib; {
    description = "New deepin session, based on systemd and existing projects";
    homepage = "https://github.com/linuxdeepin/dde-session";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
