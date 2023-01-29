{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, getUsrPatchFrom
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
, dde-account-faces
, dbus
}:
let
  patchList = {
    "dde-control-center-autostart.desktop" = [ ];
    "com.deepin.dde.ControlCenter.service" = [
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
      # /usr/share/icons/bloom/apps/64/preferences-system.svg
      [ "/usr/share/icons" "/run/current-system/sw/share/icons" ]
    ];
    "include/widgets/utils.h" = [ ];
    "src/reset-password-dialog/main.cpp" = [ ];
    "src/frame/modules/keyboard/customedit.cpp" = [
      [ "/usr/bin" "/run/current-system/sw/bin" ]
    ];
    "abrecovery/main.cpp" = [ ];
  };
in
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
    # (substituteAll {
    #   src = ./0001-patch_account_face_path_for_nix.patch;
    #   actConfigDir = "${dde-account-faces}/share/lib/AccountsService";
    # })
    ./0002-fix-svg-render-for-themeitem.patch
    ./0003-dont-show-endUserLicenseAgreement-for-deepinos.patch
  ];

  postPatch = replaceAll "/bin/bash" "${runtimeShell}"
    + replaceAll "/usr/lib/dde-control-center" "/run/current-system/sw/lib/dde-control-center"
    + replaceAll "/usr/share/zoneinfo" "${tzdata}/share/zoneinfo"
    + replaceAll "/usr/bin/dbus-send" "${dbus}/bin/dbus-send"
    + replaceAll "/usr/bin/abrecovery" "abrecovery"
    + getUsrPatchFrom patchList + ''
    substituteInPlace CMakeLists.txt --replace 'add_subdirectory("tests")' ' '
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
    dtkwidget
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

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/${qtbase.qtPluginPrefix}"
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
