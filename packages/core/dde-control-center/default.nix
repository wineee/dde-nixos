{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, qttools
, doxygen
, wrapQtAppsHook
, wrapGAppsHook
, dtkwidget
, qt5integration
, qt5platform-plugins
, deepin-pw-check
, qtbase
, qtx11extras
, qtmultimedia
, polkit-qt
, libxcrypt
, librsvg
, runtimeShell
, tzdata
, dbus
}:

stdenv.mkDerivation rec {
  pname = "dde-control-center";
  version = "6.0.20";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-K4U9LlaYjP4aSZAUoJUwsX/tBGJ7EpAo5LUaiRp1U74=";
  };

  postPatch = ''
     substituteInPlace src/plugin-datetime/window/widgets/timezone.cpp \
      --replace "/usr/share/zoneinfo" "${tzdata}/share/zoneinfo"

    substituteInPlace src/plugin-accounts/operation/accountsworker.cpp \
      --replace "/bin/bash" "${runtimeShell}"

    substituteInPlace misc/org.deepin.dde.ControlCenter1.service \
      --replace "/usr" "$out"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    doxygen
    wrapQtAppsHook
    wrapGAppsHook
  ];
  dontWrapGApps = true;

  buildInputs = [
    dtkwidget
    qt5platform-plugins
    deepin-pw-check
    qtbase
    qtx11extras
    qtmultimedia
    polkit-qt
    libxcrypt
    librsvg
  ];

  cmakeFlags = [
    "-DDVERSION=${version}"
    "-DDISABLE_AUTHENTICATION=YES"
    "-DDISABLE_UPDATE=YES"
    "-DDISABLE_LANGUAGE=YES"
    "-DBUILD_DOCS=OFF"
    "-DMODULE_READ_DIR=/run/current-system/sw/lib/dde-control-center/modules"
    "-DLOCALSTATE_READ_DIR=/var"
  ];

  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${qtbase.bin}/${qtbase.qtPluginPrefix}
  '';

  # qt5integration must be placed before qtsvg in QT_PLUGIN_PATH
  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ librsvg ]}"
  ];

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Control panel of Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-control-center";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
