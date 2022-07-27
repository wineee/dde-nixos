{ stdenv
, lib
, getPatchFrom
, getShebangsPatchFrom
, pkg-config
, fetchFromGitHub
, cmake
, kwin_23
, kwayland
, qttools
, deepin-gettext-tools
, extra-cmake-modules
, dtk
, gsettings-qt
, xorg
, libepoxy
}:
let
  patchList = {
    ### BUILD
    "translate_desktop2ts.sh" = [
      [ "/usr/bin/deepin-desktop-ts-convert" "deepin-desktop-ts-convert" ]
    ];
    "translate_ts2desktop.sh" = [
      [ "/usr/bin/deepin-desktop-ts-convert" "deepin-desktop-ts-convert" ]
    ];
    ### INSTALL
    "CMakeLists.txt" = [
      # TODO
      [ "/usr/include/KWaylandServer" "${kwayland.dev}/include/KWaylandServer" ]
      [ "/usr/local/include/KWaylandServer" "" ]
    ];
    "configures/CMakeLists.txt" = [
      [ "/etc/xdg" "$out/etc/xdg" ]
    ];
    "configures/kwin_no_scale.in" = [
      [ "kwin 5.21.5" "kwin ${kwin_23.version}" ] # TODO
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

  patches = [
    ./dde-kwin.5.4.26.patch
    ./deepin-kwin-tabbox-chameleon-rename.patch
  ];

  postPatch = ''
    patch -Rp1 -i ${./deepin-kwin-added-functions-from-their-forked-kwin.patch}
  '' + getPatchFrom patchList + getShebangsPatchFrom [
    "configures/kwin_no_scale.in"
    "translate_desktop2ts.sh"
    "translate_ts2desktop.sh"
    "plugins/platforms/plugin/translate_generation.sh"
  ];

  nativeBuildInputs = [
    cmake
    qttools
    deepin-gettext-tools
    extra-cmake-modules
    pkg-config
  ];

  buildInputs = [
    kwin_23
    kwayland
    dtk
    gsettings-qt
    xorg.libXdmcp
    libepoxy.dev
  ];

  dontWrapQtApps = true;

  NIX_CFLAGS_COMPILE = [
   "-I${kwayland.dev}/include/KF5"
  ];

  cmakeFlags = [
    "-DPROJECT_VERSION=${version}"
    "-DKWIN_VERSION=${kwin_23.version}"
    "-DUSE_WINDOW_TOOL=OFF"
    "-DENABLE_BUILTIN_BLUR=OFF"
    "-DENABLE_KDECORATION=OFF" #TODO
    "-DENABLE_BUILTIN_MULTITASKING=OFF"
    "-DENABLE_BUILTIN_BLACK_SCREEN=OFF"
    "-DUSE_DEEPIN_WAYLAND=OFF"

    "-DENABLE_BUILTIN_SCISSOR_WINDOW=OFF" # TODO
  ];

  meta = with lib; {
    description = "KWin configuration for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-kwin";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
