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
          # devShells = builtins.mapAttrs (
          #   name: value: 
          #     pkgs.mkShell {
          #       nativeBuildInputs = [ pkgs.qtcreator ]
          #               ++ deepinPkgs.${name}.nativeBuildInputs;
          #       buildInputs = deepinPkgs.${name}.buildInputs
          #               ++ deepinPkgs.${name}.propagatedBuildInputs;
          #       shellHook = ''
          #         # export QT_LOGGING_RULES=*.debug=true
          #         export QT_PLUGIN_PATH="$QT_PLUGIN_PATH:${deepinPkgs.qt5integration}/plugins"
          #         export QT_QPA_PLATFORM_PLUGIN_PATH="${deepinPkgs.qt5platform-plugins}/plugins"
          #       '';
          #    }
          # ) deepinPkgs;

#          overlays.default = final: prev: {
#            repoOverrides = { dde = (import ./packages { pkgs = prev.pkgs; }); };
#          };

          nixosModules = { config, lib, pkgs, ... }:
            with lib;
            let
              xcfg = config.services.xserver;
              cfg = xcfg.desktopManager.deepin;
            in
            {
              options = {
                services.xserver.desktopManager.deepin.enable = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Enable Deepin desktop manager";
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
                  #services.accounts-daemon.enable = true;

                  environment.pathsToLink = [ "/share" ];
                  environment.systemPackages = with packages; [
                    deepin-terminal-dbg
                    deepin-album-dbg
                    deepin-image-viewer-dbg
                    deepin-calculator-dbg
                    deepin-editor-dbg
                    deepin-music-dbg
                    deepin-movie-reborn-dbg
                    dde-file-manager-dbg
                    dde-launcher-dbg
                    dde-calendar-dbg 
                    deepin-camera-dbg
                    dde-dock-dbg
                    dde-session-ui-dbg
                    dde-session-shell-dbg

                    deepin-downloader-dbg
                    deepin-draw-dbg
                    deepin-boot-maker-dbg
                    deepin-gomoku-dbg
                    deepin-lianliankan-dbg
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

                  services.dde.dde-daemon.enable = true;
                })

                (mkIf config.services.dde.dde-daemon.enable {
                  environment.systemPackages = [ packages.dde-daemon-dbg ];
                  services.dbus.packages = [ packages.dde-daemon-dbg ];
                  systemd.packages = [ packages.dde-daemon-dbg ];
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
