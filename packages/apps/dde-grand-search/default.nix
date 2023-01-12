{ stdenv
, lib
, getUsrPatchFrom
, fetchpatch
, fetchFromGitHub
, dtk
, dde-qt-dbus-factory
, dde-dock
, qt5integration
, image-editor
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
      [ "/usr/share/applications/dde-control-center.desktop" "/run/current-system/sw/share/applications/dde-control-center.desktop" ]
    ];
    "src/libgrand-search-daemon/dbusservice/grandsearchinterface.cpp" = [
      [ "/usr/bin/dde-grand-search" "$out/bin/.dde-grand-search-wrapped" ] # fix access permit to daemon
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-grand-search";
  version = "5.4.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-OMLZgPE2OH1jItbfGiUAi9SkzcUVLNLbSwgKafAGC10=";
  };

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
    image-editor
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ image-editor ]}"
  ];

  meta = with lib; {
    description = "System-wide desktop search for DDE";
    homepage = "https://github.com/linuxdeepin/dde-grand-search";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
