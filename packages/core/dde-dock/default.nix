{ stdenv
, lib
, fetchpatch
, fetchFromGitHub
, cmake
, extra-cmake-modules
, qttools
, pkg-config
, wrapQtAppsHook
, wrapGAppsHook
, qtbase
, dtkwidget
, qt5integration
, qt5platform-plugins
, dwayland
, qtx11extras
, gsettings-qt
, libdbusmenu
, xorg
}:

stdenv.mkDerivation rec {
  pname = "dde-dock";
  version = "6.0.13";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-bF+QB+Oc/5ueaicuzXF99NUNpizUx8OBOU5ZFI4S0Jw=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/linuxdeepin/dde-dock/commit/3b6f84687c7f0aa6b09a5597d730b3456736d271.patch";
      sha256 = "sha256-5ZtmRyyWw6LZ7+w9h3QdZiBxrY1cmnRwiDdVzzTe3bw=";
    })
  ];

  postPatch = ''
    substituteInPlace plugins/pluginmanager/pluginmanager.cpp \
      --replace "/usr/lib/dde-dock/plugins" "/run/current-system/sw/lib/dde-dock/plugins"

    substituteInPlace frame/{window/components/desktop_widget.cpp,controller/quicksettingcontroller.cpp} \
      plugins/show-desktop/showdesktopplugin.cpp \
      --replace "/usr/lib/deepin-daemon" "/run/current-system/sw/libexec/deepin-daemon"
   '';

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    qttools
    pkg-config
    wrapQtAppsHook
    wrapGAppsHook
  ];
  dontWrapGApps = true;

  buildInputs = [
    qtbase
    dtkwidget
    qt5platform-plugins
    # dde-qt-dbus-factory
    # dde-control-center
    # deepin-desktop-schemas
    dwayland
    qtx11extras
    gsettings-qt
    libdbusmenu
    xorg.libXcursor
    xorg.libXtst
    xorg.libXdmcp
  ];

  outputs = [ "out" "dev" ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  # qt5integration must be placed before qtsvg in QT_PLUGIN_PATH
  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Deepin desktop-environment - dock module";
    homepage = "https://github.com/linuxdeepin/dde-dock";
    platforms = platforms.linux;
    license = licenses.lgpl3Plus;
    maintainers = teams.deepin.members;
  };
}