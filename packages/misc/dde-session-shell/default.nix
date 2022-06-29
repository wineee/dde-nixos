{ stdenv
, lib
, fetchFromGitHub
, getPatchFrom
, dtk
, dde-qt-dbus-factory
, cmake
, pkg-config
, qttools
, qtx11extras
, wrapQtAppsHook
, gsettings-qt
, lightdm_qt
, linux-pam
, xorg
, kwayland
, gtest
}:
let
  patchList = {
    ## INSTALL
    "CMakeLists.txt" = [ [ "/etc" "$out/etc" ] ];
    "cmake/DdeSessionShellConfig.cmake" = [ ];
    ## TODO patch code
  };
in
stdenv.mkDerivation rec {
  pname = "dde-session-shell";
  version = "unstable-2022-06-28";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "3bb0835a39606326fdefdf671e36f326a6ac06cf";
    sha256 = "sha256-mEYD9gC46pGufqjSCjyrLtZWn6u3ALFTjnBhL3FIs2o=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    gsettings-qt
    lightdm_qt
    qtx11extras
    linux-pam
    kwayland
    xorg.libXcursor
    xorg.libXtst
    xorg.libXrandr
    gtest
  ];

  postPatch = getPatchFrom patchList;

  meta = with lib; {
    description = "Deepin desktop-environment - session-shell module";
    homepage = "https://github.com/linuxdeepin/dde-session-shell";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
