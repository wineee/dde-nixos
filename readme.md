# dde-nixos

This is an experimental flake for DDE (Deepin Desktop Environment) on NixOS.

[Packaging Progress](https://github.com/linuxdeepin/dde-nixos/projects/1)

[DDE v20 has been merged into Nixpkgs](https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=deepin)

## Getting Started

### Installation for NixOS

#### With [flakes](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html) (Recommended):

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
      nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          dde-nixos.nixosModules.${system}
          {
            services.xserver.desktopManager.deepin-unstable.enable = true;
          }
          ./configuration.nix # your system configuration goes here
        ];
      };
    };
}
```
example: [rewine's NixOS config](https://github.com/wineee/nixos-config/commit/37c70c2c3b2a8e8ee00eba8ea336f67690683de1)


#### With ordinary `configuration.nix` and [flake-compat](https://github.com/edolstra/flake-compat):

```nix
{pkgs, ...}: let
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";

  dde-nixos = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/linuxdeepin/dde-nixos/archive/master.tar.gz";
  }).defaultNix;
in {
  imports = [dde-nixos.nixosModules.${pkgs.system}];

  services.xserver.desktopManager.deepin-unstable.enable = true;

  # other configuration still goes here
}
```

### Testing in Qemu

Quickly start an virtual machine to test out as long as you have installed nix:

``` bash
git clone git@github.com:linuxdeepin/dde-nixos.git
cd dde-nixos/vm
# edit vm/flake.nix
nix run -v -L
```
In case you don't apply custom configuration:

`nix --experimental-features 'nix-command flakes' run "github:linuxdeepin/dde-nixos?dir=vm" -v -L --no-write-lock-file`

## Building yourself

Using Nix build hooks:

```bash
nix build .#deepin-calculator -v -L
```

Manually build for debugging purposes:

```bash
nix develop .#deepin-calculator
git clone git@github.com:linuxdeepin/deepin-calculator.git
git checkout 5.7.16
... # maintainence code
cmake --build build
```

## Garnix cache

Thanks [Garnix](https://garnix.io/) for providing CI and binary cache.

For faster build and test with garnix cache, add `https://cache.garnix.io` to [substituters](https://search.nixos.org/options?channel=unstable&show=nix.settings.substituters&from=0&size=50&sort=relevance&type=packages), and `cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=` to [trusted-public-keys](https://search.nixos.org/options?channel=unstable&show=nix.settings.trusted-public-keys&from=0&size=50&sort=relevance&type=packages).

## Project using dde-nixos

- [nixos-dde-iso](https://github.com/SamLukeYes/nixos-dde-iso) NixOS live image with DDE [maintainer=@SamLukeYes]
- [dmarked](https://github.com/DMarked/DMarked)  dtk based markdown editor

## References
- [DDE Packaging Status](https://github.com/NixOS/nixpkgs/issues/94870)
- [Nix User Repository](https://github.com/nix-community/NUR)
- [nix-cutefish](https://github.com/p3psi-boo/nix-cutefish)
- [budgie-nix](https://github.com/FedericoSchonborn/budgie-nix)

## License

MIT
