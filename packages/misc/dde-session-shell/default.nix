{ stdenv
, lib
, fetchFromGitHub
, replaceAll
, linkFarm
, getUsrPatchFrom
, dtk
, dde-qt-dbus-factory
, cmake
, pkg-config
, qttools
, qtx11extras
, wrapQtAppsHook
, wrapGAppsHook
, gsettings-qt
, lightdm_qt
, linux-pam
, xorg
, kwayland
, glib
, gtest
, xkeyboard_config
, dbus
, dde-session-shell
, qtbase
, qt5integration
}:
let
  patchList = {
    ### MISC
    "files/com.deepin.dde.shutdownFront.service" = [
      #/usr/share/applications/dde-lock.desktop
    ];
    "files/com.deepin.dde.lockFront.service" = [
      #/usr/share/applications/dde-lock.desktop
    ];
    "files/lightdm-deepin-greeter.conf" = [ ];
    ### CODE
    "scripts/lightdm-deepin-greeter" = [
      # "/usr/bin/lightdm-deepin-greeter"
    ];
    "src/lightdm-deepin-greeter/greeterworker.cpp" = [
      [ "/usr/include/shadow.h" "shadow.h" ]
      # /etc/deepin/no_suspend
    ];
    "files/wayland/kwin_wayland_helper-wayland" = [
      [ "/usr/bin/kwin_wayland" "kwin_wayland" ]
    ];
    "files/wayland/deepin-greeter-wayland" = [
      # export QML2_IMPORT_PATH=/usr/lib/x86_64-linux-gnu/qt5/qml
      # export XDG_DATA_DIRS=/usr/share
      [ "/usr/bin/kwin_wayland" "kwin_wayland" ]
    ];
    "src/global_util/public_func.cpp" = [
      # /usr/share/dde-session-shell/translations
    ];
    "src/global_util/constants.h" = [
      [ "/usr/share/icons" "/run/current-system/sw/share/icons" ]
      # /usr/share/icons/default/index.theme"
      # /usr/share/dde-session-shell
    ];
    "files/wayland/lightdm-deepin-greeter-wayland" = [
      # "/usr/bin/lightdm-deepin-greeter"
      # TODO export QT_QPA_PLATFORM_PLUGIN_PATH...
    ];
    # scripts/lightdm-deepin-greeter /etc/lightdm/deepin/xsettingsd.conf
    # files/wayland/kwin_wayland_helper-wayland /etc/xdg/kglobalshortcutsrc
    "src/app/lightdm-deepin-greeter.cpp" = [
      [ "/usr/share/icons" "/run/current-system/sw/share/icons" ]
      # /etc/lightdm/deepin/xsettingsd.conf
    ];
    "src/libdde-auth/deepinauthframework.cpp" = [
      [ "common-auth" "deepin-auth-keyboard" ] # fix dde lock auth
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-session-shell";
  version = "5.6.4";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-mrdGu4t86d3No23IrnjypVLx1jxaySatr0xPMY9l5S4";
  };

  postPatch = replaceAll "/usr/bin/dbus-send" "${dbus}/bin/dbus-send"
    + replaceAll "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"
    + replaceAll "/usr/lib/dde-control-center" "/run/current-system/sw/lib/dde-control-center"
    + replaceAll "/usr/share/backgrounds" "/run/current-system/sw/share/backgrounds"
    + replaceAll "/usr/lib/dde-session-shell/modules" "/run/current-system/sw/lib/dde-session-shell/modules"
    + replaceAll "/usr/bin/dde-lock" "dde-lock"
    + replaceAll "/usr/bin/deepin-greeter" "deepin-greeter"
    + replaceAll "/usr/sbin/lightdm" "lightdm"
    + replaceAll "/usr/share/X11/xkb/rules/base.xml" "${xkeyboard_config}/share/X11/xkb/rules/base.xml"
    + getUsrPatchFrom patchList + ''
    patchShebangs files/deepin-greeter
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    wrapQtAppsHook
    wrapGAppsHook
  ];
  dontWrapGApps = true;

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    gsettings-qt
    lightdm_qt
    qtx11extras
    linux-pam
    kwayland
    xorg.libXcursor
    xorg.libXtst
    xorg.libXrandr
    xorg.libXdmcp
    gtest
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    for binary in $out/etc/deepin/greeters.d/*; do
      wrapQtApp $binary
    done
  '';

  passthru.xgreeters = linkFarm "deepin-greeter-xgreeters" [{
    path = "${dde-session-shell}/share/xgreeters/lightdm-deepin-greeter.desktop";
    name = "lightdm-deepin-greeter.desktop";
  }];

  meta = with lib; {
    description = "Deepin desktop-environment - session-shell module";
    homepage = "https://github.com/linuxdeepin/dde-session-shell";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
