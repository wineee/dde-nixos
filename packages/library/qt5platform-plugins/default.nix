{ stdenv
, lib
, fetchFromGitHub
, qmake
, pkgconfig
, qtbase
, qtx11extras
, wrapQtAppsHook
, mtdev
, cairo
, xorg
, waylandSupport ? false
}:

stdenv.mkDerivation rec {
  pname = "qt5platform-plugins";
  version = "5.0.69";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-5vwjK+Oc+GR6Ed40SMCdQsCut/wpIhOaTW7hsL1Y/no=";
  };

  ## https://github.com/linuxdeepin/qt5platform-plugins/pull/119 
  fixQtPatch = ''
    rm -r xcb/libqt5xcbqpa-dev/
    mkdir -p xcb/libqt5xcbqpa-dev/${qtbase.version}
    cp -r ${qtbase.src}/src/plugins/platforms/xcb/*.h xcb/libqt5xcbqpa-dev/${qtbase.version}/
  '';

  postPatch = fixQtPatch;

  nativeBuildInputs = [ qmake pkgconfig wrapQtAppsHook ];

  buildInputs = [
    mtdev
    cairo
    qtbase
    qtx11extras
    xorg.libSM
  ];

  qmakeFlags = [
    "VERSION=${version}"
    "INSTALL_PATH=${placeholder "out"}/${qtbase.qtPluginPrefix}/platforms"
  ] 
  ++ lib.optional (!waylandSupport) [ "CONFIG+=DISABLE_WAYLAND" ];

  meta = with lib; {
    description = "Qt platform plugins for DDE";
    homepage = "https://github.com/linuxdeepin/qt5platform-plugins";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
