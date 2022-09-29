{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
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
, deepin-anything
, deepin-gettext-tools
, deepin-movie-reborn
, deepin-desktop-schemas
, deepin-wallpapers
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
, glib
, dde-daemon
, qtbase
}:
let
  patchList = {
    ### BUILD
    "src/dde-file-manager-lib/dbusinterface/dbusinterface.pri" = [
      [ "/usr/share/dbus-1/interfaces/com.deepin.anything.xml" "${deepin-anything.server}/share/dbus-1/interfaces/com.deepin.anything.xml" ]
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
    "src/deepin-anything-server-plugins/dde-anythingmonitor/dde-anythingmonitor.pro" = [
      [ "\\$\\$system(\\$\\$PKG_CONFIG --variable libdir deepin-anything-server-lib)/deepin-anything-server-lib/plugins/handlers" "$out/lib/deepin-anything-server-lib/plugins/handlers" ]
    ];

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

    "src/dde-zone/mainwindow.h" = [
      [ "/usr/lib/deepin-daemon/desktop-toggle" "${dde-daemon}/lib/deepin-daemon/desktop-toggle" ]
    ];
    # SW_64 ...
    "src/dde-file-manager-lib/sw_label/filemanagerlibrary.h" = [ ];
    "src/dde-file-manager-lib/sw_label/llsdeepinlabellibrary.h" = [ ];

    "src/dde-file-manager-lib/shutil/dsqlitehandle.h" = [
      #["/usr/share/dde-file-manager/database" ] ## TODO
    ];
    "src/dde-file-manager-lib/shutil/mimesappsmanager.cpp" = [
      [ "/usr/share/applications" "/run/current-system/sw/share/applications" ]
      #"/usr/share/applications" ## TODO
    ];

    "src/dde-file-manager-lib/shutil/fileutils.cpp" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      #["/usr/share/applications"] ## TODO
      #["/usr/share/pixmaps"]
      [ "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon" ]
    ];

    "src/dde-file-manager-lib/vault/vaultglobaldefine.h" = [
      #["grep /usr/bin/deepin-compressor"]
    ];

    "src/dde-file-manager-lib/gvfs/networkmanager.cpp" = [
      #["/usr/lib/gvfs/gvfsd"]
    ];

    "src/dde-file-manager-lib/interfaces/dfilemenumanager.cpp" = [
      ## /usr/share/applications/dde-open.desktop 
    ];

    ## PLUGINS
    "src/dde-file-manager-lib/plugins/dfmadditionalmenu.cpp" = [
      ## /usr/share/deepin/dde-file-manager/oem-menuextensions/
    ];
    "src/dde-file-manager-lib/plugins/schemepluginmanager.cpp" = [
      ## /usr/lib/dde-file-manager/addons
    ];

    "src/dde-desktop/view/backgroundmanager.cpp" = [
      [ "/usr/share/backgrounds/default_background.jpg" "${deepin-wallpapers}/share/wallpapers/deepin/desktop.jpg" ]
    ];

    "src/dde-file-manager-lib/interfaces/customization/dcustomactiondefine.h" = [
      ## /usr/share/applications/context-menus
    ];
    "src/dde-desktop/view/canvasgridview.cpp" = [
      ## /usr/share/deepin/dde-desktop-watermask.json
    ];
    "src/dde-file-manager-daemon/accesscontrol/accesscontrolmanager.cpp" = [
      ## "/usr/bin/dmcg" << "/usr/bin/dde-file-manager"
      [ "/etc/deepin" "$out/etc/deepin" ]
      # "/etc/deepin/devAccessConfig.json" "/etc/deepin/vaultAccessConfig.json"
    ];
    "src/dde-wallpaper-chooser/frame.cpp" = [
      [ "/usr/share/backgrounds/default_background.jpg" "${deepin-wallpapers}/share/wallpapers/deepin/desktop.jpg" ]
    ];
    "src/dde-file-manager-daemon/vault/vaultbruteforceprevention.cpp" = [
      # {"/usr/bin/dde-file-manager", "/usr/bin/dde-desktop", "/usr/bin/dde-select-dialog-wayland", "/usr/bin/dde-select-dialog-x11"};
    ];

    "src/utils/utils.cpp" = [
      [ "/bin/bash" "${runtimeShell}" ]
    ];
    "src/dde-file-manager-lib/controllers/fileeventprocessor.cpp" = [
      [ "/bin/bash" "${runtimeShell}" ]
    ];
    "src/dde-advanced-property-plugin/dadvancedinfowidget.cpp" = [
      [ "/bin/bash" "${runtimeShell}" ]
    ];

    ## src/dde-file-manager-lib/models/dfmrootfileinfo.cpp "/etc/%1/ab-recovery.json"

    # src/dde-file-manager-daemon/usershare/usersharemanager.cpp
    # ln -sf /lib/systemd/system/smbd.service /etc/systemd/system/multi-user.target.wants/smbd.service
  };

in
stdenv.mkDerivation rec {
  pname = "dde-file-manager";
  version = "5.6.5";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "a00b3c9b8c983a93e11e57fccd246d3f61baadbb";
    sha256 = "sha256-KRQ0Dp4E6txShji+OimuWcrX/IJFenBj/r7dhhOqXkw=";
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
  
  patches = [
    (fetchpatch {
      name = "chore: avoid hardcode in Shebangs";
      url = "https://github.com/linuxdeepin/dde-file-manager/commit/45f55e570a2ffb13881e5950a5e77694798cc4e4.patch";
      sha256 = "sha256-bHVrKKjCCODyqCklZYxlH6e0etUFvxqicerq51nmjLU=";
    })
    (fetchpatch {
      name = "chore: avoid hardcode";
      url = "https://github.com/linuxdeepin/dde-file-manager/commit/f47acae84862fffeb5c6468c85a1672362261963.patch";
      sha256 = "sha256-wjSeCtb8CdKAUiFUGzaXEPH5Y+oVmGjCjbaEUYMgktk=";
    })
    (fetchpatch {
      name = "chore: avoid hardcode in desktop file";
      url = "https://github.com/linuxdeepin/dde-file-manager/commit/5c720cabce0af873fea6744348148fb43bbfadb7.patch";
      sha256 = "sha256-OjLFN5o7uKgnG0ZnFbbCgPSDpfDq3e3bfZPTbXV6rfQ=";
    })
  ];

  postPatch = getUsrPatchFrom patchList + ''
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
    #deepin-anything
    #deepin-anything.server
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
  ];

  enableParallelBuilding = true;
  #outputs = [ "out" "dev" ];

  qmakeFlags = [
    "filemanager.pro"
    "VERSION=${version}"
    "PREFIX=${placeholder "out"}"
    "LIB_INSTALL_DIR=${placeholder "out"}/lib"
    "INCLUDE_INSTALL_DIR=${placeholder "out"}/include"
    "CONFIG+=DISABLE_ANYTHING"
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
