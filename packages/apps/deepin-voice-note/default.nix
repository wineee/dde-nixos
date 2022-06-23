{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, cmake
, pkgconfig
, qttools
, qtmultimedia
, qtwebengine
, wrapQtAppsHook
, libvlc
, gst_all_1
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-voice-note";
  version = "5.10.17";

  src = fetchFromGitHub {
    owner = "wineee";
    repo = pname;
    rev = "09dedc34a28d8f8a49994f2042ccd4bdb215f0d5";
    sha256 = "sha256-Gn8bX1xh7jyjldLygM2L/a8zKENLxShVicZlrSrHBR4=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    qtmultimedia
    qtwebengine
    libvlc
    gst_all_1.gstreamer
    gtest
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX /usr)" "set(CMAKE_INSTALL_PREFIX $out)" \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "$out/share/deepin-manual/manual-assets/application/)"
  '';

  meta = with lib; {
    description = "a simple memo software with texts and voice recordings";
    homepage = "https://github.com/linuxdeepin/deepin-voice-note";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
