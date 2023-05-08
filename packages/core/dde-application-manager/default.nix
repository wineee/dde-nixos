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
, xorg
, iconv
}:

stdenv.mkDerivation rec {
  pname = "dde-application-manager";
  version = "1.0.12";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "233cc0db3db8da74a528cf180f97c52391d1aafd";
    sha256 = "sha256-JtcEHE6tL8Kk+Hif3Myo4hFdrq1ltflzK+VLR1oZE4k=";
  };

  ## TODO
  postPatch = ''
    substituteInPlace src/modules/mimeapp/mime_app.cpp src/modules/launcher/common.h src/service/main.cpp \
      src/modules/dock/common.h \
      --replace "/usr/share" "/run/current-system/sw/share"

    substituteInPlace src/lib/dlocale.cpp --replace "/usr/share/locale/locale.alias" "${iconv}/share/locale/locale.alias"

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
    dtkwidget
    gsettings-qt
    libcap
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
