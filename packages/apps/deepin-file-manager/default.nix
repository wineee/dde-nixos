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
, deepin-gettext-tools
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
let
  commonRp = [ ["/usr"] ["$out"] ];

  rpstr = a: b: " --replace ${a} ${b}";
  rpstrL = l: if lib.length l == 2 then rpstr (lib.head l) (lib.last l) else (throw "${l} must be a 2-tuple");

  rpfile = filePath: replaceLists:
    "substituteInPlace ${filePath}" + lib.concatMapStrings rpstrL replaceLists;

  rpfilesL = l: lib.mapAttrsToList (name: value: rpfile name value) l;

  getPatchFrom = x: lib.pipe x [
    (x: map (lib.mapAttrs (name: value: value++commonRp)) x)
    (x: map rpfilesL x)
    lib.concatLists
    (lib.concatStringsSep "\n")
  ];

  patchlist = [
    ## BUILD
    {"src/dde-file-manager/translate_ts2desktop.sh" = [
      ["/usr/bin/deepin-desktop-ts-convert" "${deepin-gettext-tools}/bin/deepin-desktop-ts-convert"]
    ];}
    {"src/dde-file-manager-lib/dbusinterface/dbusinterface.pri" = [
      ["/usr/share/dbus-1/interfaces/com.deepin.anything.xml" "${deepin-anything.server}/share/dbus-1/interfaces/com.deepin.anything.xml"]
    ];}
    ## INSTALL
    {"src/dde-file-manager/dde-file-manager.pro" = [
      ["/etc/xdg/autostart" "$out/etc/xdg/autostart"]
    ];}
    {"src/dde-select-dialog-x11/dde-select-dialog-x11.pro" = [ ];}
    {"src/dde-dock-plugins/disk-mount/disk-mount.pro" = [
      # ["/usr/include/dde-dock" "${dde-dock}/include/dde-dock"]
    ];}
    {"src/gschema/gschema.pro" = [ ];}
    {"src/common/common.pri" = [ ];}
    {"src/dde-file-manager-daemon/dde-file-manager-daemon.pro" = [
      ["/etc/dbus-1/system.d" "$out/etc/dbus-1/system.d" ] 
    ];}
    {"src/dde-select-dialog-wayland/dde-select-dialog-wayland.pro" = [ ];}
    {"src/dde-desktop/development.pri" = [ ];}
    {"src/dde-file-manager-lib/dde-file-manager-lib.pro" = [
      # /usr/include/boost/
    ];}
    {"src/dde-desktop/dbus/filedialog/filedialog.pri" = [ ];}
    {"src/dde-desktop/dbus/filemanager1/filemanager1.pri" = [ ];}
  ];
in
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
    deepin-gettext-tools
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

  fixShebangsPatch = ''
    patchShebangs src/dde-file-manager-lib/generate_translations.sh src/dde-file-manager-lib/update_translations.sh
    patchShebangs src/dde-file-manager/translate_ts2desktop.sh src/dde-file-manager/translate_desktop2ts.sh src/dde-file-manager/generate_translations.sh
  '';

  postPatch = fixShebangsPatch + getPatchFrom patchlist;

  qmakeFlags = [
    "filemanager.pro"
    "LIB_INSTALL_DIR=${placeholder "out"}/lib"
    "INCLUDE_INSTALL_DIR=${placeholder "out"}/include"
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
