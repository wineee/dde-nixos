{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, getUsrPatchFrom
, replaceAll
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

  postPatch = replaceAll "/usr/share" "/run/current-system/sw/share"
      + getUsrPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    gtest
  ];

  cmakeFlags = [ "-DDVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix XDG_DATA_DIRS : \"/run/current-system/sw/share\""
  ];

  meta = with lib; {
    description = "Provids dbus service for reading and writing DSG configuration";
    homepage = "https://github.com/linuxdeepin/dde-app-services";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
