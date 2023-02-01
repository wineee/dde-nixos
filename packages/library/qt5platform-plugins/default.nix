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
  version = "5.6.4";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-1EQomcJixq5I6AntpRP2UMqvvn7j38Z80y6nFDiXxDM=";
  };

  # patches = [
  #   ./0001-chore-find-wayland-scanner-by-pkg-config.patch
  # ];

  ## https://github.com/linuxdeepin/qt5platform-plugins/pull/119 
  postPatch = ''
    rm -r xcb/libqt5xcbqpa-dev/
    mkdir -p xcb/libqt5xcbqpa-dev/${qtbase.version}
    cp -r ${qtbase.src}/src/plugins/platforms/xcb/*.h xcb/libqt5xcbqpa-dev/${qtbase.version}/
  '';

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
  };
}
