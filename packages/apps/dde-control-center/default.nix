{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
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
  version = "5.5.143";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-D5CsM/nIiLjH2EMgIfRodrcyb6xzJbWAHvtOnhUvLH8=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/dde-control-center/commit/9e0dc3bf0abe1daa51d2bdf1866bd4b24f6b6728.patch";
      sha256 = "sha256-+2XYLwDd8Cjx/6lutlzQUlenyzf19CevxtQOgDVsmDE=";
    })
    (fetchpatch {
      name = "feat: use CMAKE_SYSTEM_PROCESSOR to check sw_64";
      url = "https://github.com/linuxdeepin/dde-control-center/commit/5ff12b5e7f1f24272d889b7014a5b8431758c8ed.patch";
      sha256 = "sha256-Jo2WTWfUF+tl8NzclERBT9NASX4emf8ToK7ESZctVnc=";
    })
  ];

  postPatch = getPatchFrom patchList;

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
    #"-DCMAKE_INSTALL_LIBDIR=lib"
    #"-DINCLUDE_INSTALL_DIR=include"
    #"-DDCMAKE_INSTALL_COMPONENT=false"
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
