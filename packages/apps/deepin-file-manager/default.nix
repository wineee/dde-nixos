{ stdenv
, lib
, fetchFromGitHub
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, udisks2-qt5
, gio-qt
, docparser
, disomaster
, deepin-anything
, qmake
, qttools
, qtx11extras
, qtmultimedia
, kcodecs
, pkgconfig
, jemalloc
, ffmpegthumbnailer
, libsecret
, libmediainfo
, mediainfo
, lxqt
, poppler
, polkit-qt
, polkit
, wrapQtAppsHook
, libzen
, lucenecpp # todo
, boost
}:

stdenv.mkDerivation rec {
  pname = "dde-file-manager";
  version = "5.5.10";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-YfX1T6peoX9EttodTbsAAofUEOMacpTtdQb5gKdMaUE=";
  };

  nativeBuildInputs = [
    qmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    udisks2-qt5
    disomaster
    gio-qt
    docparser
    deepin-anything
    qtx11extras
    qtmultimedia
    kcodecs
    jemalloc
    ffmpegthumbnailer
    libsecret
    libmediainfo
    mediainfo

    lxqt.libqtxdg
    poppler
    polkit-qt
    polkit

    libzen # libmediainfo
    lucenecpp
    boost # lucenepp
  ];
  enableParallelBuilding = false;

  postPatch = ''
    patchShebangs src/dde-file-manager-lib/generate_translations.sh src/dde-file-manager-lib/update_translations.sh

    substituteInPlace src/dde-file-manager-lib/dbusinterface/dbusinterface.pri \
      --replace '/usr/share/dbus-1/interfaces/com.deepin.anything.xml' '${deepin-anything}/usr/share/dbus-1/interfaces/com.deepin.anything.xml'
  '';

  qmakeFlags = [
    "filemanager.pro"
    "BINDIR=${placeholder "out"}/bin"
    "ICONDIR=${placeholder "out"}/share/icons/hicolor/scalable/apps"
    "APPDIR=${placeholder "out"}/share/applications"
    "DSRDIR=${placeholder "out"}/share/deepin-picker"
    "DOCDIR=${placeholder "out"}/share/dman/deepin-picker"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  meta = with lib; {
    description = "File manager for deepin desktop environment";
    homepage = "https://github.com/linuxdeepin/deepin-file-manager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
