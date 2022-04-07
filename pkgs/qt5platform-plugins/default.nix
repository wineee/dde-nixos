{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
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
  version = "5.0.46";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-7zAkN6xX10XARCbSYPRl1qSn2vuuBM10CL7DvdjKEa0=";
  };

  nativeBuildInputs = [ qmake pkgconfig wrapQtAppsHook ];

  buildInputs = [
    mtdev
    cairo
    qtbase
    qtx11extras
    xorg.libSM
  ];

  patches = [
    (fetchpatch {
      url = "https://github.com/linuxdeepin/qt5platform-plugins/commit/71bbc04210b27bcd416da667291f77b762eaea80.patch";
      sha256 = "sha256-INuMWMPXPMLGO9IvEY9RHNAN2UnTFsTj3owUVMZRY2o=";
      name = "Add_support_for_Qt_5_15-3_patch";
    })
  ];

  noWaylandPatch = ''
    rm -r wayland
    sed -i '/wayland/d' qt5platform-plugins.pro
  '';

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
    + lib.optionalString (!waylandSupport) noWaylandPatch
    + lib.optionalString waylandSupport fixWaylandInstallPatch;

  meta = with lib; {
    description = "Qt platform plugins for DDE";
    homepage = "https://github.com/linuxdeepin/qt5platform-plugins";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
