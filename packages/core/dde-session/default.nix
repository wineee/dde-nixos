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
    substituteInPlace src/dde-session/impl/sessionmanager.cpp systemd/dde-session-daemon.target.wants/dde-osd.service \
      --replace 'file.readAll().startsWith("/usr/bin/dde-lock")' 'file.readAll().contains("dde-dock")' \
      --replace "/usr/lib/deepin-daemon" "/run/current-system/sw/libexec/deepin-daemon" 

    for file in $(grep -rl "/usr/bin"); do
      substituteInPlace $file \
        --replace "/usr/bin" ""
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

  meta = with lib; {
    description = "New deepin session, based on systemd and existing projects";
    homepage = "https://github.com/linuxdeepin/dde-session";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
