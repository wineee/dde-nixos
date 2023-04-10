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
, libselinux
, glibmm
, pcre
, udisks2
, libisoburn
}:

stdenv.mkDerivation rec {
  pname = "dde-file-manager";
  version = "6.0.13";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-Kn8LuAQNWY2SwzKjMyylEAlQNxsP+3bl5hM83yHfjvo=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
    wrapGAppsHook
  ];
  dontWrapGApps = true;

  patches = [
    (fetchpatch {
      name = "chore: [cmake] use CMAKE_INSTALL_SYSCONFDIR";
      url = "https://github.com/linuxdeepin/dde-file-manager/commit/bca4bb7de20074cef4139cd6f8415408103b9788.patch";
      sha256 = "sha256-GEMuMa1UMSGf0dlHZRQyR1hC08U0GlAlmUKLIxzzoc4=";
    })
    (fetchpatch {
      name = "feat: GRANDSEARCHDAEMON_LIB_DIR use CMAKE_INSTALL_FULL_LIBDIR";
      url = "https://github.com/linuxdeepin/dde-file-manager/commit/0fd0a13b4f882c597a02f4661c02c840830fc173.patch";
      sha256 = "sha256-athDoFhQ9v9cXOf4YKmZld1RScX43+6/q1zBa/1yAgQ=";
    })
    (fetchpatch {
      name = "fix: include path should follow Qt5Widgets_PRIVATE_INCLUDE_DIRS";
      url = "https://github.com/linuxdeepin/dde-file-manager/commit/20bb841a5e3ffb04d6316ea573422701ca9058f9.patch";
      sha256 = "sha256-VPyiKKxFgNsY70ZdYE5oNF8BFosq/92YrZuZ882Fj4E=";
    })
    (fetchpatch {
      name = "chore: don't hardcode APPSHAREDIR";
      url = "https://github.com/linuxdeepin/dde-file-manager/commit/0e0430e158049423ed5f99f124c8c6ae3bec1497.patch";
      sha256 = "sha256-oZQcuPP9JTZ7aybPnmY/6RyqmJhvpxer4mhv+XpqeQY=";
    })
    (fetchpatch {
      name = "fix: use pkgconfig to check mount";
      url = "https://github.com/linuxdeepin/dde-file-manager/commit/c569f09b84159583dd2fc71436858143b94c58f3.patch";
      sha256 = "sha256-k808IsaV/RJg7bYNmUnhcFZMnMRQ8sGRagMlx5i4h4Q=";
    })
  ];

  postPatch = ''
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
      --replace "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"

    substituteInPlace src/plugins/desktop/ddplugin-background/backgroundservice.cpp \
      src/plugins/desktop/ddplugin-wallpapersetting/wallpapersettings.cpp \
      --replace "/usr/share/backgrounds" "/run/current-system/sw/share/backgrounds"

    find . -type f -regex ".*\\.\\(service\\|policy\\|desktop\\)" -exec sed -i -e "s|/usr/|$out/|g" {} \;
  '';
  # src/plugins/desktop/core/ddplugin-dbusregister/vaultmanagerdbus.cpp TODO
  # src/plugins/daemon/daemonplugin-accesscontrol/utils.cpp

  buildInputs = [
    dtkwidget
    qt5platform-plugins
    qt5integration
    deepin-pdfium
    util-dfm
    dde-qt-dbus-factory
    glibmm
    docparser
    dde-dock.dev
    deepin-movie-reborn
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
    libuuid
    libselinux
    pcre
    udisks2
    libisoburn
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
    "-DDEEPIN_OS_VERSION=20"
  ];

  enableParallelBuilding = true;

  qtWrapperArgs = [
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
