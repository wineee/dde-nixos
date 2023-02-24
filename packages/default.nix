{ pkgs ? import <nixpkgs> { } }:
let
  makeScope = pkgs.lib.makeScope;

  newScope = pkgs.deepin.newScope;

  functions = with pkgs; rec {
    getPatchFrom' = commonRp:
      let
        rpstr = a: b: " --replace \"${a}\" \"${b}\"";
        rpstrL = l: if lib.length l == 2 then rpstr (lib.head l) (lib.last l) else (throw "input must be a list of 2 string: [original  ]");
        rpfile = filePath: replaceLists:
          "substituteInPlace ${filePath}" + lib.concatMapStrings rpstrL replaceLists;
      in
      x: lib.pipe x [
        (x: lib.mapAttrs (name: value: value ++ commonRp) x)
        (x: lib.mapAttrsToList (name: value: rpfile name value) x)
        (lib.concatStringsSep "\n")
        (s: s + "\n")
      ];

    getPatchFrom = getPatchFrom' [ ];
    getUsrPatchFrom = getPatchFrom' [ [ "/usr" "$out" ] ];

    replaceAll = x: y: ''
      echo Replacing "${x}" to "${y}":
      for file in $(grep -rl "${x}")
      do
        echo -- $file
        substituteInPlace $file \
          --replace "${x}" "${y}"
      done
    '';
  };

  packages = self: with self; functions // {
    #### TOOLS
    deepin-anything = callPackage ./tools/deepin-anything { };
    dde-device-formatter = callPackage ./tools/dde-device-formatter { };

    ### CORE
    dde-kwin = callPackage ./core/dde-kwin { };
    deepin-kwin = callPackage ./core/deepin-kwin { };
    dde-dock = callPackage ./core/dde-dock { };
    dde-launcher = callPackage ./core/dde-launcher { };
    dde-control-center = callPackage ./core/dde-control-center { };
    dde-file-manager = callPackage ./core/dde-file-manager { };
    dde-calendar = callPackage ./core/dde-calendar { };
    dde-clipboard = callPackage ./core/dde-clipboard { };
    dde-app-services = callPackage ./core/dde-app-services { };
    dde-network-core = callPackage ./core/dde-network-core { };
    dde-session-shell = callPackage ./core/dde-session-shell { };
    dde-session-ui = callPackage ./core/dde-session-ui { };

    #### MISC
    nixos-gsettings-schemas = callPackage ./misc/nixos-gsettings-schemas { };

    #### Go Packages
    deepin-desktop-schemas = callPackage ./go-package/deepin-desktop-schemas { };
    dde-daemon = callPackage ./go-package/dde-daemon { };
    startdde = callPackage ./go-package/startdde { };

    #### Dtk Application
    dde-grand-search = callPackage ./apps/dde-grand-search { };
    dde-introduction = callPackage ./apps/dde-introduction { };
    deepin-music = callPackage ./apps/deepin-music { };
    deepin-movie-reborn = callPackage ./apps/deepin-movie-reborn { };
    deepin-boot-maker = callPackage ./apps/deepin-boot-maker { };
    deepin-font-manager = callPackage ./apps/deepin-font-manager { };
    deepin-system-monitor = callPackage ./apps/deepin-system-monitor { };
    deepin-camera = callPackage ./apps/deepin-camera { };
    deepin-screen-recorder = callPackage ./apps/deepin-screen-recorder { };
    deepin-clone = callPackage ./apps/deepin-clone { };
    deepin-shortcut-viewer = callPackage ./apps/deepin-shortcut-viewer { };
    deepin-downloader = callPackage ./apps/deepin-downloader { };
    deepin-gomoku = callPackage ./apps/deepin-gomoku { };
    deepin-lianliankan = callPackage ./apps/deepin-lianliankan { };
    deepin-ocr = callPackage ./apps/deepin-ocr { };

    #### OS-SPECIFIC
    ## pkgs/top-level/linux-kernels.nix
    deepin-anything-module = _kernel: callPackage ./os-specific/deepin-anything-module {
      kernel = _kernel;
    };

    #### THIRD-PARTY
    dde-top-panel = callPackage ./third-party/dde-top-panel { };
    dmarked = callPackage ./third-party/dmarked { };
  };
in
makeScope newScope packages
