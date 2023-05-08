{ stdenv
, lib
, fetchFromGitHub
, linkFarm
, cmake
, pkg-config
, qttools
, wrapQtAppsHook
, wrapGAppsHook
, qtbase
, dtkwidget
, qt5integration
, qt5platform-plugins
, deepin-pw-check
, gsettings-qt
, lightdm_qt
, qtx11extras
, linux-pam
, xorg
, gtest
, xkeyboard_config
, dbus
, dde-session-shell
, fetchpatch
}:

stdenv.mkDerivation rec {
  pname = "dde-session-shell";
  version = "6.0.8";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-gygAn/DDRV1DboFh7RoIGxN1MmA0dJmpPrrTbRZUkWk=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/linuxdeepin/dde-session-shell/commit/fbabdfa9d78dc2937a5c5e42ce3729869cc12891.patch";
      sha256 = "sha256-UoVmQ0fUZw7xwZwIowFCoMVO/2td2VTNwhGBVQGibgM=";
    })
    (fetchpatch {
      url = "https://github.com/linuxdeepin/dde-session-shell/commit/32ca27b2504213d6bfdd84c1ef6772904bd9e116.patch";
      sha256 = "sha256-BtzhEdIgPzGUsXIne0iG/1Jd1G4hmO9cs+u7DRO777M=";
    })
  ];

  postPatch = ''
    substituteInPlace scripts/lightdm-deepin-greeter files/wayland/lightdm-deepin-greeter-wayland \
      --replace "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"

    substituteInPlace src/session-widgets/auth_module.h \
      --replace "/usr/lib/dde-control-center" "/run/current-system/sw/lib/dde-control-center"

    substituteInPlace src/global_util/modules_loader.cpp \
      --replace "/usr/lib/dde-session-shell/modules" "/run/current-system/sw/lib/dde-session-shell/modules"

    substituteInPlace src/{session-widgets/{lockcontent.cpp,userinfo.cpp},widgets/fullscreenbackground.cpp} \
      --replace "/usr/share/backgrounds" "/run/current-system/sw/share/backgrounds"

    substituteInPlace src/global_util/xkbparser.h \
      --replace "/usr/share/X11/xkb/rules/base.xml" "${xkeyboard_config}/share/X11/xkb/rules/base.xml"

    substituteInPlace files/{org.deepin.dde.ShutdownFront1.service,org.deepin.dde.LockFront1.service} \
      --replace "/usr/bin/dbus-send" "${dbus}/bin/dbus-send" \
      --replace "/usr/share" "$out/share"

    substituteInPlace src/global_util/{public_func.cpp,constants.h} scripts/lightdm-deepin-greeter files/{dde-lock.desktop,lightdm-deepin-greeter.desktop,wayland/lightdm-deepin-greeter-wayland.desktop} \
      --replace "/usr" "$out"

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
    qtbase
    dtkwidget
    qt5platform-plugins
    deepin-pw-check
    gsettings-qt
    lightdm_qt
    qtx11extras
    linux-pam
    xorg.libXcursor
    xorg.libXtst
    xorg.libXrandr
    xorg.libXdmcp
    gtest
  ];

  outputs = [ "out" "dev" ];

  # qt5integration must be placed before qtsvg in QT_PLUGIN_PATH
  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
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
    maintainers = teams.deepin.members;
  };
}