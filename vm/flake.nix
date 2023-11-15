{
  inputs.dde-nixos.url = "..";

  outputs = inputs@{ self, dde-nixos }: let 
    nixpkgs = dde-nixos.inputs.nixpkgs;
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        dde-nixos.nixosModules.${system}

        {
        imports = [ "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix" ];
        #environment.enableDebugInfo = true;
        environment.systemPackages = with pkgs; [
          htop
          firefox
          neovim
          gdb
          neofetch
          gnome.dconf-editor
          dfeet
          binutils
          #gcc gnumake cmake
          #libsForQt5.full qtcreator
          gsettings-qt
          fzf
          fd
          ripgrep
          ranger
          ffmpeg
          xorg.xev
          
        ] ++ (with dde-nixos.packages.${super.system}; [
          # deepin-draw
          # deepin-voice-note
        ]);
        
        services.xserver = {
          enable = true;
          displayManager = {
            lightdm.enable = true;
            autoLogin = {
              enable = false;
              user = "test";
            };
            session = [{
              manage = "desktop";
              name = "xterm";
              start = ''
                ${pkgs.xterm}/bin/xterm -ls &
                waitPID=$!
              '';
            }];
          };
          #desktopManager.plasma5.enable = true;
          desktopManager.deepin-unstable = {
            enable = true;
            full = false;
          };
          #displayManager.defaultSession = "xterm";

        };
        #environment.deepin.excludePackages = with dde-nixos.packages.${system}; [
        #  deepin-draw
        #];
        time.timeZone = "Asia/Shanghai";
        fonts = {
          packages = with pkgs; [
            noto-fonts
            noto-fonts-cjk
            noto-fonts-emoji
          ];
        };
        i18n = {
          defaultLocale = "en_US.UTF-8";
          supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
        };
        
        users.users.test = {
          isNormalUser = true;
          uid = 1000;
          extraGroups = [ "wheel" "networkmanager" ];
          password = "test";
        };
        virtualisation = {
          qemu.options = [ "-device intel-hda -device hda-duplex" ];
          cores = 8;
          memorySize = 8192;
          diskSize = 16384;
          resolution = { x = 1024; y = 768; };
        };
        system.stateVersion = "23.11";
      }];
    };
    packages.${system}.default = self.nixosConfigurations.vm.config.system.build.vm;
    apps.${system}.default = {
      type = "app";
      program = "${self.packages.${system}.default}/bin/run-nixos-vm";
    };
  };
}
