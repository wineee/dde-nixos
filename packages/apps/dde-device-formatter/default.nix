{ stdenv
, lib
, fetchFromGitHub
, getPatchFrom
, getShebangsPatchFrom
, dtk
, deepin-gettext-tools
, qt5integration
, qt5platform-plugins
, qmake
, qttools
, qtx11extras
, pkgconfig
, wrapQtAppsHook
, udisks2-qt5
, gtest
}:
let
  patchList = {
    ## BUILD
    "translate_ts2desktop.sh" = [
      [ "/usr/bin/deepin-desktop-ts-convert" "${deepin-gettext-tools}/bin/deepin-desktop-ts-convert" ]
    ];
    ## INSTALL
    "dde-device-formatter.pro" = [ ];
  };

  shebangsList = [
    "*.sh"
  ];
in
stdenv.mkDerivation rec {
  pname = "dde-device-formatter";
  version = "unstable-2022-06-27";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "b1232cca7a0f7ab24a352e78f96e5187d8ef1be5";
    sha256 = "sha256-U67CsbgcTBBLas+KxQv+2bCc3m90GUNYm+a3YGLYbeg=";
  };

  nativeBuildInputs = [
    qmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [ 
    dtk
    udisks2-qt5
    qtx11extras
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  postPatch = getShebangsPatchFrom shebangsList + getPatchFrom patchList;
  
  meta = with lib; {
    description = "Deepin desktop-environment - Launcher module";
    homepage = "https://github.com/linuxdeepin/dde-launcher";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
