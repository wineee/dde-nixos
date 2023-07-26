{ stdenv
, lib
, fetchFromGitHub
, cmake
, qttools
, pkg-config
, wrapQtAppsHook
, wrapGAppsHook
, dtkwidget
, qt5integration
, qt5platform-plugins
, qtbase
, qtx11extras
, gsettings-qt
}:

stdenv.mkDerivation rec {
  pname = "dde-launcher";
  version = "6.0.14";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-bJHD/YH/5fqVn4LJAj8ODOVBU2oGHb71NygqmMZQDDM";
  };

  postPatch = ''
    substituteInPlace src/boxframe/{backgroundmanager.cpp,boxframe.cpp} \
      --replace "/usr/share/backgrounds" "/run/current-system/sw/share/backgrounds"
    substituteInPlace src/global_util/pluginloader.cpp \
      --replace "/usr/lib/dde-launcher" "/run/current-system/sw/lib/dde-launcher"
  '';

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
    wrapGAppsHook
  ];
  dontWrapGApps = true;

  buildInputs = [
    dtkwidget
    qt5platform-plugins
    qtbase
    qtx11extras
    gsettings-qt
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  # qt5integration must be placed before qtsvg in QT_PLUGIN_PATH
  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Deepin desktop-environment - Launcher module";
    homepage = "https://github.com/linuxdeepin/dde-launcher";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
