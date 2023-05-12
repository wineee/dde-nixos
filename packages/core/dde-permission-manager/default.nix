{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, wrapQtAppsHook
, qtbase
, dtkwidget
, polkit-qt
}:

stdenv.mkDerivation rec {
  pname = "dde-permission-manager";
  version = "1.0.5.999";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "b31de4a2ee2e7e6cb88e1146d36f3dd814fdb513";
    sha256 = "sha256-SMJ3xNNpMVEcs2mQO6inD+YXY9X5aun/1bKO2nmzfEo=";
  };

  postPatch = ''
    substituteInPlace src/{permissionpolicy.cpp,settings.cpp} \
      files/systemd/dde-permission-manager.service \
      --replace "/usr" "$out"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    dtkwidget
    polkit-qt
  ];

  meta = with lib; {
    description = "Permission manager for DDE";
    homepage = "https://github.com/linuxdeepin/dde-permission-manager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
