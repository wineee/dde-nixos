{ pkgs ? import <nixpkgs> { } }:
let
  makeScope = pkgs.lib.makeScope;

  newScope = pkgs.qt6Packages.newScope;

  packages = self: with self; {
    #### LIBRARIES
    dtkcommon = callPackage ./library/dtkcommon { };
    dtkcore = callPackage ./library/dtkcore { };
    dtkgui = callPackage ./library/dtkgui { };
    dtkwidget = callPackage ./library/dtkwidget { };
    # disomaster = callPackage ./library/disomaster { };
    # gio-qt = callPackage ./library/gio-qt { };
    # udisks2-qt5 = callPackage ./library/udisks2-qt5 { };
    # dde-qt-dbus-factory = callPackage ./library/dde-qt-dbus-factory { };
    qt5platform-plugins = callPackage ./library/qt5platform-plugins { };
    qt5integration = callPackage ./library/qt5integration { };
    # docparser = callPackage ./library/docparser { };
    dwayland = callPackage ./library/dwayland { };
    deepin-wayland-protocols = callPackage ./library/deepin-wayland-protocols { };
    dtkdeclarative = callPackage ./library/dtkdeclarative { 
      inherit (pkgs.qt6Packages) qtshadertools qt5compat;
    };
    dtksystemsettings = callPackage ./library/dtksystemsettings { };
  };
in
makeScope newScope packages
