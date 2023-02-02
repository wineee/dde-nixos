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
  version = "0.0.20.p2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "20f96230b97337ab061f2357813a195eb0f67b9c";
    sha256 = "sha256-bgpaAGgvYWaWCl6rLDI3BCnPQlJCYpdEk9mp/8731p8=";
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

  enableParallelBuilding = false;

  cmakeFlags = [
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
