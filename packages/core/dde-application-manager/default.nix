{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, wrapQtAppsHook
, dde-qt-dbus-factory
, qtbase
, qtx11extras
, dtkwidget
, dde-polkit-agent
, gsettings-qt
, libcap
, xorg
, gtest
}:

stdenv.mkDerivation rec {
  pname = "dde-application-manager";
  version = "1.0.12";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-79c/DwSpDfE21DOdQJsueo04OX82QNMU8wmhMFCiLlY=";
  };

  ## TODO
  postPatch = ''
    substituteInPlace src/modules/mimeapp/mime_app.cpp src/lib/basedir.cpp src/modules/mimeapp/mime_app.cpp \
      --replace "/usr/share" "/run/current-system/sw/share"

    for file in $(grep -rl "/usr/bin"); do
      substituteInPlace $file --replace "/usr/bin" ""
    done
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    #dde-qt-dbus-factory
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    #qtx11extras
    dtkwidget
    gsettings-qt
    libcap
    xorg.libXdmcp
    xorg.libXres
    #gtest
  ];

  meta = with lib; {
    description = "Desktop widgets service/implementation for DDE";
    homepage = "https://github.com/linuxdeepin/dde-application-manager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
