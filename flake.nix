{
  description = "deepin desktop environment for nixos";

  nixConfig.extra-substituters = "https://cache.garnix.io";
  nixConfig.extra-trusted-public-keys = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "i686-linux" ]
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          deepinScope = import ./packages { inherit pkgs; };
          deepinPkgs = flake-utils.lib.flattenTree deepinScope;
          getDbgVersion = name: value:
            (pkgs.lib.attrsets.nameValuePair
              (name + "-dbg")
              (if value.stdenv == pkgs.stdenvNoCC then value else
              value.override {
                stdenv = pkgs.stdenvAdapters.keepDebugInfo pkgs.stdenv;
              }));
          deepinPkgsDbg = with pkgs.lib.attrsets; mapAttrs' getDbgVersion deepinPkgs;
        in
        rec {
          packages = deepinPkgs // deepinPkgsDbg;
          devShells = builtins.mapAttrs
            (
              name: value:
                pkgs.mkShell {
                  nativeBuildInputs = deepinPkgs.${name}.nativeBuildInputs;
                  buildInputs = deepinPkgs.${name}.buildInputs
                    ++ deepinPkgs.${name}.propagatedBuildInputs;
                  shellHook = ''
                    # export QT_LOGGING_RULES=*.debug=true
                    export QT_PLUGIN_PATH="$QT_PLUGIN_PATH:${deepinPkgs.qt5integration}/plugins"
                    export QT_QPA_PLATFORM_PLUGIN_PATH="${deepinPkgs.qt5platform-plugins}/plugins"
                  '';
                }
            )
            deepinPkgs;

          nixosModules = { config, lib, pkgs, utils, ... }:
            with lib;
            let
              xcfg = config.services.xserver;
              cfg = xcfg.desktopManager.deepin-unstable;

              nixos-gsettings-desktop-schemas = packages.nixos-gsettings-schemas.override {
                extraGSettingsOverridePackages = cfg.extraGSettingsOverridePackages;
                extraGSettingsOverrides = cfg.extraGSettingsOverrides;
              };
            in
            {
              options = {
                services.xserver.desktopManager.deepin-unstable = {
                  enable = mkOption {
                    type = types.bool;
                    default = false;
                    description = "Enable Deepin desktop manager";
                  };
                  full = mkOption {
                    type = types.bool;
                    default = false;
                    description = "Install all deepin software";
                  };
                  extraGSettingsOverrides = mkOption {
                    default = "";
                    type = types.lines;
                    description = "Additional gsettings overrides.";
                  };
                  extraGSettingsOverridePackages = mkOption {
                    default = [ ];
                    type = types.listOf types.path;
                    description = "List of packages for which gsettings are overridden.";
                  };
                };

                environment.deepin-unstable.excludePackages = mkOption {
                  default = [ ];
                  type = types.listOf types.package;
                  description = lib.mdDoc "Which Deepin packages should exclude from systemPackages";
                };

                services.dde-unstable = {
                  dde-daemon.enable = mkEnableOption "Daemon for handling Deepin Desktop Environment session settings";
                  deepin-anything.enable = mkEnableOption "Lightning-fast filename search function for Linux users, and provides offline search functions";
                  dde-api.enable = mkEnableOption "Dbus interfaces that is used for screen zone detecting, thumbnail generating, sound playing, etc";
                  app-services.enable = mkEnableOption "Service collection of DDE applications, including dconfig-center";
                };

              };

              config = mkMerge [
                (mkIf cfg.enable {
                  services.xserver.displayManager.sessionPackages = [ packages.dde-session ];
                  services.xserver.displayManager.defaultSession = mkDefault "dde-x11";

                  # Update the DBus activation environment after launching the desktop manager.
                  services.xserver.displayManager.sessionCommands = ''
                    ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
                  '';

                  hardware.bluetooth.enable = mkDefault true;
                  hardware.pulseaudio.enable = mkDefault true;
                  security.polkit.enable = true;

                  services.colord.enable = mkDefault true;
                  services.accounts-daemon.enable = mkDefault true;
                  services.gvfs.enable = mkDefault true;
                  services.gnome.glib-networking.enable = true;
                  services.gnome.gnome-keyring.enable = mkDefault true;
                  services.bamf.enable = true;

                  services.xserver.libinput.enable = mkDefault true;
                  services.udisks2.enable = true;
                  services.upower.enable = mkDefault config.powerManagement.enable;
                  networking.networkmanager.enable = mkDefault true;
                  programs.dconf.enable = true;

                  #TODO: programs.gnupg.agent.pinentryFlavor = "qt";

                  fonts.fonts = with pkgs; [ noto-fonts ];
                  xdg.mime.enable = true;
                  xdg.menus.enable = true;
                  xdg.icons.enable = true;
                  xdg.portal.enable = mkDefault true;
                  xdg.portal.extraPortals = mkDefault [
                    (pkgs.xdg-desktop-portal-gtk.override {
                      buildPortalsInGnome = false;
                    })
                  ];

                  environment.sessionVariables = {
                    NIX_GSETTINGS_OVERRIDES_DIR = "${nixos-gsettings-desktop-schemas}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";
                    DDE_POLKIT_AGENT_PLUGINS_DIRS = [ "${packages.dpa-ext-gnomekeyring}/lib/polkit-1-dde/plugins" ];
                  };

                  environment.variables = {
                    #QT_QPA_PLATFORMTHEME = "dxcb"; # nixos/modules/config/qt5.nix
                    #QT_STYLE_OVERRIDE = "chameleon";
                    # D_PROXY_ICON_ENGINE = "KIconEngine";
                  };

                  environment.pathsToLink = [
                    "/lib/dde-dock/plugins"
                    "/lib/dde-control-center"
                    "/lib/dde-session-shell"
                    "/lib/dde-file-manager"
                    "/share/backgrounds"
                    "/share/wallpapers"
                  ];

                  environment.etc."distribution.info".text = ''
                    [Distribution]
                    Name=NixOS
                    WebsiteName=www.nixos.org
                    Website=https://www.nixos.org
                    Logo=${pkgs.nixos-icons}/share/icons/hicolor/96x96/apps/nix-snowflake.png
                    LogoLight=${pkgs.nixos-icons}/share/icons/hicolor/32x32/apps/nix-snowflake.png
                    LogoTransparent=${packages.deepin-desktop-base}/share/pixmaps/distribution_logo_transparent.svg
                  '';
                  environment.etc = {
                    "deepin/dde.conf".text = ''
                      [Password]
                      STRONG_PASSWORD = true
                      PASSWORD_MIN_LENGTH = 1
                      PASSWORD_MAX_LENGTH = 510
                      VALIDATE_POLICY = 1234567890;abcdefghijklmnopqrstuvwxyz;ABCDEFGHIJKLMNOPQRSTUVWXYZ;~`!@#$%^&*()-_+=|\{}[]:"'<>,.?/
                      VALIDATE_REQUIRED = 1
                      PALINDROME_NUM = 0
                      WORD_CHECK = 0
                      MONOTONE_CHARACTER_NUM = 0
                      CONSECUTIVE_SAME_CHARACTER_NUM = 0
                      DICT_PATH = 
                      FIRST_LETTER_UPPERCASE = false
                    '';
                    "deepin-installer.conf".text = ''
                      system_info_vendor_name="Copyright (c) 2003-2023 NixOS contributors"
                    '';
                  };

                  systemd.tmpfiles.rules = [
                    "d /var/lib/AccountsService 0775 root root - -"
                    "C /var/lib/AccountsService/icons 0775 root root - ${packages.dde-account-faces}/var/lib/AccountsService/icons"
                  ];

                  environment.systemPackages = with pkgs; with packages;
                    let
                      requiredPackages = [
                        pciutils # for dtkcore/startdde
                        xdotool # for dde-daemon
                        glib # for gsettings program / gdbus
                        gtk3 # for gtk-launch program
                        xdg-user-dirs # Update user dirs
                        util-linux # runuser
                        polkit_gnome
                        librsvg # dde-api use rsvg-convert
                        lshw # for dtkcore
                        libsForQt5.kde-gtk-config # deepin-api/gtk-thumbnailer need
                        libsForQt5.kglobalaccel
                        xsettingsd # lightdm-deepin-greeter
                        qt5platform-plugins
                        deepin-pw-check
                        deepin-turbo

                        dde-account-faces
                        #deepin-icon-theme
                        deepin-desktop-theme
                        deepin-sound-theme
                        deepin-gtk-theme
                        deepin-wallpapers

                        startdde
                        dde-dock
                        dde-launcher
                        dde-session-ui
                        dde-session-shell
                        dde-file-manager
                        dde-control-center
                        dde-network-core
                        dde-clipboard
                        dde-calendar
                        dde-polkit-agent
                        dpa-ext-gnomekeyring
                        deepin-desktop-schemas
                        deepin-terminal
                        deepin-kwin
                        dde-session
                        dde-widgets
                        dde-appearance
                        dde-application-manager
                      ];
                      optionalPackages = [
                        onboard # dde-dock plugin
                        deepin-camera
                        deepin-calculator
                        deepin-compressor
                        deepin-editor
                        deepin-picker
                        deepin-draw
                        deepin-album
                        deepin-image-viewer
                        deepin-music
                        deepin-movie-reborn
                        deepin-system-monitor
                        deepin-screen-recorder
                        deepin-shortcut-viewer
                      ];
                    in
                    requiredPackages
                    ++ utils.removePackagesByName optionalPackages config.environment.deepin-unstable.excludePackages;

                  services.dbus.packages = with pkgs; with packages; [
                    dde-dock
                    dde-launcher
                    dde-session-ui
                    dde-session-shell
                    dde-file-manager
                    dde-control-center
                    dde-calendar
                    dde-clipboard
                    deepin-kwin
                    deepin-pw-check
                    dde-widgets
                    dde-session
                  ];

                  systemd.packages = with pkgs; with packages; [
                    dde-launcher
                    dde-file-manager
                    dde-calendar
                    dde-clipboard
                    deepin-kwin
                    dde-appearance
                    dde-widgets
                    dde-session
                    dde-application-manager
                  ];

                  services.dde-unstable.dde-daemon.enable = mkForce true;
                  services.dde-unstable.dde-api.enable = mkForce true;
                  services.dde-unstable.app-services.enable = mkForce true;

                  services.dde-unstable.deepin-anything.enable = true;
                })

                (mkIf config.services.dde-unstable.dde-daemon.enable {
                  environment.systemPackages = [ packages.dde-daemon ];
                  services.dbus.packages = [ packages.dde-daemon ];
                  services.udev.packages = [ packages.dde-daemon ];
                  systemd.packages = [ packages.dde-daemon ];
                  environment.pathsToLink = [ "/lib/deepin-daemon" ];
                  security.pam.services.dde-lock.text = ''
                    # original at {dde-session-shell}/etc/pam.d/dde-lock
                    auth      substack      login
                    account   include       login
                    password  substack      login
                    session   include       login
                  '';
                })

                (mkIf config.services.dde-unstable.deepin-anything.enable {
                  environment.systemPackages = [ packages.deepin-anything ];
                  services.dbus.packages = [ packages.deepin-anything ];
                  # systemd.packages = [ packages.deepin-anything ];
                  environment.pathsToLink = [ "/lib/deepin-anything-server-lib" ];
                  environment.sessionVariables.DAS_PLUGIN_PATH = [ "/run/current-system/sw/lib/deepin-anything-server-lib/plugins/handlers" ];
                  users.groups.deepin-anything-server = { };
                  users.users.deepin-anything-server = {
                    description = "Deepin Anything Server";
                    group = "deepin-anything-server";
                    isSystemUser = true;
                  };
                  boot.extraModulePackages = [ (deepinScope.deepin-anything-module config.boot.kernelPackages.kernel) ];
                  boot.kernelModules = [ "vfs_monitor" ];
                  systemd.services.deepin-anything-tool = {
                    unitConfig = {
                      Description = "Deepin anything tool service";
                      After = [ "dbus.service" "udisks2.service" ];
                      Before = [ "deepin-anything-monitor.service" ];
                    };
                    serviceConfig = {
                      Type = "dbus";
                      User = "root";
                      Group = "root";
                      BusName = "com.deepin.anything";
                      ExecStart = "${packages.deepin-anything}/bin/deepin-anything-tool-ionice --dbus";
                      Restart = "on-failure";
                      RestartSec = 10;
                    };
                    wantedBy = [ "multi-user.target" ];
                    path = [ pkgs.util-linux packages.deepin-anything ]; # ionice
                  };
                  systemd.services.deepin-anything-monitor = {
                    unitConfig = {
                      Description = "Deepin anything service";
                      After = [ "deepin-anything-tool.service" ];
                    };
                    serviceConfig = {
                      User = "root";
                      Group = "deepin-anything-server";
                      ExecStart = "${packages.deepin-anything}/bin/deepin-anything-monitor";
                      ExecStartPre = "${pkgs.kmod}/bin/modprobe vfs_monitor";
                      ExecStopPost = "${pkgs.kmod}/bin/rmmod vfs_monitor";
                      Environment = [ "DAS_DEBUG_PLUGINS=1" ];
                      Restart = "always";
                      RestartSec = 10;
                    };
                    wantedBy = [ "multi-user.target" ];
                    path = [ pkgs.kmod packages.deepin-anything ]; # modprobe/rmmod
                  };
                })

                (mkIf config.services.dde-unstable.dde-api.enable {
                  environment.systemPackages = [ packages.dde-api ];
                  services.dbus.packages = [ packages.dde-api ];
                  systemd.packages = [ packages.dde-api ];
                  environment.pathsToLink = [ "/lib/deepin-api" ];
                  users.groups.deepin-sound-player = { };
                  users.users.deepin-sound-player = {
                    description = "Deepin sound player";
                    home = "/var/lib/deepin-sound-player";
                    createHome = true;
                    group = "deepin-sound-player";
                    isSystemUser = true;
                  };
                })

                (mkIf config.services.dde-unstable.app-services.enable {
                  environment.systemPackages = [ packages.dde-app-services ];
                  services.dbus.packages = [ packages.dde-app-services ];
                  environment.pathsToLink = [ "/share/dsg" ];
                })

              ];
            };
        });
}
