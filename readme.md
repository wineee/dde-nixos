# dde-nixos

This project is dedicated to packaging DDE for NixOS 

[Packaging Progress](https://github.com/linuxdeepin/dde-nixos/projects/1)

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
	  ({ pkgs, config, ... }: {
            imports = [
              dde-nixos.nixosModules.${system}
            ];
            config.services.xserver.desktopManager.deepin.enable = true;
          })
	];
     # ......
    };
}
```

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

## References
- [Status of packaging the Deepin Desktop Environment ](https://github.com/NixOS/nixpkgs/issues/94870)
- [Nix User Repository](https://github.com/nix-community/NUR)
- [nix-cutefish](https://github.com/p3psi-boo/nix-cutefish)

## License

MIT
