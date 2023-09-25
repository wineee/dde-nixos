{ stdenv
, lib
, fetchFromGitHub
, cmake
, qttools
, pkg-config
, wrapQtAppsHook
, dtkwidget
, dtkdeclarative
, qtbase
, qtdeclarative
, qtquickcontrols2
, appstream-qt
, kitemmodels
, qt5integration
}:

stdenv.mkDerivation rec {
  pname = "dde-launchpad";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-tWlh7BS+qUgzZIDGxI/giDZnU54jMtRxzRSOX76DAzk=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];
  dontWrapGApps = true;

  buildInputs = [
    dtkwidget
    dtkdeclarative
    qtbase
    qtdeclarative
    qtquickcontrols2
    appstream-qt
    kitemmodels
  ];

  cmakeFlags = [
    "-DSYSTEMD_USER_UNIT_DIR=${placeholder "out"}/lib/systemd/user"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "Deepin desktop-environment - Launcher module";
    homepage = "https://github.com/linuxdeepin/dde-launcher";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
