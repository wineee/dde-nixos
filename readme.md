# dde-nixos

This project is dedicated to packaging DDE for NixOS 

[Packaging Progress](https://github.com/linuxdeepin/dde-nixos/projects/1)

v23 port is WIP, Please use v20 branch !!!

## USAGE

### Enable DDE for NixOS

In order to use DDE, you must enable [flakes](https://nixos.wiki/wiki/Flakes) to manage your system configuration.

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    dde-nixos = {
      url = "github:linuxdeepin/dde-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
   };
  outputs = { self, nixpkgs, dde-nixos, ... } @ inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          dde-nixos.nixosModules.${system}
          {
            services.xserver.desktopManager.deepin.enable = true;
          }
        ];
      };
     # ......
    };
}
```

[an example](https://github.com/wineee/nixos-config/commit/37c70c2c3b2a8e8ee00eba8ea336f67690683de1)

### Use NixOS DDE in Qemu

Even if you aren't in NixOS, as long as you have installed nix, you can run dde-nixos in a virtual machine through `nix run`

``` bash
git clone git@github.com:linuxdeepin/dde-nixos.git
cd dde-nixos/vm
# edit vm/falke.nix
nix run -v -L
```
This can be done with a single command if you don't need custom configuration:

`nix --experimental-features 'nix-command flakes' run "github:linuxdeepin/dde-nixos?dir=vm" -v -L --no-write-lock-file`

## Build

```bash
nix build .#deepin-calculator -v -L
```

```bash
nix develop .#deepin-calculator
git clone git@github.com:linuxdeepin/deepin-calculator.git
git checkout 5.7.16
... # maintenance code
cmake --build build
```

## Garnix

Thanks [Garnix](https://garnix.io/) provide CI and binary caches.

In order to use the cache that garnix provides, adding https://cache.garnix.io to substituters, and cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g= to trusted-public-keys.

## Project use dde-nixos

- [nixos-dde-iso](https://github.com/SamLukeYes/nixos-dde-iso) NixOS live image with DDE @[SamLukeYes](https://github.com/SamLukeYes)
- [dmarked](https://github.com/DMarked/DMarked)  dtk based markdown editor

## References
- [Status of packaging the Deepin Desktop Environment ](https://github.com/NixOS/nixpkgs/issues/94870)
- [Nix User Repository](https://github.com/nix-community/NUR)
- [nix-cutefish](https://github.com/p3psi-boo/nix-cutefish)
- [budgie-nix](https://github.com/FedericoSchonborn/budgie-nix)

## License

MIT
