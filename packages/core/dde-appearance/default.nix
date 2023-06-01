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
  version = "1.1.1.999";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "b8d3533cba9bd6214b5f35962b895e7727e2dd03";
    sha256 = "sha256-hsyt9ibrYjHycyuORPGgJPubhxMF9Yq5lN7X1xkbDtE=";
  };

  postPatch = ''
    substituteInPlace misc/systemd/dde-appearance.service src/service/modules/subthemes/customtheme.cpp \
      --replace "/usr" "$out"

    substituteInPlace src/service/modules/api/compatibleengine.cpp \
      src/service/modules/background/backgrounds.cpp \
      src/service/dbus/deepinwmfaker.cpp \
      misc/dconfig/org.deepin.dde.appearance.json \
      misc/dbusservice/org.deepin.dde.Appearance1.service \
      src/service/impl/appearancemanager.cpp \
      src/service/modules/subthemes/customtheme.cpp \
      --replace "/usr" "/run/current-system/sw"

    substituteInPlace src/service/modules/api/themethumb.cpp \
      --replace "/usr/lib/deepin-api" "/run/current-system/sw/lib/deepin-api"

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
