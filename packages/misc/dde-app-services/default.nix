{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, replaceAll
, dtk
, cmake
, wrapQtAppsHook
, qt5integration
, qtbase
}:
stdenv.mkDerivation rec {
  pname = "dde-app-services";
  version = "0.0.20";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-M9XXNV3N4CifOXitT6+UxaGsLoVuoNGqC5SO/mF+bLw=";
  };

  postPatch = replaceAll "/usr/share" "/run/current-system/sw/share" + ''
    substituteInPlace dconfig-center/dde-dconfig-daemon/services/org.desktopspec.ConfigManager.service \
      --replace "/usr" "$out"
    substituteInPlace dconfig-center/dde-dconfig/main.cpp \
      --replace "/bin/dde-dconfig-editor" "dde-dconfig-editor"
    substituteInPlace dconfig-center/CMakeLists.txt \
      --replace 'add_subdirectory("example")' " " \
      --replace 'add_subdirectory("tests")'   " "
  '';

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  buildInputs = [ dtk ];

  cmakeFlags = [
    "-DDVERSION=${version}"
    "-DDSG_DATA_DIR=/run/current-system/sw/share/dsg"  
  ];

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
