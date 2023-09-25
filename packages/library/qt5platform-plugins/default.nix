{ stdenv
, lib
, fetchFromGitHub
, cmake
, extra-cmake-modules
, pkg-config
, dtkcommon
, qtbase
, qtx11extras
, mtdev
, cairo
, xorg
, libuuid
, libglvnd
, libxkbcommon
, qtwayland
, dwayland
, wayland
, waylandSupport ? false
, fetchpatch
}:

stdenv.mkDerivation rec {
  pname = "qt5platform-plugins";
  version = "5.6.16";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-1/biT8wR44+sdOMhBW/8KMUSBDK/UxuEqsyjTZyjBT4=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
  ];

  buildInputs = [
    dtkcommon
    mtdev
    cairo
    qtbase
    qtx11extras
    xorg.libSM
    xorg.libXdmcp
    xorg.libxcb
    xorg.libXi
    xorg.libX11
    xorg.xcbutilwm

    libuuid
    libglvnd
    libxkbcommon
  ] ++ lib.optionals waylandSupport [
    qtwayland
    dwayland
    wayland
  ];

  patches = [
    (fetchpatch {
      url = "https://github.com/linuxdeepin/qt5platform-plugins/commit/d7f6230716a0ff5ce34fc7d292ec0af5bbac30e4.patch";
      hash = "sha256-RY2+QBR3OjUGBX4Y9oVvIRY90IH9rTOCg8dCddkB2WE=";
    })
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace "add_subdirectory(wayland)" " "
  '';

  cmakeFlags = [
    "-DINSTALL_PATH=${placeholder "out"}/${qtbase.qtPluginPrefix}/platforms"
    "-DQT_XCB_PRIVATE_HEADERS=${qtbase.src}/src/plugins/platforms/xcb"
  ] ++ lib.optional (!waylandSupport) [ 
  ];

  #NIX_CFLAGS_COMPILE = lib.optional waylandSupport [
  #  "-I${wayland.dev}/include"
  #];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "Qt platform plugins for DDE";
    homepage = "https://github.com/linuxdeepin/qt5platform-plugins";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
