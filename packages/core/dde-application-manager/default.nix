{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, wrapQtAppsHook
, qtbase
, dtkwidget
, dde-polkit-agent
, gsettings-qt
, libcap
, jemalloc
, xorg
, iconv
}:

stdenv.mkDerivation rec {
  pname = "dde-application-manager";
  version = "1.0.16";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-roEddgKQhe/lsal356ceUG5E3VDUFIbpJ5M+rSHDVnI=";
  };

  ## TODO
  postPatch = ''
    substituteInPlace src/modules/mimeapp/mime_app.cpp src/modules/launcher/common.h src/service/main.cpp \
      src/modules/dock/common.h \
      misc/dconf/com.deepin.dde.dock.json \
      misc/dconf/com.deepin.dde.appearance.json \
      --replace "/usr/share" "/run/current-system/sw/share"

    substituteInPlace src/lib/dlocale.cpp --replace "/usr/share/locale/locale.alias" "${iconv}/share/locale/locale.alias"

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
    dtkwidget
    gsettings-qt
    libcap
    jemalloc
    xorg.libXdmcp
    xorg.libXres
  ];

  meta = with lib; {
    description = "App manager for DDE";
    homepage = "https://github.com/linuxdeepin/dde-application-manager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
