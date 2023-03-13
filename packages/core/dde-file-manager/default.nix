{ stdenv
, lib
, fetchFromGitHub
, replaceAll
, fetchpatch
, runtimeShell
, dtkwidget
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, docparser
, dde-dock
, deepin-movie-reborn
, cmake
, qttools
, qtx11extras
, qtmultimedia
, kcodecs
, pkg-config
, ffmpegthumbnailer
, libsecret
, libmediainfo
, mediainfo
, libzen
, poppler
, polkit-qt
, polkit
, wrapQtAppsHook
, wrapGAppsHook
, lucenepp
, boost
, taglib
, cryptsetup
, glib
, gst_all_1
, qtbase
, mpv
, ffmpeg
, util-dfm
, deepin-pdfium
, libuuid
, glibmm
}:

stdenv.mkDerivation rec {
  pname = "dde-file-manager";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "BLumia";
    repo = pname;
    rev = "b3eb3655aaf6f53d70c08b2e86f4d372a4b298b3";
    sha256 = "sha256-fUL9aYzjrsGFfqyeTEqYnw47wb8y3CZl35bwoHrUMgo=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
    wrapGAppsHook
  ];
  dontWrapGApps = true;

  postPatch = replaceAll "qt5/QtCore/qobjectdefs.h" "QtCore/qobjectdefs.h"
    + ''
    patchShebangs .

    substituteInPlace src/plugins/filemanager/dfmplugin-vault/utils/vaultdefine.h \
      --replace "/usr/bin/deepin-compressor" "deepin-compressor"
    
    substituteInPlace src/plugins/filemanager/dfmplugin-avfsbrowser/utils/avfsutils.cpp \
      --replace "/usr/bin/mountavfs" "mountavfs" \
      --replace "/usr/bin/umountavfs" "umountavfs"

    substituteInPlace src/plugins/common/core/dfmplugin-menu/{extendmenuscene/extendmenu/dcustomactionparser.cpp,oemmenuscene/oemmenu.cpp} \
      --replace "/usr" "$out"

    substituteInPlace src/tools/upgrade/dialog/processdialog.cpp \
      --replace "/usr/bin/dde-file-manager" "dde-file-manager" \
      --replace "/usr/bin/dde-desktop" "dde-desktop"

    substituteInPlace src/dfm-base/file/local/localfilehandler.cpp \
      --replace "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon" \
      --replace "/usr/bin/x-terminal-emulator" "x-terminal-emulator"

    substituteInPlace src/plugins/desktop/ddplugin-background/backgroundservice.cpp \
      --replace "/usr/share/backgrounds" "/run/current-system/sw/share/backgrounds"

    substituteInPlace src/plugins/desktop/ddplugin-wallpapersetting/wallpapersettings.cpp \
      --replace "/usr/share/backgrounds" "/run/current-system/sw/share/backgrounds"

    find . -type f -regex ".*\\.\\(service\\|policy\\|desktop\\)" -exec sed -i -e "s|/usr/|$out/|g" {} \;

    ######################
    substituteInPlace src/dfm-base/CMakeLists.txt --replace "/usr" "$out"
  '';
  # src/plugins/desktop/core/ddplugin-dbusregister/vaultmanagerdbus.cpp TODO
  # src/plugins/desktop/ddplugin-grandsearchdaemon/CMakeLists.txt 
  # src/plugins/daemon/daemonplugin-accesscontrol/utils.cpp

  buildInputs = [
    dtkwidget
    qt5platform-plugins
    deepin-pdfium
    util-dfm
    dde-qt-dbus-factory
    glibmm
    docparser
    dde-dock.dev
    deepin-movie-reborn.dev
    qtx11extras
    qtmultimedia
    kcodecs
    ffmpegthumbnailer
    libsecret
    libmediainfo
    mediainfo
    poppler
    polkit-qt
    polkit
    lucenepp
    boost
    taglib
    cryptsetup
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-I${libuuid.dev}/include/libmount"
    "-I${libuuid.dev}/include"
  ];

  cmakeFlags = [
    "-DDEEPIN_OS_VERSION=20"
  ];

  enableParallelBuilding = true;

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ mpv ffmpeg ffmpegthumbnailer gst_all_1.gstreamer gst_all_1.gst-plugins-base ]}"
  ];

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "File manager for deepin desktop environment";
    homepage = "https://github.com/linuxdeepin/dde-file-manager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
