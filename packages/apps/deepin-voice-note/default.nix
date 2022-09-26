{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, cmake
, pkg-config
, qttools
, qtmultimedia
, qtwebengine
, wrapQtAppsHook
, libvlc
, gst_all_1
, gtest
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "deepin-voice-note";
  version = "5.10.18";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-h7eo2DNENJKbeYWCyYSfO9lwIcFx6A+7eY0kJHmKW0Q=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/deepin-voice-note/commit/3013c6bfcaef9c2969399286613e6810f8557f0a.patch";
      sha256 = "sha256-MYAxDAVvkt62841naRQRnPX7Q4jdqFNtOfbeEuHKwBQ=";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
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

  NIX_CFLAGS_COMPILE = "-I${dde-qt-dbus-factory}/include/libdframeworkdbus-2.0";

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "a simple memo software with texts and voice recordings";
    homepage = "https://github.com/linuxdeepin/deepin-voice-note";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
