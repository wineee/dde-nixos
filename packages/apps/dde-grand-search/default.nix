{ stdenv
, lib
, getUsrPatchFrom
, fetchpatch
, fetchFromGitHub
, dtkwidget
, dde-qt-dbus-factory
, dde-dock
, qt5integration
, qt5platform-plugins
, image-editor
, deepin-pdfium
, cmake
, qttools
, pkg-config
, gsettings-qt
, taglib
, ffmpeg
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
  version = "6.0.0.999";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "a32e46ee55ca69f54e2cd1c96a5519009c44aa7c";
    sha256 = "sha256-lt2kLmIt67LFdhubmA67+8UwuA4Jee/zhVNdVDBCXsI=";
  };

  postPatch = getUsrPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    dde-dock
    dde-qt-dbus-factory
    taglib
    ffmpeg
    ffmpegthumbnailer
    image-editor
    deepin-pdfium
    qt5integration
    qt5platform-plugins
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
    "-DDEEPIN_OS_VERSION=23"
  ];

  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ image-editor ]}"
  ];

  meta = with lib; {
    description = "System-wide desktop search for DDE";
    homepage = "https://github.com/linuxdeepin/dde-grand-search";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
