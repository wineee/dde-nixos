{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, replaceAll
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
, pkg-config
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
      [ "qdbus" "${qttools.bin}/bin/qdbus" ]
    ];

    "src/reboot-reminder-dialog/main.cpp" = [
      # /usr/share/dde-control-center/translations/dialogs_
    ];
    "src/frame/main.cpp" = [
      # /usr/share/dde-control-center/translations/keyboard_language_
    ];
    "src/frame/window/mainwindow.cpp" = [
      #? /usr/share/icons/bloom/apps/64/preferences-system.svg
      [ "/usr/share/icons" "/run/current-system/sw/share/icons" ]
    ];
    "include/widgets/utils.h" = [ ];
    "src/reset-password-dialog/main.cpp" = [ ];
    "src/frame/modules/datetime/timezone_dialog/timezone.cpp" = [
      [ "usr/share/zoneinfo" "${tzdata}/share/zoneinfo" ]
    ];
    "src/frame/modules/keyboard/customedit.cpp" = [
      [ "/usr/bin" "/run/current-system/sw/bin" ]
    ];
    "abrecovery/main.cpp" = [ ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-control-center";
  version = "5.5.157";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-DVZI4xa1ibfcvNuKzfGufVE22v5oUeRKQGLH/kMJCgo=";
  };

  postPatch = replaceAll "/bin/bash" "${runtimeShell}"
    + replaceAll "/usr/lib/dde-control-center/modules" "/run/current-system/sw/lib/dde-control-center/modules"
    + getUsrPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
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
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
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
