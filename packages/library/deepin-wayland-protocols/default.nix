{ stdenv
, stdenvNoCC
, lib
, fetchpatch
, getUsrPatchFrom
, pkg-config
, fetchFromGitHub
, cmake
, wayland
, qtbase
, qttools
, wrapQtAppsHook
, extra-cmake-modules
, plasma-wayland-protocols
}:
let
  patchList = {
  };

in
stdenv.mkDerivation rec {
  pname = "deepin-wayland-protocols";
  version = "1.6.0-deepin.1.1";

  src = fetchFromGitHub {
    owner = "justforlxz";
    repo = pname;
    rev = version;
    sha256 = "";
  };

  patches = [
  ];

  postPatch = getUsrPatchFrom patchList + ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  # buildInputs = [ plasma-wayland-protocols wayland wayland-protocols ];
  
  propagatedBuildInputs = [ qtbase ];

  NIX_CFLAGS_COMPILE = [
  ];

  cmakeFlags = [
  ];

  postFixup = ''
    wrapProgram $out/bin/kwin_no_scale \
      --set QT_QPA_PLATFORM_PLUGIN_PATH "${placeholder "out"}/${qtbase.qtPluginPrefix}"
  '';
  ## FIXME: why cann't use --prefix

  meta = with lib; {
    description = "KWin configuration for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-kwin";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
