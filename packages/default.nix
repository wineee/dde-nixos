{ pkgs ? import <nixpkgs> { } }:
let
  makeScope = pkgs.lib.makeScope;

  newScope = pkgs.libsForQt5.newScope;

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
    #### LIBRARIES
    dtkcommon = callPackage ./library/dtkcommon { };
    dtkcore = callPackage ./library/dtkcore { };
    dtkgui = callPackage ./library/dtkgui { };
    dtkwidget = callPackage ./library/dtkwidget { };
    disomaster = callPackage ./library/disomaster { };
    image-editor = callPackage ./library/image-editor { };
    gio-qt = callPackage ./library/gio-qt { };
    udisks2-qt5 = callPackage ./library/udisks2-qt5 { };
    dde-qt-dbus-factory = callPackage ./library/dde-qt-dbus-factory { };
    qt5platform-plugins = callPackage ./library/qt5platform-plugins { };
    qt5integration = callPackage ./library/qt5integration { };
    docparser = callPackage ./library/docparser { };
    dwayland = callPackage ./library/dwayland { };
    deepin-wayland-protocols = callPackage ./library/deepin-wayland-protocols { };
    dtk = [ dtkcommon dtkcore dtkgui dtkwidget /*qt5integration*/ qt5platform-plugins ];
    qt5integration-styles = callPackage ./library/qt5integration-styles { };

    #### artwork
    deepin-icon-theme = callPackage ./artwork/deepin-icon-theme { };
    deepin-gtk-theme = callPackage ./artwork/deepin-gtk-theme { };
    deepin-wallpapers = callPackage ./artwork/deepin-wallpapers { };
    deepin-sound-theme = callPackage ./artwork/deepin-sound-theme { };
    dde-account-faces = callPackage ./artwork/dde-account-faces { };

    #### TOOLS
    deepin-gettext-tools = callPackage ./tools/deepin-gettext-tools { };
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
    dde-polkit-agent = callPackage ./core/dde-polkit-agent { };
    dpa-ext-gnomekeyring = callPackage ./core/dpa-ext-gnomekeyring { };

    #### MISC
    deepin-desktop-base = callPackage ./misc/deepin-desktop-base { };
    deepin-turbo = callPackage ./misc/deepin-turbo { };
    nixos-gsettings-schemas = callPackage ./misc/nixos-gsettings-schemas { };

    #### Go Packages
    go-dbus-factory = callPackage ./go-package/go-dbus-factory { };
    go-gir-generator = callPackage ./go-package/go-gir-generator { };
    go-lib = callPackage ./go-package/go-lib { };
    dde-api = callPackage ./go-package/dde-api { };
    deepin-desktop-schemas = callPackage ./go-package/deepin-desktop-schemas { };
    dde-daemon = callPackage ./go-package/dde-daemon { };
    deepin-pw-check = callPackage ./go-package/deepin-pw-check { };
    startdde = callPackage ./go-package/startdde { };

    #### Dtk Application
    dde-grand-search = callPackage ./apps/dde-grand-search { };
    dde-introduction = callPackage ./apps/dde-introduction { };
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
    deepin-picker = callPackage ./apps/deepin-picker { };
    deepin-draw = callPackage ./apps/deepin-draw { };
    deepin-camera = callPackage ./apps/deepin-camera { };
    deepin-devicemanager = callPackage ./apps/deepin-devicemanager { };
    deepin-screen-recorder = callPackage ./apps/deepin-screen-recorder { };
    deepin-clone = callPackage ./apps/deepin-clone { };
    deepin-shortcut-viewer = callPackage ./apps/deepin-shortcut-viewer { };
    deepin-downloader = callPackage ./apps/deepin-downloader { };
    deepin-voice-note = callPackage ./apps/deepin-voice-note { };
    deepin-reader = callPackage ./apps/deepin-reader { };
    deepin-gomoku = callPackage ./apps/deepin-gomoku { };
    deepin-lianliankan = callPackage ./apps/deepin-lianliankan { };

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
