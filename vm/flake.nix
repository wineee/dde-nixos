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
        environment.enableDebugInfo = true;
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
          exa
          ffmpeg
        ] ++ (with dde-nixos.packages.${super.system}; [
          deepin-draw
          deepin-voice-note
        ]);
        services.xserver = {
          enable = true;
          displayManager = {
            lightdm.enable = true;
            autoLogin = {
              enable = false;
              user = "test";
            };
          };
          desktopManager.plasma5.enable = true;

          desktopManager.deepin = {
            enable = true;
          };
        };
        time.timeZone = "Asia/Shanghai";
        fonts = {
          fonts = with pkgs; [
            noto-fonts
            noto-fonts-cjk
            noto-fonts-emoji
          ];
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
        system.stateVersion = "22.11";
      }];
    };
    packages.${system}.default = self.nixosConfigurations.vm.config.system.build.vm;
    apps.${system}.default = {
      type = "app";
      program = "${self.packages.${system}.default}/bin/run-nixos-vm";
    };
  };
}
