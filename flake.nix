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
                (if value.stdenv == pkgs.stdenvNoCC then value else value.override {
                  stdenv = pkgs.stdenvAdapters.keepDebugInfo pkgs.stdenv;
                }));
          deepinPkgsDbg = with pkgs.lib.attrsets; mapAttrs' getDbgVersion deepinPkgs;
        in
        rec {
          packages = deepinPkgs // deepinPkgsDbg;
          devShells = builtins.mapAttrs (
            name: value: 
              pkgs.mkShell {
                nativeBuildInputs = deepinPkgs.${name}.nativeBuildInputs;
                buildInputs = deepinPkgs.${name}.buildInputs
                        ++ deepinPkgs.${name}.propagatedBuildInputs;
                shellHook = ''
                  # export QT_LOGGING_RULES=*.debug=true
                  export QT_PLUGIN_PATH="$QT_PLUGIN_PATH:${deepinPkgs.qt5integration}/plugins"
                '';
             }
          ) deepinPkgs;

          nixosModules = { config, lib, pkgs, utils, ... }:
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
                    default = [];
                    type = types.listOf types.path;
                    description = "List of packages for which gsettings are overridden.";
                  };
                };

                environment.deepin.excludePackages = mkOption {
                  default = [];
                  type = types.listOf types.package;
                  description = lib.mdDoc "Which Deepin packages should exclude from systemPackages";
                };

                services.dde = {
                  dde-daemon.enable = mkEnableOption "Daemon for handling Deepin Desktop Environment session settings";
                  dde-api.enable = mkEnableOption "Dbus interfaces that is used for screen zone detecting, thumbnail generating, sound playing, etc";
                  app-services.enable = mkEnableOption "Service collection of DDE applications, including dconfig-center";
                };
                
              };

              config = mkMerge [
                (mkIf cfg.enable {
                  services.xserver.displayManager.sessionPackages = [ pkgs.deepin.startdde ];
                  services.xserver.displayManager.defaultSession = "deepin";

                  services.xserver.displayManager.sessionCommands = ''
                      ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
                  '';
                  
                  
                  hardware.bluetooth.enable = mkDefault true;
                  hardware.pulseaudio.enable = mkDefault true;

                  security.polkit.enable = true;
                  services.colord.enable = mkDefault true;
                  
                  services.accounts-daemon.enable = true;
                  services.gvfs.enable = true;
                  services.gnome.glib-networking.enable = true;
                  services.gnome.gnome-keyring.enable = true;

                  services.bamf.enable = true;
                  
                  services.xserver.updateDbusEnvironment = true;
                  services.xserver.libinput.enable = mkDefault true;      
                  # Enable GTK applications to load SVG icons
                  services.xserver.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

                  services.udisks2.enable = true;
                  services.upower.enable = mkDefault config.powerManagement.enable;
                  # services.tumbler.enable = mkDefault true;
                  
                  # services.power-profiles-daemon.enable = true;
                  networking.networkmanager.enable = mkDefault true;
                  
                  programs.dconf.enable = true;

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
                    DDE_POLKIT_AGENT_PLUGINS_DIRS = [ "${pkgs.deepin.dpa-ext-gnomekeyring}/lib/polkit-1-dde/plugins" ];
                  };

                  environment.variables = {
                    # QT_PLUGIN_PATH = [
                    #   "{packages.qt5platform-plugins}/${pkgs.libsForQt5.qtbase.qtPluginPrefix}"
                    #   "{packages.qt5integration}/${pkgs.libsForQt5.qtbase.qtPluginPrefix}" 
                    # ];
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
                    "/share/sounds/deepin"
                  ];

                  environment.etc."distribution.info".text = ''
                    [Distribution]
                    Name=NixOS
                    WebsiteName=www.nixos.org
                    Website=https://www.nixos.org
                    Logo=${pkgs.nixos-icons}/share/icons/hicolor/96x96/apps/nix-snowflake.png
                    LogoLight=${pkgs.nixos-icons}/share/icons/hicolor/32x32/apps/nix-snowflake.png
                    LogoTransparent=${pkgs.deepin.deepin-desktop-base}/share/pixmaps/distribution_logo_transparent.svg
                  '';
                  environment.etc = {
                    #"X11/Xsession.d".source = "${packages.startdde}/etc/X11/Xsession.d";
                    #"dde-session-shell/dde-session-shell.conf".source = "${pkgs.deepin.dde-session-shell}/share/dde-session-shell/dde-session-shell.conf";
                    #"deepin/greeters.d".source = "${pkgs.deepin.dde-session-shell}/etc/deepin/greeters.d";
                    #"dde-dock/indicator".source = "${pkgs.deepin.dde-dock}/etc/dde-dock/indicator";
                    "polkit-1/localauthority/10-vendor.d/10-network-manager.pkla".source = "${pkgs.deepin.dde-network-core}/var/lib/polkit-1/localauthority/10-vendor.d/10-network-manager.pkla";
                    # "deepin/dde.conf".text = ''
                    #   [Password]
                    #   STRONG_PASSWORD = true
                    #   PASSWORD_MIN_LENGTH = 1
                    #   PASSWORD_MAX_LENGTH = 510
                    #   VALIDATE_POLICY = 1234567890;abcdefghijklmnopqrstuvwxyz;ABCDEFGHIJKLMNOPQRSTUVWXYZ;~`!@#$%^&*()-_+=|\{}[]:"'<>,.?/
                    #   VALIDATE_REQUIRED = 1
                    #   PALINDROME_NUM = 0
                    #   WORD_CHECK = 0
                    #   MONOTONE_CHARACTER_NUM = 0
                    #   CONSECUTIVE_SAME_CHARACTER_NUM = 0
                    #   DICT_PATH = 
                    #   FIRST_LETTER_UPPERCASE = false
                    # '';
                    "deepin-installer.conf".text = ''
                      system_info_vendor_name="Copyright (c) 2003-2023 NixOS contributors"
                    '';
                  };

                  systemd.tmpfiles.rules = [
                    "d /var/lib/AccountsService 0775 root root - -"
                    "C /var/lib/AccountsService/icons 0775 root root - ${pkgs.deepin.dde-account-faces}/var/lib/AccountsService/icons"
                  ];

                  environment.systemPackages = with pkgs; with deepin; [
                    pciutils # startdde
                    socat
                    xdotool
                    glib # for gsettings program / gdbus
                    gtk3.out # for gtk-launch program
                    xdg-user-dirs # Update user dirs as described in http://freedesktop.org/wiki/Software/xdg-user-dirs/
                    util-linux # runuser
                    polkit_gnome
                    librsvg # dde-api use rsvg-convert
                    kde-gtk-config # deepin-api/gtk-thumbnailer need
                    lshw
                    libsForQt5.kglobalaccel
                    onboard # dde-dock plugin
                    xsettingsd # lightdm-deepin-greeter
                    qt5platform-plugins
                    deepin-pw-check
                    deepin-turbo
                    dde-account-faces
                    deepin-icon-theme
                    deepin-sound-theme
                    deepin-gtk-theme
                    deepin-wallpapers
                    deepin-camera

                    dpa-ext-gnomekeyring
                    dde-polkit-agent
                    deepin-terminal
                    deepin-album
                    deepin-draw
                    deepin-image-viewer
                    deepin-calculator
                    deepin-editor
                    deepin-picker
                    dde-control-center

                    dde-session-ui
                    dde-session-shell
                    dde-launcher
                    dde-dock
                    dde-network-core
                    dde-clipboard
                    dde-calendar

                    startdde
                    dde-file-manager
                    deepin-desktop-schemas
                    
                    deepin-music
                    deepin-movie-reborn
                    #deepin-system-monitor
                    deepin-shortcut-viewer

                    deepin-compressor

                  ] ++ (with packages; (utils.removePackagesByName ([
                    dde-kwin
                    deepin-kwin
                    deepin-screen-recorder
                  ]) config.environment.deepin.excludePackages));

                  services.dbus.packages =  with pkgs; with deepin; [
                    deepin-pw-check
                    deepin-picker
                    deepin-draw
                    deepin-image-viewer
                    dde-control-center
                    dde-launcher
                    dde-dock
                    dde-session-ui
                    dde-session-shell
                  ] ++ (with packages; (utils.removePackagesByName ([
                    dde-kwin
                    deepin-kwin
                   
                    dde-file-manager
                    dde-calendar
                    #deepin-screen-recorder
                    deepin-system-monitor
                    deepin-camera
                    dde-clipboard
                  ] ++ lib.optionals cfg.full [
                    dde-grand-search
                  ]) config.environment.deepin.excludePackages));

                  systemd.packages = with pkgs.deepin; [
                    packages.deepin-kwin
                    dde-launcher
                    dde-file-manager
                    dde-calendar
                    dde-clipboard
                  ];

                  services.dde.dde-daemon.enable = mkForce true;
                  services.dde.dde-api.enable = mkForce true;
                  services.dde.app-services.enable = mkForce true;

                })

                (mkIf config.services.dde.dde-daemon.enable {
                  environment.systemPackages = [ pkgs.deepin.dde-daemon ];
                  services.dbus.packages = [ pkgs.deepin.dde-daemon ];
                  services.udev.packages = [ pkgs.deepin.dde-daemon ];
                  systemd.packages = [ pkgs.deepin.dde-daemon ];
                  environment.pathsToLink = [ "/lib/deepin-daemon" ];
                  environment.etc= {
                    #"lightdm/deepin/xsettingsd.conf".source = "${pkgs.deepin.dde-daemon}/etc/lightdm/deepin/xsettingsd.conf";
                    #"pam.d/deepin-auth-keyboard"
                    #"acpi/actions/deepin_lid.sh".source = "${packages.dde-daemon}/etc/acpi/actions/deepin_lid.sh";
                    #"polkit-1/localauthority/10-vendor.d/com.deepin.daemon.Accounts.pkla".source = "${packages.dde-daemon}/var/lib/polkit-1/localauthority/10-vendor.d/com.deepin.daemon.Accounts.pkla";
                    #"polkit-1/localauthority/10-vendor.d/com.deepin.daemon.Fprintd.pkla".source = "${packages.dde-daemon}/var/lib/polkit-1/localauthority/10-vendor.d/com.deepin.daemon.Fprintd.pkla";
                    #"polkit-1/localauthority/10-vendor.d/com.deepin.daemon.Grub2.pkla".source = "${packages.dde-daemon}/var/lib/polkit-1/localauthority/10-vendor.d/com.deepin.daemon.Grub2.pkla";
                  };
                  # security.pam.services.deepin-auth-keyboard.text = ''
                  #   # original at {dde-daemon}/etc/pam.d/deepin-auth-keyboard
                  #   auth    [success=5 default=ignore]      pam_unix.so nullok_secure
                  #   -auth   [success=4 default=ignore]      pam_lsass.so
                  #   -auth   [authinfo_unavail=ignore success=3 default=ignore]      pam_ldap.so minimum_uid=1000 use_first_pass
                  #   -auth   [success=2 default=ignore] pam_ccreds.so minimum_uid=1000 action=validate use_first_pass
                  #   -auth   [default=ignore] pam_ccreds.so minimum_uid=1000 action=update
                  #   auth    requisite       pam_deny.so
                  #   auth    required        pam_permit.so
                  #   -auth   optional        pam_ccreds.so minimum_uid=1000 action=store
                  # '';
                  security.pam.services.dde-lock.text = ''
                    # original at {dde-session-shell}/etc/pam.d/dde-lock
                    auth      substack      login
                    account   include       login
                    password  substack      login
                    session   include       login
                  '';
               })


               (mkIf config.services.dde.dde-api.enable {
                  environment.systemPackages = [ pkgs.deepin.dde-api ];
                  services.dbus.packages = [ pkgs.deepin.dde-api ];
                  systemd.packages = [ pkgs.deepin.dde-api ];
                  environment.pathsToLink = [ "/lib/deepin-api" ];
                  users.groups.deepin-sound-player = { };
                  users.users.deepin-sound-player = {
                    description = "Deepin sound player";
                    home = "/var/lib/deepin-sound-player";
                    createHome = true;
                    group = "deepin-sound-player";
                    isSystemUser = true;
                  };
                  #environment.etc."polkit-1/localauthority/10-vendor.d/com.deepin.api.device.pkla".source = "${pkgs.deepin.dde-api}/var/lib/polkit-1/localauthority/10-vendor.d/com.deepin.api.device.pkla";
               })

               (mkIf config.services.dde.app-services.enable {
                  environment.systemPackages = [ pkgs.deepin.dde-app-services ];
                  services.dbus.packages = [ pkgs.deepin.dde-app-services ];
                  environment.pathsToLink = [ "/share/dsg" ];
               })

              ];
            };
        });
}
