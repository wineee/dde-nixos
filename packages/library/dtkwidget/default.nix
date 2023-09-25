{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtkcore
, dtkgui
, dtkcommon
, pkg-config
, cmake
, qttools
, qtbase
, qtmultimedia
, qtsvg
, qtx11extras
, doxygen
, wrapQtAppsHook
, cups
, gsettings-qt
, libstartup_notification
, xorg
}:

stdenv.mkDerivation rec {
  pname = "dtkwidget";
  version = "5.6.17";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-oFmM0e7ht3lCL50pwS/v/BLFmT2jymQaUZ4SmLdxvMo=";
  };

  outputs = [ "out" "doc" ];

  postPatch = ''
    substituteInPlace src/widgets/dapplication.cpp \
      --replace "auto dataDirs = DStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);" \
                "auto dataDirs = DStandardPaths::standardLocations(QStandardPaths::GenericDataLocation) << \"$out/share\";"
  '';

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
    doxygen
  ];

  buildInputs = [
    qtbase
    qtmultimedia
    qtsvg
    qtx11extras
    cups
    gsettings-qt
    libstartup_notification
    xorg.libXdmcp
  ];

  propagatedBuildInputs = [ dtkgui ];

  cmakeFlags = [
    "-DDTK_VERSION=${version}"
    "-DBUILD_DOCS=ON"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
    "-DQCH_INSTALL_DESTINATION=${placeholder "doc"}/${qtbase.qtDocPrefix}"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ];

  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${qtbase.bin}/${qtbase.qtPluginPrefix}
  '';

  meta = with lib; {
    description = "Deepin graphical user interface library";
    homepage = "https://github.com/linuxdeepin/dtkwidget";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
