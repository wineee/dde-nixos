{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, getUsrPatchFrom
, dtk
, cmake
, wrapQtAppsHook
, gtest
, qt5integration
, qtbase
}:
let
  patchList = {
    "dconfig-center/dde-dconfig-daemon/services/org.desktopspec.ConfigManager.service" = [ ];
    "dconfig-center/dde-dconfig-daemon/dconfig_global.h" = [
      # "/etc/dsg" 
      [ "/usr/share/dsg" "/run/current-system/sw/share/dsg" ]
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-app-services";
  version = "0.0.19";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-cB9mA99eKx8NrBBIUfDr/jyLUfWmwaW7m3ssm22iCLs=";
  };

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    gtest
  ];

  postPatch = getUsrPatchFrom patchList;

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
