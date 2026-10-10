{
  config,
  lib,
  pkgs,
  ...
}:

let
  dmcfg = config.services.displayManager;
  cfg = config.services.displayManager.ddm;

  iniFmt = pkgs.formats.ini { };

  defaultConfig =
    {
      General = {
        HaltCommand = "/run/current-system/systemd/bin/systemctl poweroff";
        RebootCommand = "/run/current-system/systemd/bin/systemctl reboot";
      };

      Wayland = {
        SessionDir = "${dmcfg.sessionData.desktops}/share/wayland-sessions";
      };
    }
    // lib.optionalAttrs dmcfg.autoLogin.enable {
      Autologin = {
        User = dmcfg.autoLogin.user;
        Session = "${dmcfg.sessionData.autologinSession}.desktop";
      };
    };

  cfgFile = iniFmt.generate "ddm.conf" (lib.recursiveUpdate defaultConfig cfg.settings);
in
{
  options.services.displayManager.ddm = {
    enable = lib.mkEnableOption "ddm, a fork of SDDM used as the Deepin display manager";

    package = lib.mkPackageOption pkgs.deepin [ "ddm" ] { };

    settings = lib.mkOption {
      type = iniFmt.type;
      default = { };
      description = ''
        Extra settings merged in and overwriting defaults in `ddm.conf`.

        See {manpage}`ddm.conf(5)` for the supported sections
        (`General`, `Theme`, `X11`, `Wayland`, `Single`, `Users`,
        `Autologin`).
      '';
      example = {
        Autologin = {
          User = "john";
          Session = "treeland.desktop";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = dmcfg.autoLogin.enable -> dmcfg.sessionData.autologinSession != null;
        message = ''
          ddm auto-login requires `services.displayManager.defaultSession` to be
          set (or at least one session package to be installed).
        '';
      }
    ];

    services.displayManager = {
      enable = true;
      generic = {
        enable = true;
        execCmd = "exec /run/current-system/sw/bin/ddm";
      };
    };

    # `services.xserver.enable = true` makes lightdm the fallback display
    # manager when no other DM is selected. ddm is a mutually exclusive
    # display manager, so force it off to avoid the two execCmds colliding.
    services.xserver.displayManager.lightdm.enable = lib.mkForce false;

    environment.systemPackages = [ cfg.package ];

    # The generated ddm.conf is read-only; ddm never rewrites it (it stores
    # runtime state in state.conf under the ddm user's home directory).
    environment.etc."ddm.conf.d/00-nixos.conf".source = cfgFile;

    # ddm talks to dde-seatd over /run/dde-seatd-{control,}.sock and owns
    # VT 7, so make sure it comes up after the seat daemon and does not
    # race with the getty on tty7.
    systemd.services.display-manager = {
      after = [
        "systemd-user-sessions.service"
        "getty@tty7.service"
        "plymouth-quit.service"
        "systemd-logind.service"
        "dde-seatd.service"
      ];
      conflicts = [ "getty@tty7.service" ];
    };

    # The dde-seatd package ships a hardened unit with
    # WantedBy=multi-user.target, but NixOS does not process [Install]
    # sections, so express that explicitly.
    systemd.packages = [ pkgs.deepin.dde-seatd ];
    systemd.services.dde-seatd.wantedBy = [ "multi-user.target" ];

    systemd.tmpfiles.rules = [
      # Home of the greeter (dde) and ddm state (state.conf) accounts.
      "d /var/lib/ddm 0750 dde dde - -"
      # X11 auth files passed to Xorg and the greeter.
      "d /run/ddm 0711 root root - -"
    ];

    users.groups.dde = { };
    users.groups.nopasswdlogin = { };

    users.users.dde = {
      description = "DDM greeter account";
      isSystemUser = true;
      group = "dde";
      home = "/var/lib/ddm";
      # treeland runs as this user and needs access to DRM devices.
      extraGroups = [
        "video"
        "render"
      ];
    };

    # ddm resolves the state.conf directory via getpwnam("ddm"), falling back
    # to the (read-only) store path baked into STATE_DIR. Point it at a
    # writable location.
    users.users.ddm = {
      description = "DDM state account";
      isSystemUser = true;
      group = "dde";
      home = "/var/lib/ddm";
    };

    security.pam.services.ddm.text = ''
      # Allow members of the nopasswdlogin group to log in without a password
      auth       sufficient    pam_succeed_if.so user ingroup nopasswdlogin
      auth       substack      login
      account    include       login
      password   substack      login
      session    include       login
    '';

    security.pam.services.ddm-autologin.text = ''
      auth       requisite     pam_nologin.so
      auth       required      pam_succeed_if.so uid >= 1000 quiet
      auth       required      pam_permit.so
      account    include       ddm
      password   include       ddm
      session    include       ddm
    '';
  };
}
