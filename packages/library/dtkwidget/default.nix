{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, cmake
, pkg-config
, qttools
, doxygen
, wrapQtAppsHook
, dtkgui
, qtbase
, qtmultimedia
, qtsvg
, qtx11extras ? null
, cups
, gsettings-qt
, libstartup_notification
, xorg
}:

stdenv.mkDerivation rec {
  pname = "dtkwidget";
  version = "5.6.20";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-rYJl1NQ8YGf8auraqjG0IuYsI98ywKw5+3KezlW7MFM=";
  };

  patches = [
    ./fix-pkgconfig-path.patch
    ./fix-pri-path.patch
  ];

  postPatch = ''
    substituteInPlace src/widgets/dapplication.cpp \
      --replace "auto dataDirs = DStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);" \
                "auto dataDirs = DStandardPaths::standardLocations(QStandardPaths::GenericDataLocation) << \"$out/share\";"
  '';

  nativeBuildInputs = [
    cmake
    qttools
    doxygen
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtmultimedia
    qtsvg
    cups
    gsettings-qt
    libstartup_notification
    xorg.libXdmcp
  ] ++ lib.optionals (lib.versionOlder qtbase.version "6")  [
    qtx11extras
  ];

  propagatedBuildInputs = [ dtkgui ];

  cmakeFlags = [
    "-DDTK_VERSION=${if lib.versionAtLeast qtbase.version "6" then "6.0.0" else "5.6.20"}"
    "-DBUILD_DOCS=ON"
    "-DMKSPECS_INSTALL_DIR=${placeholder "dev"}/mkspecs/modules"
    "-DQCH_INSTALL_DESTINATION=${placeholder "doc"}/share/doc"
    "-DCMAKE_INSTALL_LIBEXECDIR=${placeholder "dev"}/libexec"
  ];

  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${lib.getBin qtbase}/${qtbase.qtPluginPrefix}
  '';

  outputs = [ "out" "dev" "doc" ];

  meta = with lib; {
    description = "Deepin graphical user interface library";
    homepage = "https://github.com/linuxdeepin/dtkwidget";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
