{ stdenv
, lib
, fetchFromGitHub
, dtkgui
, pkg-config
, cmake
, qttools
, wrapQtAppsHook
, qtdeclarative
, qtquickcontrols2
, doxygen
, qtbase
, qt5integration
, qt5platform-plugins
, qtgraphicaleffects
, fetchpatch
}:

stdenv.mkDerivation rec {
  pname = "dtkdeclarative";
  version = "5.6.8";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-L7xZGPDsT5C/ssQrV7BTk3kvGMvqTeLaoXambrARd18=";
  };

  postPatch = ''
    substituteInPlace chameleon/CMakeLists.txt \
      --replace "''${_qt5Core_install_prefix}/bin/qmlcachegen" "${qtdeclarative.dev}/bin/qmlcachegen"
  '';

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
    qtdeclarative.dev

    doxygen
    qttools.dev
  ];

  buildInputs = [
    qt5integration
    qt5platform-plugins # for examples
  ];

  propagatedBuildInputs = [ 
    dtkgui
    qtdeclarative
    qtquickcontrols2
    qtgraphicaleffects
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
    "-DBUILD_DOCS=ON"
    "-DBUILD_EXAMPLES=ON"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
    "-DQCH_INSTALL_DESTINATION=${qtbase.qtDocPrefix}"
    "-DQML_INSTALL_DIR=${qtbase.qtQmlPrefix}"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ];

  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${qtbase.bin}/${qtbase.qtPluginPrefix}
    export QML2_IMPORT_PATH=${qtdeclarative.bin}/${qtbase.qtQmlPrefix}
  '';

  meta = with lib; {
    description = "A widget development toolkit based on QtQuick/QtQml";
    homepage = "https://github.com/linuxdeepin/dtkdeclarative";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
