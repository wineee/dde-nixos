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
, pkgconfig
, qtx11extras
, wrapQtAppsHook
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-calculator";
  version = "5.7.12";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-RUDXvipjDE5xAVAQToRCKhY/MioUrwGV3sjC+MoHrFc=";
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
    gtest
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX /usr)" "set(CMAKE_INSTALL_PREFIX $out)" \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "share/deepin-manual/manual-assets/application/)"
  '';

  meta = with lib; {
    description = "An easy to use calculator for ordinary users";
    homepage = "https://github.com/linuxdeepin/deepin-calculator";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
