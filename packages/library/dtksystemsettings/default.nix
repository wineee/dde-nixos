{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, cmake
, pkg-config
, qttools
, doxygen
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

  patches = [
    (fetchpatch {
      url = "https://github.com/linuxdeepin/dtksystemsettings/commit/f776b9c6ab2752857fbaaf50fd1ea26e9e85ec87.patch";
      hash = "sha256-VRG2Chp6mVJQ4sAmu2iA3ln6BfMDqzvHMhFx7ABPXA8=";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    doxygen
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
    "-DDTK_INCLUDE_INSTALL_DIR=${placeholder "dev"}/include/dtk/DSystemSettings"
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
