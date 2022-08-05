{ stdenv
, lib
, fetchFromGitHub
, getPatchFrom
, dtk
, substituteAll
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, deepin-pw-check
, deepin-desktop-schemas
, udisks2-qt5
, cmake
, qttools
, qtbase
, pkgconfig
, qtx11extras
, qtmultimedia
, wrapQtAppsHook
, wrapGAppsHook
, gsettings-qt
, wayland
, kwayland
, qtwayland
, polkit-qt
, pcre
, xorg
, util-linux
, libselinux
, libsepol
, networkmanager-qt
, glib
, gtest
, runtimeShell
, tzdata
, dbus
}:
let
  patchList = {
    "com.deepin.controlcenter.develop.policy" = [
      # "/usr/lib/dde-control-center/develop-tool"
    ];
    "dde-control-center-autostart.desktop" = [
      # /usr/bin/dde-control-center
    ];
    "abrecovery/deepin-ab-recovery.desktop" = [
      # /usr/bin/abrecovery
    ];
    "com.deepin.dde.ControlCenter.service" = [
      [ "/usr/bin/dbus-send" "${dbus}/bin/dbus-send" ]
      # "/usr/share/applications/dde-control-center.desktop
    ];
    "dde-control-center-wapper" = [
      # /usr/share/applications/dde-control-center.desktop
      #? qdbus
    ];

    "src/reboot-reminder-dialog/main.cpp" = [
      # /usr/share/dde-control-center/translations/dialogs_
    ];
    "src/frame/main.cpp" = [
      # /usr/share/dde-control-center/translations/keyboard_language_
    ];
    "src/frame/window/insertplugin.cpp" = [
      # /usr/lib/dde-control-center/modules
    ];
    "src/frame/window/mainwindow.cpp" = [
      # /usr/lib/dde-control-center/modules
      #? /usr/share/icons/bloom/apps/64/preferences-system.svg
    ];
    "src/frame/window/protocolfile.cpp" = [
      #? /usr/share/protocol
      #? /usr/share/deepin-deepinid-client/
    ];
    "include/widgets/utils.h" = [
      # "/usr/share/dde-control-center/dde-control-center.conf" 
    ];
    "src/reset-password-dialog/main.cpp" = [
      # /usr/share/dde-control-center/translations/reset-password-dialog_
    ];
    "src/frame/modules/update/updatework.cpp" = [
      #? /usr/share/deepin/
    ];
    "src/frame/modules/datetime/timezone_dialog/timezone.cpp" = [
      [ "usr/share/zoneinfo" "${tzdata}/share/zoneinfo" ]
      # /usr/share/zoneinfo/zone1970.tab
    ];
    "src/frame/modules/keyboard/customedit.cpp" = [
      #? /usr/bin
    ];
    "abrecovery/main.cpp" = [
      # /usr/share/dde-control-center/translations/recovery_
    ];
    "src/frame/modules/accounts/accountsworker.cpp" = [
      [ "/bin/bash" "${runtimeShell}" ]
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-control-center";
  version = "unstable-2022-07-26";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "2dbbe3e203191cd9ff3d79e11654492496bcbfff";
    sha256 = "sha256-2do/iW+Olxmpi91xwPq+jykgJx6L78D6dUUzO8ieEeU=";
  };

  fixInstallPatch = ''
    substituteInPlace src/frame/CMakeLists.txt \
      --replace 'set(CMAKE_INSTALL_PREFIX /usr)' 'set(CMAKE_INSTALL_PREFIX $out)'

    substituteInPlace src/develop-tool/CMakeLists.txt \
      --replace 'set(CMAKE_INSTALL_PREFIX /usr)' 'set(CMAKE_INSTALL_PREFIX $out)'

    substituteInPlace abrecovery/CMakeLists.txt \
      --replace 'set(CMAKE_INSTALL_PREFIX /usr)' 'set(CMAKE_INSTALL_PREFIX $out)' \
      --replace '/usr/bin)' 'bin)' \
      --replace '/etc/xdg/autostart)' 'etc/xdg/autostart)'

    substituteInPlace src/reboot-reminder-dialog/CMakeLists.txt \
      --replace 'set(CMAKE_INSTALL_PREFIX /usr)' 'set(CMAKE_INSTALL_PREFIX $out)'

    substituteInPlace src/reset-password-dialog/CMakeLists.txt \
      --replace 'set(CMAKE_INSTALL_PREFIX /usr)' 'set(CMAKE_INSTALL_PREFIX $out)'
  '';

  postPatch = fixInstallPatch + getPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
    wrapGAppsHook
  ];

  dontWrapGApps = true;

  buildInputs = [
    dtk
    qtbase.dev
    dde-qt-dbus-factory
    deepin-pw-check
    deepin-desktop-schemas
    qtx11extras
    qtmultimedia
    gsettings-qt
    udisks2-qt5
    wayland
    kwayland
    qtwayland
    polkit-qt
    pcre
    xorg.libXdmcp
    util-linux
    libselinux
    libsepol
    networkmanager-qt
    gtest
  ];

  cmakeFlags = [
    "-DCVERSION=${version}"
    "-DDISABLE_AUTHENTICATION=YES"
    "-DDISABLE_ACTIVATOR=YES"
    "-DDISABLE_SYS_UPDATE=YES"
    "-DDISABLE_RECOVERY=YES"
    "-DDISABLE_DEVELOPER_MODE=YES"
    "-DDISABLE_CLOUD_SYNC=YES"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DINCLUDE_INSTALL_DIR=include"
    #"-DDCMAKE_INSTALL_COMPONENT=false"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Control panel of Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-control-center";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
