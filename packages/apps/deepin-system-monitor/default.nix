{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, qttools
, deepin-gettext-tools
, wrapQtAppsHook
, dtkwidget
, qt5integration
, qt5platform-plugins
, qtbase
, qtsvg
, qtx11extras
, dde-qt-dbus-factory
, dde-dock
, gsettings-qt
, procps
, libpcap
, libnl
, util-linux
, systemd
, polkit
, wayland
, dwayland
}:

stdenv.mkDerivation rec {
  pname = "deepin-system-monitor";
  version = "6.0.6";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-4GViTW0Yho2uiLdsb6LYswZL2GQGWlM1W9G+mfrbNdo=";
  };

  postPatch = ''
    substituteInPlace deepin-system-monitor-main/{service/service_manager.cpp,process/{priority_controller.cpp,process_controller.cpp}} \
      deepin-system-monitor-main/translations/policy/com.deepin.pkexec.deepin-system-monitor.policy \
      --replace "/usr/bin/pkexec" "${lib.getBin polkit}/bin/pkexec" \
      --replace "/usr/bin/kill" "${util-linux}/bin/kill" \
      --replace "/usr/bin/renice" "${util-linux}/bin/renice" \
      --replace '/usr/bin/systemctl' '${lib.getBin systemd}/systemctl'

    for file in $(grep -rl "/usr")
    do
      substituteInPlace $file --replace "/usr" "$out"
    done
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    deepin-gettext-tools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    qt5integration
    qt5platform-plugins
    qtbase
    qtsvg
    qtx11extras
    dde-qt-dbus-factory
    dde-dock
    gsettings-qt
    procps
    libpcap
    libnl
    wayland
    dwayland
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
  ];

  strictDeps = true;

  meta = with lib; {
    description = "A more user-friendly system monitor";
    homepage = "https://github.com/linuxdeepin/deepin-system-monitor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}