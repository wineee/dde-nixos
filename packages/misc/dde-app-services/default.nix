{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, getPatchFrom
, dtk
, cmake
, wrapQtAppsHook
, gtest
, qt5integration
, qtbase
}:
let
  patchList = {
    ### MISC
    "dconfig-center/dde-dconfig-daemon/services/org.desktopspec.ConfigManager.service" = [ ];

    ### CODE
    "dconfig-center/dde-dconfig-editor/oemdialog.cpp" = [
      [ "/etc/dsg" "/run/current-system/sw/share/dsg" ]
    ];
    "dconfig-center/dde-dconfig-daemon/dconfig_global.h" = [
      [ "/etc/dsg" "/run/current-system/sw/share/dsg" ]
      [ "/usr/share/dsg" "/run/current-system/sw/share/dsg" ]
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-app-services";
  version = "0.0.16";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-iPYjXWBSc9p8AwyylDEeIpnOpPynvnYlPhLhA1MP1fY=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/dde-app-services/commit/f6df6915fda2d360e44f0c941cc5dd7cece24ef0.patch";
      sha256 = "sha256-M1LjYRbkrngOKUqo7R5u0Gkf7CA+tvlNvx04RBVDE+g=";
    })
  ];

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    gtest
  ];

  postPatch = getPatchFrom patchList;

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "Provids dbus service for reading and writing DSG configuration";
    homepage = "https://github.com/linuxdeepin/dde-app-services";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
