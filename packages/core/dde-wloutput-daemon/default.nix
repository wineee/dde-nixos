{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, cmake
, extra-cmake-modules
, pkg-config
, wrapQtAppsHook
, wayland-scanner
, dtkgui
, dwayland
, wayland
, wayland-protocols
, deepin-wayland-protocols
}:

stdenv.mkDerivation rec {
  pname = "dde-wloutput-daemon";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-WJjsZIgaK4mNN8y6P5XuELMtSgFNVKyLOHWng9eNnFs=";
  };

  postPatch = ''
    substituteInPlace misc/org.deepin.dde.KWayland1.service \
      --replace "/usr" "$out"

    substituteInPlace CMakeLists.txt --replace "test" " "
  '';

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
    wrapQtAppsHook
    wayland-scanner
  ];

  buildInputs = [
    dtkgui
    dwayland
    wayland
  ];
  enableParallelBuilding =false;

  # cmakeFlags = [
  #   "-DDSG_DATA_DIR=/run/current-system/sw/share/dsg"
  # ];

  meta = with lib; {
    description = "A daemon for display settings in DDE Wayland";
    homepage = "https://github.com/linuxdeepin/dde-wloutput-daemon";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
