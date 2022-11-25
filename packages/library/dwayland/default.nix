{ stdenv
, lib
, fetchFromGitHub
, cmake
, qtbase
, qtwayland
, wayland
, wayland-protocols
, extra-cmake-modules
, deepin-wayland-protocols
}:
stdenv.mkDerivation rec {
  pname = "dwayland";
  version = "5.24.3-deepin.1.3";

  src = fetchFromGitHub {
    owner = "justforlxz";
    repo = pname;
    rev = version;
    sha256 = "sha256-87Ih2IiOFGF4pXdZH+4VLa1c59PuuFuX3IEGuCmtKzA=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    qtbase
    qtwayland
    wayland
    wayland-protocols
    deepin-wayland-protocols
  ];
  
  dontWrapQtApps = true;

  meta = with lib; {
    description = "Qt-style API to interact with the wayland-client and wayland-server";
    homepage = "https://github.com/linuxdeepin/dwayland";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
