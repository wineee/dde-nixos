{ stdenv
, lib
, fetchFromGitHub
, pkg-config
, cmake
, gsettings-qt
, wrapQtAppsHook
, qtbase
, qttools
, lshw
, libuchardet
, spdlog
, dtkcommon
, doxygen
, withSystemd ? true
}:

stdenv.mkDerivation rec {
  pname = "dtkcore";
  version = "5.6.17";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-/MGSvT8tPn+KqqlM6FY2iFsArmAkYMW5Q3Sl4g4zvH0=";
  };

  outputs = [ "out" "doc" ];
  
  postPatch = ''
    substituteInPlace src/dsysinfo.cpp \
      --replace "/usr/share/deepin/distribution.info" "/etc/distribution.info" \
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
    doxygen
    qttools
  ];

  dontWrapQtApps = true;

  buildInputs = [
    qtbase
    gsettings-qt
    lshw
    libuchardet
    spdlog
  ];

  propagatedBuildInputs = [ dtkcommon ];

  cmakeFlags = [
    "-DDTK_VERSION=${version}"
    "-DBUILD_DOCS=ON"
    "-DBUILD_EXAMPLES=OFF"
    "-DQCH_INSTALL_DESTINATION=${placeholder "doc"}/${qtbase.qtDocPrefix}"
    "-DDSG_PREFIX_PATH='/run/current-system/sw'"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DD_DSG_APP_DATA_FALLBACK=/var/dsg/appdata"
    "-DBUILD_WITH_SYSTEMD=${if withSystemd then "ON" else "OFF"}"
  ];

  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${qtbase.bin}/${qtbase.qtPluginPrefix}
  '';

  meta = with lib; {
    description = "Deepin tool kit core library";
    homepage = "https://github.com/linuxdeepin/dtkcore";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
