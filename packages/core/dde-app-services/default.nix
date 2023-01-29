{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, replaceAll
, dtkwidget
, cmake
, wrapQtAppsHook
, qt5integration
, qt5platform-plugins
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

  postPatch = replaceAll "/usr/share/dsg" "/run/current-system/sw/share/dsg" + ''
    substituteInPlace dconfig-center/dde-dconfig-daemon/services/org.desktopspec.ConfigManager.service \
      --replace "/usr/bin/dde-dconfig-daemon" "$out/bin/dde-dconfig-daemon"
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

  buildInputs = [ dtkwidget ];

  cmakeFlags = [
    "-DDVERSION=${version}"
    "-DDSG_DATA_DIR=/run/current-system/sw/share/dsg"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "Provids dbus service for reading and writing DSG configuration";
    homepage = "https://github.com/linuxdeepin/dde-app-services";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
