{ pkgs ? import <nixpkgs> { } }:
let
  makeScope = pkgs.lib.makeScope;

  newScope = pkgs.deepin.newScope;

  packages = self: with self; {

    ### CORE
    dde-kwin = callPackage ./core/dde-kwin { };
    deepin-kwin = callPackage ./core/deepin-kwin { };
    #### MISC
    nixos-gsettings-schemas = callPackage ./misc/nixos-gsettings-schemas { };

    #### Go Packages
    #dde-daemon = callPackage ./go-package/dde-daemon { };
    #startdde = callPackage ./go-package/startdde { };

    #### Dtk Application
    #dde-grand-search = callPackage ./apps/dde-grand-search { };
    #dde-introduction = callPackage ./apps/dde-introduction { };
    #deepin-boot-maker = callPackage ./apps/deepin-boot-maker { };
    #deepin-font-manager = callPackage ./apps/deepin-font-manager { };
    #deepin-system-monitor = callPackage ./apps/deepin-system-monitor { };
    #deepin-screen-recorder = callPackage ./apps/deepin-screen-recorder { };
    #deepin-downloader = callPackage ./apps/deepin-downloader { };
    #deepin-gomoku = callPackage ./apps/deepin-gomoku { };
    #deepin-lianliankan = callPackage ./apps/deepin-lianliankan { };
    #deepin-ocr = callPackage ./apps/deepin-ocr { };

    #### OS-SPECIFIC
    ## pkgs/top-level/linux-kernels.nix
    # deepin-anything-module = _kernel: callPackage ./os-specific/deepin-anything-module {
    #   kernel = _kernel;
    # };

    #### THIRD-PARTY
    # dde-top-panel = callPackage ./third-party/dde-top-panel { };
    # dmarked = callPackage ./third-party/dmarked { };
  };
in
makeScope newScope packages
