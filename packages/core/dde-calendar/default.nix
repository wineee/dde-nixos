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
  version = "5.10.0.999";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "a5595bfbea2c757d8640924421d502b24e255586";
    hash = "sha256-K+Rcpl0prMtsiUO+mzqZIsjc6bkjVBRpafYIbwvV02A=";
  };

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
    qt5integration
    qt5platform-plugins
    dde-qt-dbus-factory
    libical
    sqlite
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  strictDeps = true;

  meta = with lib; {
    description = "Calendar for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-calendar";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}