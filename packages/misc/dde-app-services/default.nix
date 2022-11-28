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
    "dconfig-center/dde-dconfig/main.cpp" = [
      [ "/bin/dde-dconfig-editor" "dde-dconfig-editor" ]
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-app-services";
  version = "0.0.20";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-M9XXNV3N4CifOXitT6+UxaGsLoVuoNGqC5SO/mF+bLw=";
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
