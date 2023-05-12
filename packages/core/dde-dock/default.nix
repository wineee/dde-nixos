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
  version = "6.0.16";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-8DbqmyTK3YTv/MSTscmUED6PApzreuuEvSF7c3O/2B0=";
  };

  postPatch = ''
    substituteInPlace plugins/pluginmanager/pluginmanager.cpp frame/controller/quicksettingcontroller.cpp  \
      --replace "/usr/lib/dde-dock" "/run/current-system/sw/lib/dde-dock"

    substituteInPlace plugins/show-desktop/showdesktopplugin.cpp frame/window/components/desktop_widget.cpp \
      --replace "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"
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