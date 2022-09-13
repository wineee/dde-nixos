{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, getUsrPatchFrom
, dtk
, cmake
, pkgconfig
, wrapQtAppsHook
}:
let
  ## TODO src/launcherlib/booster.cpp ...
  patchList = {
    "src/booster-dtkwidget/CMakeLists.txt" = [ ];
    "src/booster-desktop/CMakeLists.txt" = [ ];
    "src/booster-generic/CMakeLists.txt" = [ ];
  };
in
stdenv.mkDerivation rec {
  pname = "deepin-turbo";
  version = "0.0.6.3";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-t6/Ws/Q8DO0zBzrUr/liD61VkxbOv4W4x6VgMWr+Ozk=";
  };

  # patches = [
  #   (fetchpatch {
  #     name = "chore: use GNUInstallDirs in CmakeLists";
  #     url = "https://github.com/linuxdeepin/deepin-turbo/commit/f39073668e54e06264ee9570d912ce6fc0082e31.patch";
  #     sha256 = "sha256-vEQUborOhHXxWgmaXeOcCop9RkzKFbXXfNOKiSxMPSs=";
  #   })
  # ];

  nativeBuildInputs = [
    cmake
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [ dtk ];

  postPatch = getUsrPatchFrom patchList;

  meta = with lib; {
    description = "A daemon that helps to launch applications faster";
    homepage = "https://github.com/linuxdeepin/deepin-turbo";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
