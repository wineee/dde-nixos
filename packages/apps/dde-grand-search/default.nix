{ stdenv
, lib
, getUsrPatchFrom
, fetchpatch
, fetchFromGitHub
, dtk
, dde-qt-dbus-factory
, dde-dock
, qt5integration
, qt5platform-plugins
, cmake
, qttools
, pkg-config
, gsettings-qt
, taglib
, ffmpeg
, poppler
, pcre
, util-linux
, libselinux
, libsepol
, ffmpegthumbnailer
, wrapQtAppsHook
, dbus
, qtbase
}:
let
  patchList = {
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
  version = "5.3.2+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "9fcde3ea9b152233d19a750e14d1c2681676b6c0";
    sha256 = "sha256-pXMTsOFar0nJDAlzjOkkO+D/XpEmhf8DYA37cR0XKbU=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/dde-grand-search/commit/4e1cc361554774b74d52d819cc42bbd89a21567c.patch";
      sha256 = "sha256-ZBqbYAYf6XenR++FDbyUg0bKDThOD9aWzT9JxDZjv5g=";
    })
  ];

  postPatch = getUsrPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
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
    util-linux.dev
    ffmpegthumbnailer
  ];

  cmakeFlags = [ 
    "-DVERSION=${version}" 
  ];

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
