{ stdenv
, lib
, getPatchFrom
, pkg-config
, fetchFromGitHub
, cmake
, kwin
, kwayland
, qttools
}:
let
  patchList = {
    "CMakeLists.txt" = [
      # TODO
      ["/usr/include/KWaylandServer" "${kwayland.dev}/include/KWaylandServer"]
      ["/usr/local/include/KWaylandServer" ""]
    ];
    "configures/CMakeLists.txt" = [
      [ "/etc/xdg" "$out/etc/xdg" ]
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-kwin";
  version = "5.4.26";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-j/dgGt5zNaVHZF+DrEK8aRdYanPxcvePwqKmc7KM8gk=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    #deepin-gettext-tools
    #extra-cmake-modules
    pkg-config
  ];

  buildInputs = [
    kwin
    kwayland
  ];

  dontWrapQtApps = true;

  #NIX_CFLAGS_COMPILE = [
  #  "-I${kwayland.dev}/include/KF5"
  #];

  cmakeFlags = [
    "-DKWIN_VERSION=${kwin.version}"
  ];

  postPatch = getPatchFrom patchList;

  meta = with lib; {
    description = "KWin configuration for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-kwin";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
