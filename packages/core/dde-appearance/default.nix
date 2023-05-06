{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
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
, tzdata
, iconv
}:
stdenv.mkDerivation rec {
  pname = "dde-appearance";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-5XuogRF8VdjZRB67/O41Ncd1//Tj9Cl4hM+bwYXXb8E=";
  };

  postPatch = ''
    substituteInPlace misc/systemd/dde-appearance.service src/service/modules/subthemes/customtheme.cpp \
      --replace "/usr" "$out"

    substituteInPlace src/service/modules/api/compatibleengine.cpp \
      src/service/modules/background/backgrounds.cpp \
      src/service/dbus/deepinwmfaker.cpp \
      misc/dconfig/org.deepin.dde.appearance.json \
      --replace "/usr" "/run/current-system/sw"

    substituteInPlace src/service/modules/common/commondefine.h \
      --replace "/usr/share/zoneinfo" "${tzdata}/share/zoneinfo"
    substituteInPlace src/service/modules/api/themethumb.cpp \
      --replace "/usr/lib/deepin-api" "/run/current-system/sw/libexec/deepin-api"

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
