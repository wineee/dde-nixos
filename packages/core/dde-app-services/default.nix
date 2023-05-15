{ stdenv
, lib
, fetchFromGitHub
, dtkwidget
, qt5integration
, qt5platform-plugins
, cmake
, wrapQtAppsHook
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "dde-app-services";
  version = "1.0.20";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "7fcf4db70bc2d48f96218f79d35bb75c635c6ee9";
    sha256 = "sha256-GpFr878JIrDPI3EjMJFwwOW81Suw0GHuYYl0S/AI+R0=";
  };

  postPatch = ''
    substituteInPlace dconfig-center/dde-dconfig-daemon/services/org.desktopspec.ConfigManager.service \
      --replace "/usr/bin/dde-dconfig-daemon" "$out/bin/dde-dconfig-daemon"
    substituteInPlace dconfig-center/dde-dconfig/main.cpp \
      --replace "/bin/dde-dconfig-editor" "dde-dconfig-editor"
    substituteInPlace dconfig-center/CMakeLists.txt \
      --replace 'add_subdirectory("example")' " " \
      --replace 'add_subdirectory("tests")'   " "

    substituteInPlace dconfig-center/dde-dconfig-daemon/services/dde-dconfig-daemon.service \
      --replace "/usr/bin" "$out/bin" \
      --replace "/usr/share" "/run/current-system/sw/share"
  '';

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    qt5integration
    qt5platform-plugins
  ];

  cmakeFlags = [
    "-DDVERSION=${version}"
    "-DDSG_DATA_DIR=/run/current-system/sw/share/dsg"
  ];

  meta = with lib; {
    description = "Provids dbus service for reading and writing DSG configuration";
    homepage = "https://github.com/linuxdeepin/dde-app-services";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}