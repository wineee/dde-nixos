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
  version = "5.0.64";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-28sz1reexvqjBibQywpj+UaVSN9zXqyg9cXwPg/OF3s=";
  };

  nativeBuildInputs = [ qmake pkgconfig wrapQtAppsHook ];

  buildInputs = [
    mtdev
    cairo
    qtbase
    qtx11extras
    xorg.libSM
  ];

  qmakeFlags = lib.optional (!waylandSupport) [ "CONFIG+=DISABLE_WAYLAND" ];

  fixXcbInstallPatch = ''
    substituteInPlace xcb/xcb.pro \
      --replace "DESTDIR = \$\$_PRO_FILE_PWD_/../bin/plugins/platforms
    " "DESTDIR = $out/plugins/platforms"
  '';

  fixWaylandInstallPatch = ''
    substituteInPlace wayland/wayland-shell/wayland-shell.pro \
      --replace "DESTDIR = \$\$_PRO_FILE_PWD_/../../bin/plugins/wayland-shell-integration" "DESTDIR = $out/plugins/wayland-shell-integration"

    substituteInPlace wayland/dwayland/dwayland.pro \
      --replace "DESTDIR = \$\$_PRO_FILE_PWD_/../../bin/plugins/platforms" "DESTDIR = $out/plugins/platforms"
  '';

  postPatch = fixXcbInstallPatch
    + lib.optionalString waylandSupport fixWaylandInstallPatch;

  meta = with lib; {
    description = "Qt platform plugins for DDE";
    homepage = "https://github.com/linuxdeepin/qt5platform-plugins";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
