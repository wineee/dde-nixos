{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, qttools
, doxygen
, wrapQtAppsHook
, qtbase
, dtkcore
, libxcrypt
}:

stdenv.mkDerivation rec {
  pname = "dtksystemsettings";
  version = "unstable-2024-01-01";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "b10c98bf1f7b7fabfd54bd57bdc74bc4a47f6098";
    hash = "sha256-1FDTtdDwa2G/cPtPqq2/hMMZxyTD9ErGtDX0dVu3jrw=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    doxygen
    wrapQtAppsHook
  ];

  dontWrapQtApps = true;

  buildInputs = [
    qtbase
    dtkcore
    libxcrypt
  ];

  cmakeFlags = [
    "-DDTK_VERSION=${if lib.versionAtLeast qtbase.version "6" then "6.0.0" else "5.6.20"}"
    "-DBUILD_DOCS=ON"
    "-DBUILD_EXAMPLES=OFF"
    "-DQCH_INSTALL_DESTINATION=${placeholder "doc"}/share/doc"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
  ];

  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${lib.getBin qtbase}/${qtbase.qtPluginPrefix}
  '';

  outputs = [ "out" "dev" "doc" ];

  meta = with lib; {
    description = "Qt-based development library for system settings on Deepin";
    homepage = "https://github.com/linuxdeepin/dtksystemsettings";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
