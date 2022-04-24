{ pkgs ? import <nixpkgs> {} }:
let 
  makeScope = pkgs.lib.makeScope;

  newScope = pkgs.libsForQt5.newScope;
  
  packages = self: with self; {
    #### LIBRARIES
    dtkcommon = callPackage ./library/dtkcommon { };
    dtkcore = callPackage ./library/dtkcore { };
    dtkgui = callPackage ./library/dtkgui { };
    dtkwidget = callPackage ./library/dtkwidget { };
    disomaster = callPackage ./library/disomaster { };
    qtmpris = callPackage ./library/qtmpris { };
    qtdbusextended = callPackage ./library/qtdbusextended { };
    image-editor = callPackage ./library/image-editor { };
    gio-qt = callPackage ./library/gio-qt { };
    udisks2-qt5 = callPackage ./library/udisks2-qt5 { };
    dde-qt-dbus-factory = callPackage ./library/dde-qt-dbus-factory { };
    qt5platform-plugins = callPackage ./library/qt5platform-plugins { };
    qt5integration = callPackage ./library/qt5integration { };
    libqtapt = callPackage ./library/libqtapt { };
    dtk = [
      dtkcommon
      dtkcore
      dtkgui
      dtkwidget
    ];

    #### MISC
    dde-polkit-agent = callPackage ./misc/dde-polkit-agent { };
    deepin-desktop-base = callPackage ./misc/deepin-desktop-base { };
    deepin-gettext-tools = callPackage ./misc/deepin-gettext-tools { };
    deepin-icon-theme = callPackage ./misc/deepin-icon-theme { };
    deepin-anything = callPackage ./misc/deepin-anything { };
    deepin-wallpapers = callPackage ./misc/deepin-wallpapers { };
    
    #### Go Packages
    go-dbus-factory = callPackage ./go-package/go-dbus-factory { };
    go-gir-generator = callPackage ./go-package/go-gir-generator { };
    go-lib = callPackage ./go-package/go-lib { };
    dde-api = callPackage ./go-package/dde-api { };
    deepin-desktop-schemas = callPackage ./go-package/deepin-desktop-schemas { };
    dde-daemon = callPackage ./go-package/dde-daemon { };
    #startdde

    #### Dtk Application
    dde-calendar = callPackage ./apps/dde-calendar { };
    dde-clipboard = callPackage ./apps/dde-clipboard { };
    deepin-compressor = callPackage ./apps/deepin-compressor { };
    deepin-terminal = callPackage ./apps/deepin-terminal { };
    deepin-editor = callPackage ./apps/deepin-editor { };
    deepin-music = callPackage ./apps/deepin-music { };
    deepin-movie-reborn = callPackage ./apps/deepin-movie-reborn { };
    deepin-album = callPackage ./apps/deepin-album { };
    deepin-image-viewer = callPackage ./apps/deepin-image-viewer { };
    deepin-boot-maker = callPackage ./apps/deepin-boot-maker { };
    deepin-calculator = callPackage ./apps/deepin-calculator { };
    deepin-font-manager = callPackage ./apps/deepin-font-manager { };
    deepin-system-monitor = callPackage ./apps/deepin-system-monitor { };
    #dmarked = callPackage ./apps/dmarked { };
    deepin-picker = callPackage ./apps/deepin-picker { };
    deepin-draw = callPackage ./apps/deepin-draw { };

    # break, need fix
    deepin-camera = callPackage ./apps/deepin-camera { };
    #deepin-devicemanager = callPackage ./apps/deepin-devicemanager { };
  };
in
makeScope newScope packages
