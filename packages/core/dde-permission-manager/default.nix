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
, polkit-qt
}:

stdenv.mkDerivation rec {
  pname = "dde-permission-manager";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "7211761facc55ff70eab6f8b9e4120770a457ba1";
    sha256 = "sha256-seo3ppEod2KhoDcuOUTYMbZ6FNHQmGXvB1p3IJnFBr4=";
  };

  ## TODO
  postPatch = ''
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
