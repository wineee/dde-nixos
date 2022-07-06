{ stdenv
, lib
, fetchFromGitHub
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
}:

stdenv.mkDerivation rec {
  pname = "dde-control-center";
  version = "unstable-2022-07-06";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "5214b2756a13a8a27fe414280d1ab8e3d990454f";
    sha256 = "sha256-aB2vH8Uz06zqBsW9KBlzr8Z7S5HxDS7bZ2qxg95lSuY=";
  };

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

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  patches = [
    (substituteAll {
      src = ./0001-fix-path.patch;
      qtbase_dev = "${lib.getDev qtbase}/include/QtXkbCommonSupport/5.15.3";
    })
  ];

  ### TODO include/widgets/utils.h abrecovery/main.cpp dde-control-center-autostart.desktop com.deepin.dde.ControlCenter.service src/frame/window/protocolfile.cpp ...

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

  fixPolicyPatch = ''
    substituteInPlace com.deepin.controlcenter.develop.policy \
      --replace '/usr/lib/dde-control-center/develop-tool' 'out/lib/dde-control-center/develop-tool'
  '';

  postPatch = fixInstallPatch + fixPolicyPatch;

  cmakeFlags = [
    "-DVERSION=${version}"
    "-DDISABLE_AUTHENTICATION=YES"
    "-DDISABLE_ACTIVATOR=YES"
    "-DDISABLE_SYS_UPDATE=YES"
    "-DDISABLE_RECOVERY=YES"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DINCLUDE_INSTALL_DIR=include"
    #"-DDCMAKE_INSTALL_COMPONENT=false"
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
