# dde-nixos

DDE (Deepin Desktop Environment) on NixOS, ported back after it was removed from
nixpkgs and being migrated to Qt6 + Treeland.

> [!WARNING]
> **Experimental — please read before using.**
>
> - **The port is still in progress and is not usable.** Enabling
>   `services.desktopManager.deepin` does not give you a working desktop yet.
>   It is a porting workbench, not a daily driver.
> - **This repository is maintained with heavy AI assistance.** Package
>   definitions, patches, NixOS modules and docs are largely produced by coding
>   agents. They are **not guaranteed** to meet the standards nixpkgs requires
>   for merge, and are not meant to be upstreamed as-is. See
>   [docs/upstream-patches.md](docs/upstream-patches.md).

## Start here

- [docs/development.md](docs/development.md) — maintained-package table, Qt6
  upgrade log and build gotchas
- [docs/AI-GUIDE.md](docs/AI-GUIDE.md) — how the VM was verified on real
  hardware and what still fails
- `docs/porting/dde-*.md`, `docs/porting/dtk.md`, `docs/porting/libraries.md`,
  `docs/porting/go-packages.md` — per-package notes

```bash
cd vm && nix run -v -L      # DDM + Treeland VM
```

## Using this flake

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    dde-nixos = {
      url = "github:wineee/dde-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, dde-nixos, ... }:
    let system = "x86_64-linux";
    in {
      nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          dde-nixos.nixosModules.${system}
          { services.desktopManager.deepin.enable = true; }  # unusable, see docs
          ./configuration.nix
        ];
      };
    };
}
```

`nixosModules.deepin` is the canonical name; `nixosModules.<system>` is kept as
an alias for older configurations.

Non-flake setups go through `flake-compat` with
`https://github.com/wineee/dde-nixos/archive/main.tar.gz`.

## Building packages

```bash
nix build .#<package> --no-link   # single package
nix flake show                    # everything exposed
```

## Projects using this

- [nixos-dde-iso](https://github.com/SamLukeYes/nixos-dde-iso) — NixOS live image with DDE [maintainer=@SamLukeYes]
- [dmarked](https://github.com/DMarked/DMarked) — DTK based markdown editor

## References

- [DDE Packaging Status](https://github.com/NixOS/nixpkgs/issues/94870)
- [Nix User Repository](https://github.com/nix-community/NUR)
- [budgie-nix](https://github.com/FedericoSchonborn/budgie-nix)

## License

MIT
