{ stdenv
, lib
, getPatchFrom
, fetchFromGitHub
, dtk
, dde-qt-dbus-factory
, dde-dock
, qt5integration
, qt5platform-plugins
, cmake
, qttools
, pkgconfig
, gsettings-qt
, taglib
, ffmpeg
, poppler
, pcre
, utillinux
, libselinux
, libsepol
, ffmpegthumbnailer
, wrapQtAppsHook
, dbus
, qtbase
}:
let
  patchList = {
    "src/grand-search-daemon/CMakeLists.txt" = [
        [ "/etc/xdg/autostart" "$out/etc/xdg/autostart" ]
    ];
    "src/grand-search-dock-plugin/CMakeLists.txt" = [ ];
    "src/grand-search/CMakeLists.txt" = [ ];
    "CMakeLists.txt" = [ ];

    "src/grand-search-daemon/data/dde-grand-search-daemon.desktop" = [ ];
    "src/grand-search-daemon/data/com.deepin.dde.daemon.GrandSearch.service" = [
        [ "/usr/bin/dbus-send" "${dbus}/bin/dbus-send" ]
    ];
    "src/grand-search/contacts/services/com.deepin.dde.GrandSearch.service" = [ ];

    "src/grand-search/utils/utils.cpp" = [
        [ "/usr/share/applications/dde-control-center.desktop"  "/run/current-system/sw/share/applications/dde-control-center.desktop" ]
    ];
    "src/grand-search-daemon/searcher/app/desktopappsearcher.cpp" = [
        [ "/usr/share" "/run/current-system/sw/share" ] # TODO
    ];
    "src/grand-search-daemon/dbusservice/grandsearchinterface.cpp" = [ ];
  }; 
in stdenv.mkDerivation rec {
  pname = "dde-grand-search";
  version = "5.3.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "9fcde3ea9b152233d19a750e14d1c2681676b6c0";
    sha256 = "sha256-pXMTsOFar0nJDAlzjOkkO+D/XpEmhf8DYA37cR0XKbU=";
  };

  postPatch = getPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [ 
    dtk
    dde-dock
    dde-qt-dbus-factory
    gsettings-qt
    taglib
    ffmpeg.dev
    poppler
    pcre
    libselinux
    libsepol.dev
    utillinux.dev
    ffmpegthumbnailer
    qt5integration
    qt5platform-plugins
  ];

  cmakeFlags = [ 
    "-DVERSION=${version}" 
  ];

  NIX_CFLAGS_COMPILE = "-I${dde-dock.dev}/include/dde-dock";

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "System-wide desktop search for DDE";
    homepage = "https://github.com/linuxdeepin/dde-grand-search";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
