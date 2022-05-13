{ pkgs ? import <nixpkgs> { } }:
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
    docparser = callPackage ./library/docparser { };
    dtk = [
      dtkcommon
      dtkcore
      dtkgui
      dtkwidget
    ];

    ## TMP
    lucenecpp = callPackage ./library/lucenecpp { };

    #### MISC
    dde-polkit-agent = callPackage ./misc/dde-polkit-agent { };
    dpa-ext-gnomekeyring = callPackage ./misc/dpa-ext-gnomekeyring { };
    deepin-desktop-base = callPackage ./misc/deepin-desktop-base { };
    deepin-gettext-tools = callPackage ./misc/deepin-gettext-tools { };
    deepin-icon-theme = callPackage ./misc/deepin-icon-theme { };
    deepin-anything = callPackage ./misc/deepin-anything { };
    deepin-wallpapers = callPackage ./misc/deepin-wallpapers { };
    deepin-sound-theme = callPackage ./misc/deepin-sound-theme { };

    #### Go Packages
    go-dbus-factory = callPackage ./go-package/go-dbus-factory { };
    go-gir-generator = callPackage ./go-package/go-gir-generator { };
    go-lib = callPackage ./go-package/go-lib { };
    dde-api = callPackage ./go-package/dde-api { };
    deepin-desktop-schemas = callPackage ./go-package/deepin-desktop-schemas { };
    dde-daemon = callPackage ./go-package/dde-daemon { };
    deepin-pw-check = callPackage ./go-package/deepin-pw-check { };
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
    dde-control-center = callPackage ./apps/dde-control-center { };
    deepin-camera = callPackage ./apps/deepin-camera { };
    deepin-file-manager = callPackage ./apps/deepin-file-manager { };
    deepin-devicemanager = callPackage ./apps/deepin-devicemanager { };
    deepin-screen-recorder = callPackage ./apps/deepin-screen-recorder { };
    deepin-clone = callPackage ./apps/deepin-clone { };
  };
in
makeScope newScope packages
