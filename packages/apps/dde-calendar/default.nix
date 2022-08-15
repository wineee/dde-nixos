{ stdenv
, lib
, fetchFromGitHub
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, cmake
, qttools
, pkgconfig
, wrapQtAppsHook
, runtimeShell
, gtest
}:

stdenv.mkDerivation rec {
  pname = "dde-calendar";
  version = "5.8.29";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-2J8AvXugOhcsipMvkqJ0SsgIQcXqLe2KgJIDNQC3dzI=";
  };

  fixInstallPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX /usr)" "set(CMAKE_INSTALL_PREFIX /)" \
      --replace "ADD_SUBDIRECTORY(tests)" ""

    substituteInPlace calendar-client/CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX /usr)" "set(CMAKE_INSTALL_PREFIX /)" \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "share/deepin-manual/manual-assets/application/)"

    substituteInPlace calendar-service/CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX /usr)" "set(CMAKE_INSTALL_PREFIX /)"
  '';

  fixServicePath = ''
    substituteInPlace calendar-service/assets/data/com.dde.calendarserver.calendar.service \
      --replace "/bin/bash" "${runtimeShell}"
    substituteInPlace calendar-service/assets/dde-calendar-service.desktop \
      --replace "/bin/bash" "${runtimeShell}"

    substituteInPlace calendar-service/assets/data/com.deepin.dataserver.Calendar.service \
      --replace "/usr/lib/deepin-daemon/dde-calendar-service" "$out/lib/deepin-daemon/dde-calendar-service" 
    substituteInPlace calendar-client/assets/dbus/com.deepin.Calendar.service \
      --replace "/usr/bin/dde-calendar" "$out/bin/dde-calendar"
  '';

  fixCodePath = ''
    substituteInPlace calendar-service/src/dbmanager/huanglidatabase.cpp \
      --replace "/usr/share/dde-calendar/data/huangli.db" "$out/share/dde-calendar/data/huangli.db"
    substituteInPlace calendar-service/src/main.cpp \
      --replace "/usr/share/dde-calendar/translations" "$out/share/dde-calendar/translations"
    substituteInPlace calendar-service/src/csystemdtimercontrol.cpp \
      --replace "/bin/bash" "${runtimeShell}"
    substituteInPlace calendar-service/src/jobremindmanager.cpp \
      --replace "/bin/bash" "${runtimeShell}"
  '';

  postPatch = fixInstallPatch + fixServicePath + fixCodePath;

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    gtest
    qt5integration
    qt5platform-plugins
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  installFlags = [ "DESTDIR=$(out)" ];

  # qtWrapperArgs = [
  #   "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
  #   "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  # ];

  postFixup = ''
    wrapQtApp $out/lib/deepin-daemon/dde-calendar-service
  '';

  meta = with lib; {
    description = "Calendar for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/deepin-calendar";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
