{ stdenv
, lib
, fetchFromGitHub
, getPatchFrom
, dtk
, cmake
, wrapQtAppsHook
, gtest
}:
let
  patchList = {
    ### INSTALL
    "dconfig-center/dde-dconfig-editor/CMakeLists.txt" = [ ];
    "dconfig-center/dde-dconfig-daemon/CMakeLists.txt" = [ ];
    "dconfig-center/dde-dconfig/CMakeLists.txt" = [ ];

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
  version = "0.0.15";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-aDgq36E2+hCin5L2xQMuoyCu/sUAMnxXYa37iPuyT2k=";
  };

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    gtest
  ];

  postPatch = getPatchFrom patchList;

  meta = with lib; {
    description = "Provids dbus service for reading and writing DSG configuration";
    homepage = "https://github.com/linuxdeepin/dde-app-services";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
