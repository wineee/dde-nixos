{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, qt5integration
, dde-qt-dbus-factory
, cmake
, pkg-config
, qttools
, qtmultimedia
, qtwebengine
, wrapQtAppsHook
, wrapGAppsHook
, libvlc
, gst_all_1
, gtest
, qtbase
}:
let
  gstPluginPath = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with gst_all_1; [ gstreamer gst-plugins-base gst-plugins-good ]);
in
stdenv.mkDerivation rec {
  pname = "deepin-voice-note";
  version = "5.10.22";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-ZDw/kGmhcoTPDUsZa9CYhrVbK4Uo75G0L4q4cCBPr7E=";
  };

  postPatch = ''
    substituteInPlace src/common/audiowatcher.cpp \
      --replace "/usr/share" "$out/share"
    substituteInPlace assets/deepin-voice-note.desktop \
      --replace "/usr/bin" "$out/bin"
  '';

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
    gtest
  ] ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
  ]);

  cmakeFlags = [ "-DVERSION=${version}" ];

  NIX_CFLAGS_COMPILE = "-I${dde-qt-dbus-factory}/include/libdframeworkdbus-2.0";

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${gstPluginPath}"
  ];

  meta = with lib; {
    description = "Simple memo software with texts and voice recordings";
    homepage = "https://github.com/linuxdeepin/deepin-voice-note";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
