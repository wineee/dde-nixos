# nix run -v -L
{
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixpkgs.url = "git+file:///home/rewine/nixpkgs?depth=1";

  outputs = inputs@{ self, nixpkgs }: let 
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        {
        imports = [ "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix" ];
        services.xserver = {
          enable = true;
          displayManager = {
            lightdm.enable = true;
            autoLogin = {
              enable = false;
              user = "test";
            };
          };
          desktopManager.deepin.enable = true;
        };
        services.openssh.enable = true;
        
        environment.systemPackages = with pkgs; [
          dfeet
          gnome.dconf-editor

          neovim
          jq
        ];
 
        users.users.test = {
          isNormalUser = true;
          uid = 1000;
          extraGroups = [ "wheel" "networkmanager" "libvirtd" "docker" "audio" "sound" "video" "input" "tty" "camera" "ssh" ];
          password = "test";
          createHome = true;
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
