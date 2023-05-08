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
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-4v9/Qq1cJITPwVgFYoW+1nTjN+pt4VGYcfvkgErvPwY=";
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
      substituteInPlace $file --replace "/usr/bin/" ""
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
