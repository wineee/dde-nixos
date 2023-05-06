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
    rev = "24ff57eb70a06285aadd4c588674be4c96a2521f";
    sha256 = "sha256-3EWMCbHb+uShyJ6eiQ44tPCoFkGBtg+BNxx57WS58iw=";
  };

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