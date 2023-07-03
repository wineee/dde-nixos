{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, wrapQtAppsHook
, qt5integration
, qt5platform-plugins
, qtbase
, dtkgui
, gsettings-qt
, gtk3
, kconfig
, kwindowsystem
, kglobalaccel
, xorg
, iconv
}:

stdenv.mkDerivation rec {
  pname = "dde-appearance";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-53iIXl8VV/V26tzvCmR0mmef5OOJ/TcgizmHUhKhn6k=";
  };

  patches = [
    ./fix-custom-wallpapers-path.diff
  ];

  postPatch = ''
    substituteInPlace src/service/impl/appearancemanager.cpp \
      src/service/modules/api/compatibleengine.cpp \
      src/service/modules/subthemes/customtheme.cpp \
      --replace "/usr" "/run/current-system/sw"
    
    for file in $(grep -rl "/usr/bin/dde-appearance"); do
      substituteInPlace $file --replace "/usr/bin/dde-appearance" "$out/bin/dde-appearance"
    done

    substituteInPlace src/service/modules/api/themethumb.cpp \
      --replace "/usr/lib/deepin-api" "/run/current-system/sw/lib/deepin-api"

    substituteInPlace src/service/dbus/deepinwmfaker.cpp \
      --replace "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"

    substituteInPlace src/service/modules/api/locale.cpp \
      --replace "/usr/share/locale/locale.alias" "${iconv}/share/locale/locale.alias"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkgui
    gsettings-qt
    gtk3
    kconfig
    kwindowsystem
    kglobalaccel
    xorg.libXcursor
    xorg.xcbutilcursor
  ];

  cmakeFlags = [
    "-DDSG_DATA_DIR=/run/current-system/sw/share/dsg"
  ];

  meta = with lib; {
    description = "A program used to set the theme and appearance of deepin desktop";
    homepage = "https://github.com/linuxdeepin/dde-appearance";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
