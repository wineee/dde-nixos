{ stdenv
, lib
, fetchFromGitHub
, qmake
, pkg-config
, qtbase
, qtx11extras
, wrapQtAppsHook
, mtdev
, cairo
, xorg
, qtwayland
, dwayland
, wayland
, waylandSupport ? true
}:

stdenv.mkDerivation rec {
  pname = "qt5platform-plugins";
  version = "5.6.12";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-ET/IRCmMTulV/4KWztnGFgs0Ej3hDheZFsIqh98fmV0=";
  };

  # patches = [
  #   ./0001-chore-find-wayland-scanner-by-pkg-config.patch
  # ];

  nativeBuildInputs = [ qmake pkg-config wrapQtAppsHook ];

  buildInputs = [
    mtdev
    cairo
    qtbase
    qtx11extras
    xorg.libSM
  ] ++ lib.optional waylandSupport [
    #qtwayland
    #dwayland
    wayland
  ];

  qmakeFlags = [
    "VERSION=${version}"
    "INSTALL_PATH=${placeholder "out"}/${qtbase.qtPluginPrefix}/platforms"
    "QT_XCB_PRIVATE_INCLUDE=${qtbase.src}/src/plugins/platforms/xcb"
  ] ++ lib.optional (!waylandSupport) [ 
    "CONFIG+=DISABLE_WAYLAND" 
  ];

  NIX_CFLAGS_COMPILE = lib.optional waylandSupport [
    "-I${wayland.dev}/include"
  ];

  enableParallelBuilding = false;

  meta = with lib; {
    description = "Qt platform plugins for DDE";
    homepage = "https://github.com/linuxdeepin/qt5platform-plugins";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
