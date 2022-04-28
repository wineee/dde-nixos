{ stdenv
, lib
, fetchFromGitHub
, dtk
, substituteAll
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, deepin-pw-check
, udisks2-qt5
, cmake
, qttools
, qtbase
, pkgconfig
, qtx11extras
, qtmultimedia
, wrapQtAppsHook
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
, gtest
}:

stdenv.mkDerivation rec {
  pname = "dde-control-center";
  version = "unstable-2022-04-26";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "5d3beacccb64f5f0806071041d1d9b0e7cd1aa85";
    sha256 = "sha256-DEB4tlc7FV1+dxb8vyIseLEuaK+AEFfZdyfV2US2oyU=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    qtbase.dev
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
    util-linux
    libselinux
    libsepol
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
    "-DDISABLE_AUTHENTICATION=true"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DINCLUDE_INSTALL_DIR=include"
    #"-DDCMAKE_INSTALL_COMPONENT=false"
  ];

  meta = with lib; {
    description = "Control panel of Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-control-center";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
