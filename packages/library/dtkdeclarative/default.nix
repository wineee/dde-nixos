{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, cmake
, pkg-config
, qttools
, doxygen
, wrapQtAppsHook
, qtbase
, dtkgui
, qtdeclarative
# qt5
, qtquickcontrols2 ? null
, qtgraphicaleffects ? null
# qt6
, qtshadertools ? null
, qt5compat ? null
}:

stdenv.mkDerivation rec {
  pname = "dtkdeclarative";
  version = "5.6.20";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-teI6KWjyK9GqWtK3O8ELuzAcCB2QmO5elzfe/FhcmJg=";
  };

  patches = [
    ./fix-pkgconfig-path.patch
    ./fix-pri-path.patch
    ./a.diff
     (fetchpatch {
      url = "https://github.com/linuxdeepin/dtkdeclarative/commit/a7c09ac55585df2e58627d99de71e86f455772a8.patch";
      hash = "sha256-fTLJKqXT5zO6PQWXuxJ0jLqCBkj9OXjzYn9ejanPqkc";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    doxygen
    qttools
    wrapQtAppsHook
  ];

  propagatedBuildInputs = [
    dtkgui
    qtbase
    qtdeclarative
    qtquickcontrols2
  ] ++ lib.optionals (lib.versionOlder qtbase.version "6") [
    qtquickcontrols2
    qtgraphicaleffects
  ] ++ lib.optionals (lib.versionAtLeast qtbase.version "6") [
    qtshadertools
    qt5compat
  ];

  cmakeFlags = [
    "-DDTK_VERSION=${if lib.versionAtLeast qtbase.version "6" then "6.0.0" else "5.6.20"}"
    "-DBUILD_DOCS=ON"
    "-DBUILD_EXAMPLES=ON"
    "-DMKSPECS_INSTALL_DIR=${placeholder "dev"}/mkspecs/modules"
    "-DQCH_INSTALL_DESTINATION=${placeholder "doc"}/share/doc"
    "-DQML_INSTALL_DIR=${placeholder "out"}/${qtbase.qtQmlPrefix}"
  ];

  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${lib.getBin qtbase}/${qtbase.qtPluginPrefix}
    export QML2_IMPORT_PATH=${lib.getBin qtdeclarative}/${qtbase.qtQmlPrefix}
  '';

  outputs = [ "out" "dev" "doc" ];

  strictDeps = true;

  #noAuditTmpdir = true; # Why?

  meta = with lib; {
    description = "A widget development toolkit based on QtQuick/QtQml";
    homepage = "https://github.com/linuxdeepin/dtkdeclarative";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
