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
    polkit-qt-1 = callPackage ./library/polkit-qt-1 { }; # https://github.com/NixOS/nixpkgs/pull/168603
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
    deepin-desktop-schemas = callPackage ./pkgs/deepin-desktop-schemas { };
    dde-daemon = callPackage ./go-package/dde-daemon { };
    #startdde

    #### Dtk Application
    dde-calendar = callPackage ./pkgs/dde-calendar { };
    dde-clipboard = callPackage ./pkgs/dde-clipboard { };
    deepin-compressor = callPackage ./pkgs/deepin-compressor { };
    deepin-terminal = callPackage ./pkgs/deepin-terminal { };
    deepin-editor = callPackage ./pkgs/deepin-editor { };
    deepin-music = callPackage ./pkgs/deepin-music { };
    deepin-movie-reborn = callPackage ./pkgs/deepin-movie-reborn { };
    deepin-album = callPackage ./pkgs/deepin-album { };
    deepin-image-viewer = callPackage ./pkgs/deepin-image-viewer { };
    deepin-boot-maker = callPackage ./pkgs/deepin-boot-maker { };
    deepin-calculator = callPackage ./pkgs/deepin-calculator { };
    deepin-font-manager = callPackage ./pkgs/deepin-font-manager { };
    deepin-system-monitor = callPackage ./pkgs/deepin-system-monitor { };
    dmarked = callPackage ./pkgs/dmarked { };
    deepin-picker = callPackage ./pkgs/deepin-picker { };
    deepin-draw = callPackage ./pkgs/deepin-draw { };

    # break, need fix
    deepin-camera = callPackage ./pkgs/deepin-camera { };
    deepin-devicemanager = callPackage ./pkgs/deepin-devicemanager { };
  };
in
makeScope newScope packages
