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
, dtkcommon
, doxygen
, buildDocs ? true
, withSystemd ? true
}:
let
  onOffBool = b: if b then "ON" else "OFF";
in
stdenv.mkDerivation rec {
  pname = "dtkcore";
  version = "5.6.5";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-jOLQ8hMVz51YXSs4VXusHlB6jtPQay2lCJNlGgTX7d0=";
  };

  postPatch = ''
    substituteInPlace src/dsysinfo.cpp \
      --replace "/usr/share/deepin/distribution.info" "/etc/distribution.info" \
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
  ] ++ lib.optional buildDocs [
    doxygen
    qttools.dev
  ];

  dontWrapQtApps = true;

  buildInputs = [
    qtbase
    gsettings-qt
    lshw
    libuchardet
  ];

  propagatedBuildInputs = [ dtkcommon ];

  cmakeFlags = [
    "-DDVERSION=${version}"
    "-DBUILD_DOCS=ON"
    "-DBUILD_EXAMPLES=${onOffBool buildDocs}"
    "-DQCH_INSTALL_DESTINATION=${qtbase.qtDocPrefix}"
    "-DDSG_PREFIX_PATH='/run/current-system/sw'"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DD_DSG_APP_DATA_FALLBACK=/var/dsg/appdata"
    "-DBUILD_WITH_SYSTEMD=${onOffBool withSystemd}"
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
  };
}
