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
, sqlite
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
    ./a.diff
  ];

  postPatch = ''
    for file in $(grep -rl "/bin/bash"); do
      substituteInPlace $file --replace "/bin/bash" "${runtimeShell}"
    done
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
    sqlite
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  # qt5integration must be placed before qtsvg in QT_PLUGIN_PATH
  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  # postFixup = ''
  #   wrapQtApp $out/lib/deepin-daemon/dde-calendar-service
  # '';

  strictDeps = true;

  meta = with lib; {
    description = "Calendar for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-calendar";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}