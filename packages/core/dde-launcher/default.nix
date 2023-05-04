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
  version = "6.0.10";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-XVwozXNAEakyFDUa9vMqxeQVcQ/y2qUJdjawdZfuUAY=";
  };

  postPatch = ''
    substituteInPlace src/boxframe/{backgroundmanager.cpp,boxframe.cpp} \
      --replace "/usr/share/backgrounds" "/run/current-system/sw/share/backgrounds"
    substituteInPlace dde-launcher.desktop dde-launcher-wapper src/dbusservices/org.deepin.dde.Launcher1.service \
      --replace "/usr" "$out"
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