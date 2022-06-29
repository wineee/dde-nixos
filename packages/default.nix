{ pkgs ? import <nixpkgs> { } }:
let
  makeScope = pkgs.lib.makeScope;

  newScope = pkgs.libsForQt5.newScope;

  functions = with pkgs.lib; {
    getShebangsPatchFrom = x: "patchShebangs " + concatStringsSep " " x + "\n";

    getPatchFrom = let
        rpstr = a: b: " --replace \"${a}\" \"${b}\"";
        rpstrL = l: if length l == 2 then rpstr (head l) (last l) else (throw "input must be a 2-tuple");
        rpfile = filePath: replaceLists:
          "substituteInPlace ${filePath}" + concatMapStrings rpstrL replaceLists;
        commonRp = [ [ "/usr" "$out" ] ];
      in
      x: pipe x [
        (x: mapAttrs (name: value: value ++ commonRp) x)
        (x: mapAttrsToList (name: value: rpfile name value) x)
        (concatStringsSep "\n")
        (s: s + "\n")
      ];
  };

  packages = self: with self; functions // {
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
    dtk = [ dtkcommon dtkcore dtkgui dtkwidget ];

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
    deepin-gtk-theme = callPackage ./misc/deepin-gtk-theme { };
    deepin-turbo = callPackage ./misc/deepin-turbo { };
    dde-session-shell = callPackage ./misc/dde-session-shell { };
    dde-session-ui = callPackage ./misc/dde-session-ui { };
    dde-account-faces = callPackage ./misc/dde-account-faces { };

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
    dde-kwin = callPackage ./apps/dde-kwin { };
    dde-calendar = callPackage ./apps/dde-calendar { };
    dde-clipboard = callPackage ./apps/dde-clipboard { };
    dde-dock = callPackage ./apps/dde-dock { };
    dde-device-formatter = callPackage ./apps/dde-device-formatter { };
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
    dmarked = callPackage ./apps/dmarked { };
    deepin-picker = callPackage ./apps/deepin-picker { };
    deepin-draw = callPackage ./apps/deepin-draw { };
    dde-control-center = callPackage ./apps/dde-control-center { };
    dde-launcher = callPackage ./apps/dde-launcher { };
    deepin-camera = callPackage ./apps/deepin-camera { };
    dde-file-manager = callPackage ./apps/dde-file-manager { };
    deepin-devicemanager = callPackage ./apps/deepin-devicemanager { };
    deepin-screen-recorder = callPackage ./apps/deepin-screen-recorder { };
    deepin-clone = callPackage ./apps/deepin-clone { };
    deepin-shortcut-viewer = callPackage ./apps/deepin-shortcut-viewer { };
    deepin-downloader = callPackage ./apps/deepin-downloader { };
    deepin-voice-note = callPackage ./apps/deepin-voice-note { };
    deepin-reader = callPackage ./apps/deepin-reader { };
    deepin-gomoku = callPackage ./apps/deepin-gomoku { };
    deepin-lianliankan = callPackage ./apps/deepin-lianliankan { };
  };
in
makeScope newScope packages
