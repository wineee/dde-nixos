{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, replaceAll
, fetchpatch
, runtimeShell
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, udisks2-qt5
, gio-qt
, docparser
, disomaster
, dde-dock
#, deepin-anything
, deepin-gettext-tools
, deepin-movie-reborn
, deepin-desktop-schemas
, qmake
, qttools
, qtx11extras
, qtmultimedia
, kcodecs
, pkg-config
, jemalloc
, ffmpegthumbnailer
, libsecret
, libmediainfo
, mediainfo
, libzen
, lxqt
, poppler
, polkit-qt
, polkit
, pcre
, wrapQtAppsHook
, wrapGAppsHook
, lucenepp
, boost
, taglib
, cryptsetup
, glib
, qtbase
}:
let
  patchList = {
    ### BUILD
    "src/dde-file-manager-lib/dbusinterface/dbusinterface.pri" = [
 #     [ "/usr/share/dbus-1/interfaces/com.deepin.anything.xml" "${deepin-anything.server}/share/dbus-1/interfaces/com.deepin.anything.xml" ]
    ];
    ### INSTALL
    "src/dde-file-manager/dde-file-manager.pro" = [
      [ "/etc/xdg/autostart" "$out/etc/xdg/autostart" ]
    ];
    "src/dde-select-dialog-x11/dde-select-dialog-x11.pro" = [ ];
    "src/dde-dock-plugins/disk-mount/disk-mount.pro" = [
       ["/usr/include/dde-dock" "${dde-dock.dev}/include/dde-dock"]
    ];
    "src/gschema/gschema.pro" = [ ];
    "src/common/common.pri" = [
      [ "LIB_INSTALL_DIR = \\$\\$[QT_INSTALL_LIBS]" "" ]
      [ "CONFIG += ENABLE_ANYTHING" "" ] # disable deepin-anything
    ];
    "src/dde-file-manager-daemon/dde-file-manager-daemon.pro" = [
      [ "/etc/dbus-1/system.d" "$out/etc/dbus-1/system.d" ]
    ];
    "src/dde-select-dialog-wayland/dde-select-dialog-wayland.pro" = [ ];
    "src/dde-desktop/development.pri" = [ ];
    "src/dde-file-manager-lib/dde-file-manager-lib.pro" = [
      # /usr/include/boost/
    ];
    "src/dde-desktop/dbus/filedialog/filedialog.pri" = [ ];
    "src/dde-desktop/dbus/filemanager1/filemanager1.pri" = [ ];
#    "src/deepin-anything-server-plugins/dde-anythingmonitor/dde-anythingmonitor.pro" = [
#      [ "\\$\\$system(\\$\\$PKG_CONFIG --variable libdir deepin-anything-server-lib)/deepin-anything-server-lib/plugins/handlers" "$out/lib/deepin-anything-server-lib/plugins/handlers" ]
#    ];

    ### MISC
    "src/dde-file-manager-daemon/dbusservice/dde-filemanager-daemon.service" = [ ];
    "src/dde-file-manager-daemon/dbusservice/com.deepin.filemanager.daemon.service" = [ ];
    "src/dde-desktop/dbus/filemanager1/org.freedesktop.FileManager.service" = [ ];
    "src/dde-select-dialog-x11/com.deepin.filemanager.filedialog_x11.service" = [ ];
    "src/dde-select-dialog-wayland/com.deepin.filemanager.filedialog_wayland.service" = [ ];
    "src/dde-desktop/dbus/filedialog/com.deepin.filemanager.filedialog.service" = [ ];
    "src/dde-desktop/data/com.deepin.dde.desktop.service" = [ ];
    "src/dbusservices/com.deepin.dde.desktop.service" = [ ];

    ### CODE
    "src/dde-file-manager-lib/shutil/mimesappsmanager.cpp" = [
      [ "/usr/share/applications" "/run/current-system/sw/share/applications" ]
    ];
    "src/dde-file-manager-lib/shutil/fileutils.cpp" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
    ];
    "src/dde-file-manager-lib/vault/vaultglobaldefine.h" = [
      [ "/usr/bin/deepin-compressor" "deepin-compressor" ]
    ];
    "src/dde-file-manager-lib/interfaces/dfilemenumanager.cpp" = [
      # /usr/share/applications/dde-open.desktop 
    ];

    ## PLUGINS
    "src/dde-file-manager-lib/plugins/dfmadditionalmenu.cpp" = [
      # /usr/share/deepin/dde-file-manager/oem-menuextensions/
    ];
    "src/dde-file-manager-lib/interfaces/customization/dcustomactiondefine.h" = [
      # /usr/share/applications/context-menus
    ];
    "src/dde-desktop/view/canvasgridview.cpp" = [
      # /usr/share/deepin/dde-desktop-watermask.json
    ];
    "src/dde-file-manager-daemon/accesscontrol/accesscontrolmanager.cpp" = [
      # "/usr/bin/dmcg" << "/usr/bin/dde-file-manager"
      # "/etc/deepin/devAccessConfig.json" "/etc/deepin/vaultAccessConfig.json"
    ];
    "src/dde-file-manager-daemon/vault/vaultbruteforceprevention.cpp" = [ ];
    # src/dde-file-manager-daemon/usershare/usersharemanager.cpp
    # ln -sf /lib/systemd/system/smbd.service /etc/systemd/system/multi-user.target.wants/smbd.service
  };

in
stdenv.mkDerivation rec {
  pname = "dde-file-manager";
  version = "5.8.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-+pd0YLcaq3fGZImm6wt1QW/eIDnXkLoqmFOrwNexn80=";
  };

  nativeBuildInputs = [
    qmake
    qttools
    pkg-config
    deepin-gettext-tools
    wrapQtAppsHook
    wrapGAppsHook
  ];
  dontWrapGApps = true;

  postPatch = replaceAll "/bin/bash" "${runtimeShell}"
    + replaceAll "/usr/bin/deepin-desktop-ts-convert" "deepin-desktop-ts-convert"
    + replaceAll "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"
    + replaceAll "/usr/share/backgrounds" "/run/current-system/sw/share/backgrounds"
    + replaceAll "/usr/lib/dde-file-manager" "$out/lib/dde-file-manager"
    + replaceAll "/usr/lib/gvfs/gvfsd" "gvfsd" # TODO
    + replaceAll "/usr/share/dde-file-manager/database" "/var/db/dde-file-manager/database"
    + getUsrPatchFrom patchList
    + ''
    patchShebangs .
  '';

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    udisks2-qt5
    disomaster
    gio-qt
    docparser
    dde-dock.dev
 #   deepin-anything
 #   deepin-anything.server
    deepin-movie-reborn.dev
    deepin-desktop-schemas
    qtx11extras
    qtmultimedia
    kcodecs
    jemalloc
    ffmpegthumbnailer
    libzen
    libsecret
    libmediainfo
    mediainfo
    lxqt.libqtxdg
    poppler
    polkit-qt
    polkit
    pcre
    lucenepp
    boost
    taglib
    cryptsetup
  ];

  enableParallelBuilding = true;

  qmakeFlags = [
    "filemanager.pro"
    "VERSION=${version}"
    "PREFIX=${placeholder "out"}"
    "LIB_INSTALL_DIR=${placeholder "out"}/lib"
    "INCLUDE_INSTALL_DIR=${placeholder "out"}/include"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
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
