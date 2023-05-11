{ stdenv
, lib
, fetchFromGitHub
, cmake
, qttools
, pkg-config
, wrapQtAppsHook
, dtkwidget
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, qtbase
, qtsvg
, libical
, runtimeShell
}:

stdenv.mkDerivation rec {
  pname = "dde-calendar";
  version = "5.10.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-MRB4dzjOkdySRD01bMhYIVajz08xA3f3Srscrxc6wgU=";
  };

  patches = [
    ./0001-feat-avoid-use-hardcode-path.patch
  ];

  postPatch = ''
    substituteInPlace calendar-service/src/{csystemdtimercontrol.cpp,alarmManager/dalarmmanager.cpp,calendarDataManager/daccountmanagemodule.cpp} \
      calendar-service/assets/{data/com.dde.calendarserver.calendar.service,dde-calendar-service.desktop} \
      --replace "/bin/bash" "${runtimeShell}"
  '';

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    qtbase
    qtsvg
    qt5platform-plugins
    dde-qt-dbus-factory
    libical
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  # qt5integration must be placed before qtsvg in QT_PLUGIN_PATH
  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  postFixup = ''
    wrapQtApp $out/lib/deepin-daemon/dde-calendar-service
  '';

  strictDeps = true;

  meta = with lib; {
    description = "Calendar for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-calendar";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}