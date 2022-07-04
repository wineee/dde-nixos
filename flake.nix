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
          deepinPkgsDbg = with pkgs.lib.attrsets; mapAttrs'
            (
              name: value: nameValuePair
                (name + "-dbg")
                (value.override {
                  stdenv = pkgs.stdenvAdapters.keepDebugInfo pkgs.stdenv;
                })
            )
            deepinPkgs;
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

                #services.deepin.dde-daemon = {
                #  enable = mkEnableOption "dde daemon";
                #};
                ## TODO: deepin-anything
              };

              config = mkMerge [

                ### TODO
                (mkIf cfg.enable {
                  #services.xserver.displayManager.sessionPackages = [ pkgs.deepin.core ];
                  #services.xserver.displayManager.lightdm.theme = mkDefault "deepin";
                  #services.accounts-daemon.enable = true;

                  environment.pathsToLink = [ "/share" ];
                  environment.systemPackages =
                    let
                      deepinPkgs = with packages; [
                        deepin-terminal
                      ];
                    in
                    deepinPkgs;
                })

                #(mkIf config.services.deepin.dde-daemon.enable {
                #  environment.systemPackages = [ pkgs.deepin.dde-daemon ];
                #  systemd.packages = [ pkgs.deepin.dde-daemon ];
                #})
              ];
            };
        });
}
