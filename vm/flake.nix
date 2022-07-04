{
  inputs.dde-nixos.url = "..";

  outputs = inputs@{ self, dde-nixos }: let 
    nixpkgs = dde-nixos.inputs.nixpkgs;
  in {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        dde-nixos.nixosModules.default

        {
        imports = [ "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix" ];
        environment.enableDebugInfo = true;
        services.xserver = {
          enable = true;
          displayManager = {
            lightdm.enable = true;
          };
          desktopManager.plasma5 = {
            enable = true;
          };
          desktopManager.deepin = {
            enable = true;
          };
        };
        users.users.test = {
          isNormalUser = true;
          uid = 1000;
          extraGroups = [ "wheel" "networkmanager" ];
          password = "test";
        };
        virtualisation = {
          qemu.options = [ "-device intel-hda -device hda-duplex" ];
          cores = 4;
          memorySize = 4096;
          diskSize = 16384;
          resolution = { x = 1024; y = 768; };
        };
        system.stateVersion = "22.11";
      }];
    };
    packages.x86_64-linux.default = self.nixosConfigurations.vm.config.system.build.vm;
    apps.x86_64-linux.default = {
      type = "app";
      program = "${self.packages.x86_64-linux.default}/bin/run-nixos-vm";
    };
  };
}

