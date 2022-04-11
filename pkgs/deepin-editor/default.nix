{ stdenv
, lib
, fetchFromGitHub
, dtkcommon
, dtkcore
, dtkgui
, dtkwidget
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, cmake
, pkgconfig
, qttools
, wrapQtAppsHook
, kcodecs
, syntax-highlighting
, libchardet
, libuchardet
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-editor";
  version = "5.6.35";
  # TODO 5.10.19 need  com_deepin_dde_daemon_dock.h 

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-P0ZL3/XFZQgs37wLkY0hzh/gxpHj4XzzRpWazTOOXVk=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
    dde-qt-dbus-factory
    kcodecs
    syntax-highlighting
    libchardet
    libuchardet
    gtest
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX /usr)" "set(CMAKE_INSTALL_PREFIX $out)"
  '';

  meta = with lib; {
    description = "A desktop text editor that supports common text editing features";
    homepage = "https://github.com/linuxdeepin/deepin-editor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
