{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, replaceAll
, dtkwidget
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
, libxcrypt
, networkmanager-qt
, glib
, runtimeShell
, tzdata
, dbus
}:

stdenv.mkDerivation rec {
  pname = "dde-control-center";
  version = "5.5.164";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-Pd1vCkA0vDC6aGTt1hXreIxTi9feBWNZZhIdpjf26iw=";
  };

  patches = [
    (fetchpatch {
      name = "fix info for other distributions";
      url = "https://github.com/linuxdeepin/dde-control-center/commit/32394aa84f4b575e0a84a0813ba07b72cb1ba137.patch";
      sha256 = "sha256-r21oczFyhKarMuEkL8Ruzd8jqB/T+MfuUGrLNeQdZB8=";
    })
    ./0002-fix-svg-render-for-themeitem.patch
    ./0003-dont-show-endUserLicenseAgreement-for-deepinos.patch
  ];

  postPatch = replaceAll "/bin/bash" "${runtimeShell}"
    + replaceAll "/usr/lib/dde-control-center" "/run/current-system/sw/lib/dde-control-center"
    + replaceAll "/usr/share/zoneinfo" "${tzdata}/share/zoneinfo"
    + replaceAll "/usr/bin/dbus-send" "${dbus}/bin/dbus-send"
    + replaceAll "/usr/bin/abrecovery" "abrecovery" + ''
    substituteInPlace CMakeLists.txt --replace 'add_subdirectory("tests")' ' '

    substituteInPlace dde-control-center-autostart.desktop com.deepin.dde.ControlCenter.service \
      --replace "/usr" "$out" 

    substituteInPlace abrecovery/main.cpp include/widgets/utils.h src/{reboot-reminder-dialog/main.cpp,frame/main.cpp,reset-password-dialog/main.cpp} \
      --replace "/usr/share/dde-control-center" "$out/share/dde-control-center"

    # default path for QFileDialog::getOpenFileName
    substituteInPlace src/frame/modules/keyboard/customedit.cpp \
      --replace "/usr/bin" "/run/current-system/sw/bin"

    substituteInPlace dde-control-center-wapper \
      --replace "qdbus" "${qttools.bin}/bin/qdbus" \
      --replace "/usr/share" "$out/share"

    substituteInPlace src/frame/window/mainwindow.cpp \
      --replace "/usr/share/icons/bloom/apps/64/preferences-system.svg" "preferences-system.svg"
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
    qtbase
    dtkwidget
    qt5platform-plugins
    dde-qt-dbus-factory
    deepin-pw-check
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
    libselinux
    libsepol
    libxcrypt
    networkmanager-qt
  ];

  cmakeFlags = [
    "-DCVERSION=${version}"
    "-DDISABLE_AUTHENTICATION=YES"
    "-DDISABLE_ACTIVATOR=YES"
    "-DDISABLE_SYS_UPDATE=YES"
    "-DDISABLE_RECOVERY=YES"
  ];

  # qt5integration must be placed before qtsvg in QT_PLUGIN_PATH
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
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
