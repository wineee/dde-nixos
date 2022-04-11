{ pkgs ? import <nixpkgs> {} }:
let 
  makeScope = pkgs.lib.makeScope;

  newScope = pkgs.libsForQt5.newScope;
  
  packages = self: with self; {
    deepin-desktop-base = callPackage ./pkgs/deepin-desktop-base { };
    dde-qt-dbus-factory = callPackage ./pkgs/dde-qt-dbus-factory { };
    dtkcommon = callPackage ./pkgs/dtkcommon { };
    dtkcore = callPackage ./pkgs/dtkcore { };
    dtkgui = callPackage ./pkgs/dtkgui { };
    dtkwidget = callPackage ./pkgs/dtkwidget { };
    qt5platform-plugins = callPackage ./pkgs/qt5platform-plugins { };
    qt5integration = callPackage ./pkgs/qt5integration { };
    image-editor = callPackage ./pkgs/image-editor { };
    gio-qt = callPackage ./pkgs/gio-qt { };
    udisks2-qt5 = callPackage ./pkgs/udisks2-qt5 { };
    deepin-gettext-tools = callPackage ./pkgs/deepin-gettext-tools { };
    deepin-album = callPackage ./pkgs/deepin-album { };
    deepin-image-viewer = callPackage ./pkgs/deepin-image-viewer { };
    deepin-boot-maker = callPackage ./pkgs/deepin-boot-maker { };
    deepin-calculator = callPackage ./pkgs/deepin-calculator { };
    deepin-font-manager = callPackage ./pkgs/deepin-font-manager { };
    dde-clipboard = callPackage ./pkgs/dde-clipboard { };
    deepin-system-monitor = callPackage ./pkgs/deepin-system-monitor { };
    deepin-icon-theme = callPackage ./pkgs/deepin-icon-theme { };
    deepin-anything = callPackage ./pkgs/deepin-anything { };
    dmarked = callPackage ./pkgs/dmarked { };
    deepin-picker = callPackage ./pkgs/deepin-picker { };
    deepin-draw = callPackage ./pkgs/deepin-draw { };
    deepin-wallpapers = callPackage ./pkgs/deepin-wallpapers { };
    # Lib
    disomaster = callPackage ./pkgs/disomaster { };
   

    # Go Packages
    go-dbus-factory = callPackage ./pkgs/go-dbus-factory { };
    go-gir-generator = callPackage ./pkgs/go-gir-generator { };
    go-lib = callPackage ./pkgs/go-lib { };
    dde-api = callPackage ./pkgs/dde-api { };
    deepin-desktop-schemas = callPackage ./pkgs/deepin-desktop-schemas { };
    #dde-daemon
    #startdde

    # Dtk Application
    dde-calendar = callPackage ./pkgs/dde-calendar { };
    deepin-compressor = callPackage ./pkgs/deepin-compressor { };
    deepin-terminal = callPackage ./pkgs/deepin-terminal { };

    # break, need fix
    deepin-camera = callPackage ./pkgs/deepin-camera { };
    deepin-devicemanager = callPackage ./pkgs/deepin-devicemanager { };

    # kde package
    libqtapt = callPackage ./pkgs/libqtapt { };
  };
in
makeScope newScope packages
