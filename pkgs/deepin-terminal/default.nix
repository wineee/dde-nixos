{ stdenv
, lib
, fetchFromGitHub
, dtkcore
, dtkgui
, dtkwidget
, dtkcommon
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, cmake
, qttools
, qtx11extras
, pkgconfig
, wrapQtAppsHook
, at-spi2-core
, libsecret
, chrpath
, lxqt
, zssh
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-terminal";
  version = "5.4.28";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-tmy1fQfT5zQ2va2bx0uIQGOk8Z44VKpade7qp05JYBc=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
    dde-qt-dbus-factory
    qtx11extras
    at-spi2-core
    libsecret
    chrpath
    lxqt.lxqt-build-tools
    gtest
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "share/deepin-manual/manual-assets/application/)"

    substituteInPlace 3rdparty/terminalwidget/CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX \"/usr\")" "set(CMAKE_INSTALL_PREFIX $out)"
  '';

  meta = with lib; {
    description = "An advanced terminal emulator with workspace,multiple windows,remote management,quake mode and other features";
    homepage = "https://github.com/linuxdeepin/deepin-terminal";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
