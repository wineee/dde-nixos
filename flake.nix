{
  description = "dde for nixos";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ]
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          deepinScope = import ./packages { inherit pkgs; };
          deepinPkgs = flake-utils.lib.flattenTree deepinScope;
          getDbgVersion = name: value:
              (pkgs.lib.attrsets.nameValuePair
                (name + "-dbg")
                (value.override {
                  stdenv = pkgs.stdenvAdapters.keepDebugInfo pkgs.stdenv;
                }));
          deepinPkgsDbg = with pkgs.lib.attrsets; mapAttrs' getDbgVersion deepinPkgs;
        in
        rec {
          packages = deepinPkgs // deepinPkgsDbg;
          devShells = builtins.mapAttrs (
            name: value: 
              pkgs.mkShell {
                nativeBuildInputs = [ pkgs.qtcreator ]
                        ++ deepinPkgs.${name}.nativeBuildInputs;
                buildInputs = deepinPkgs.${name}.buildInputs
                        ++ deepinPkgs.${name}.propagatedBuildInputs;
                shellHook = ''
                  # export QT_LOGGING_RULES=*.debug=true
                  export QT_PLUGIN_PATH="$QT_PLUGIN_PATH:${deepinPkgs.qt5integration}/plugins"
                  export QT_QPA_PLATFORM_PLUGIN_PATH="${deepinPkgs.qt5platform-plugins}/plugins"
                '';
             }
          ) deepinPkgs;

#          overlays.default = final: prev: {
#            repoOverrides = { dde = (import ./packages { pkgs = prev.pkgs; }); };
#          };

          nixosModules = { config, lib, pkgs, ... }:
            with lib;
            let
              xcfg = config.services.xserver;
              cfg = xcfg.desktopManager.deepin;

              nixos-gsettings-desktop-schemas = packages.nixos-gsettings-schemas.override {
                extraGSettingsOverridePackages = cfg.extraGSettingsOverridePackages;
                extraGSettingsOverrides = cfg.extraGSettingsOverrides;
              };
            in
            {
              options = {
                services.xserver.desktopManager.deepin = {
                  enable = mkOption {
                    type = types.bool;
                    default = false;
                    description = "Enable Deepin desktop manager";
                  };
                  extraGSettingsOverrides = mkOption {
                    default = "";
                    type = types.lines;
                    description = "Additional gsettings overrides.";
                  };
                  extraGSettingsOverridePackages = mkOption {
                    default = [];
                    type = types.listOf types.path;
                    description = "List of packages for which gsettings are overridden.";
                  };
                };

                services.dde = {
                  dde-daemon.enable = mkEnableOption "A daemon for handling Deepin Desktop Environment session settings";
                };

                ## TODO: deepin-anything
                
              };

              config = mkMerge [

                ### TODO
                (mkIf cfg.enable {
                  #services.xserver.displayManager.sessionPackages = [ pkgs.deepin.core ];
                  #services.xserver.displayManager.lightdm.theme = mkDefault "deepin";
                  hardware.bluetooth.enable = mkDefault true;
                  hardware.pulseaudio.enable = mkDefault true;
                  security.polkit.enable = true;
                  services.accounts-daemon.enable = true;
                  programs.dconf.enable = true;
                  services.gnome.gnome-keyring.enable = true;

                  services.udev.packages = [];
                  programs.dconf.packages = [];
                  
                  services.xserver.updateDbusEnvironment = true;
                  services.udisks2.enable = true;
                  services.upower.enable = true;
                  services.power-profiles-daemon.enable = true;


                  environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = "${nixos-gsettings-desktop-schemas}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";

                  environment.pathsToLink = [
                    "/share"
                    #"/share/dsg"
                  ];

                  environment.systemPackages = with packages; [
                    deepin-terminal
                    deepin-album
                    deepin-image-viewer
                    deepin-calculator
                    deepin-editor
                    deepin-music
                    deepin-movie-reborn
                    dde-file-manager
                    dde-launcher
                    dde-calendar 
                    deepin-camera
                    dde-dock
                    dde-session-ui
                    dde-session-shell
                    deepin-system-monitor
                    dde-control-center
                    deepin-picker
                    deepin-shortcut-viewer
                    startdde
                    deepin-screen-recorder
                    dde-app-services
                    
                    deepin-desktop-schemas
                    dde-api
                    dde-daemon

                    dde-polkit-agent
                    dde-account-faces
                    deepin-voice-note
                    deepin-turbo
                    deepin-icon-theme
                    deepin-sound-theme
                    deepin-wallpapers
                    deepin-reader
                    dmarked
                    deepin-downloader
                    deepin-draw
                    deepin-boot-maker
                    deepin-gomoku
                    deepin-lianliankan
                    deepin-font-manager
                  ] ++ (with pkgs; [
                    socat
                    glib
                  ]);

                  services.dbus.packages = with packages; [
                    dde-launcher
                    dde-session-ui
                    dde-session-shell
                    dde-api
                    deepin-image-viewer
                    dde-daemon
                    dde-app-services
                    dde-file-manager
                    dde-control-center
                    dde-calendar

                    dde-dock
                    deepin-anything
                  ];

                  systemd.packages = with packages; [
                    dde-launcher
                    dde-api
                    dde-daemon
                    dde-file-manager
                    dde-calendar

                    deepin-anything
                  ];

                  users.groups.deepin-sound-player = { };
                  users.users.deepin-sound-player = {
                    description = "Deepin sound player";
                    group = "deepin-sound-player";
                    isSystemUser = true;
                  };

                  users.groups.deepin-daemon = { };
                  users.users.deepin-daemon = {
                    description = "Deepin daemon user";
                    group = "deepin-daemon";
                    isSystemUser = true;
                  };

                  users.groups.deepin_anything_server = { };
                  users.users.deepin_anything_server = {
                    description = "Deepin Anything Server";
                    group = "deepin_anything_server";
                    isSystemUser = true;
                  };

                  #services.dde.dde-daemon.enable = true;
                })

                (mkIf config.services.dde.dde-daemon.enable {
                  environment.systemPackages = [ packages.dde-daemon ];
                  services.dbus.packages = [ packages.dde-daemon ];
                  systemd.packages = [ packages.dde-daemon ];
                  users.groups.dde-daemon = { };
                  users.users.dde-daemon = {
                    description = "Deepin daemon user";
                    group = "dde-daemon";
                    isSystemUser = true;
                  };
               })

               
              ];
            };
        });
}
