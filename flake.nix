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
                  services.xserver.displayManager.sessionPackages = [ packages.startdde ];
                  services.xserver.displayManager.defaultSession = "deepin";
                  # services.xserver.displayManager.lightdm.greeters.gtk.enable = false;
                  # services.xserver.displayManager.lightdm.greeter = mkDefault {
                  #   package = packages.dde-session-shell.xgreeters;
                  #   name = "lightdm-deepin-greeter";
                  # };

                  #services.xserver.displayManager.lightdm.theme = mkDefault "deepin";
                  
                  hardware.bluetooth.enable = mkDefault true;
                  hardware.pulseaudio.enable = mkDefault true;

                  security.polkit.enable = true;
                  services.colord.enable = mkDefault true; # Need this?
                  services.fwupd.enable = mkDefault true;  # Need this?

                  
                  services.accounts-daemon.enable = true;
                  services.gnome.gnome-keyring.enable = true;
                  services.gnome.at-spi2-core.enable = true; # Need this?
                  services.gvfs.enable = true;  # Need this?
                  services.gnome.glib-networking.enable = true;  # Need this?


                  services.bamf.enable = true;
                  services.udev.packages = with packages; [
                    dde-daemon
                  ];
                  # pkg/etc/udev/rules.d and pkg/lib/udev/rules.d
            
                  services.xserver.updateDbusEnvironment = true;
                  services.xserver.libinput.enable = mkDefault true;      
                  # Enable GTK applications to load SVG icons
                  services.xserver.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

                  services.udisks2.enable = true;
                  services.upower.enable = true;
                  services.tumbler.enable = true;
                  
                  services.power-profiles-daemon.enable = true;
                  networking.networkmanager.enable = mkDefault true;
                  
                  programs.dconf.enable = true;
                  #programs.dconf.packages = [];
                  # /etc/dconf /etc/dconf/profiles/
                  programs.bash.vteIntegration = mkDefault true;
                  programs.zsh.vteIntegration = mkDefault true;

                  fonts.fonts = with pkgs; [ noto-fonts ];

                  xdg.mime.enable = true;
                  xdg.icons.enable = true;
                  xdg.portal.enable = true;
                  xdg.portal.extraPortals = [ 
                    (pkgs.xdg-desktop-portal-gtk.override {
                      buildPortalsInGnome = false;
                    })
                  ];

                  environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = "${nixos-gsettings-desktop-schemas}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";
                  environment.variables.DDE_POLKIT_AGENT_PLUGINS_DIRS = [ "${packages.dpa-ext-gnomekeyring}/lib/polkit-1-dde/plugins" ];

                  environment.pathsToLink = [
                    "/lib/deepin-daemon"
                    "/lib/deepin-api"
                    "/share/dsg"
                    # TODO
                    "/share"
                  ];

                  #environment.etc."deepin-version".source = "${packages.deepin-desktop-base}/etc/deepin-version";

                  environment.systemPackages = with packages; [
                    # dde-kwin
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
                    dde-clipboard
                    
                    deepin-desktop-schemas
                    dde-api
                    dde-daemon
                    dpa-ext-gnomekeyring # 这个怎么搞

                    dde-polkit-agent
                    dde-account-faces
                    deepin-voice-note
                    deepin-turbo
                    deepin-icon-theme
                    deepin-sound-theme
                    deepin-wallpapers
                    deepin-reader
                    dmarked
                    deepin-draw
                    deepin-boot-maker
                    deepin-gomoku
                    deepin-lianliankan
                    deepin-font-manager
                  ] ++ (with pkgs; [
                    socat
                    xdotool
                    glib # for gsettings program
                    gtk3.out # for gtk-launch program
                    xdg-user-dirs # Update user dirs as described in http://freedesktop.org/wiki/Software/xdg-user-dirs/
                    util-linux # runuser
                    polkit_gnome
                  ]);

                  services.dbus.packages = with packages; [
                    dde-api
                    dde-daemon
                    deepin-pw-check

                    dde-launcher
                    dde-session-ui
                    dde-session-shell
                    dde-app-services
                    dde-file-manager
                    dde-control-center
                    dde-calendar
                    deepin-picker
                    deepin-draw
                    deepin-image-viewer
                    deepin-screen-recorder
                    deepin-system-monitor
                    deepin-boot-maker
                    deepin-camera
                    dde-clipboard

                    dde-dock
                    deepin-anything
                  ];

                  systemd.packages = with packages; [
                    dde-launcher
                    dde-api
                    dde-daemon
                    dde-file-manager
                    dde-calendar
                    dde-clipboard

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
